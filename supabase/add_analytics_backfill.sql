-- ============================================================================
-- One-time migration: BACKFILL existing history into the unified model.
-- Run ONCE, AFTER add_analytics_core.sql (order doesn't matter vs. _views).
-- ============================================================================
--
-- Converts what you already collected in the app —
--   leads             → anon_visitors + persons + person_anon_map + 'register'
--   practice_activity → 'practice_complete' / 'view' events
-- — so the funnel and CRM reports include your existing users from day one.
--
-- Safe to run once. Re-running is a no-op: a guard checks for the backfill
-- marker and skips, and the identity inserts use ON CONFLICT / NOT-EXISTS.
--
-- Note: authenticated-user history (auth.users + quiz_results) is left in place;
-- the anonymous leads/practice_activity path is the primary funnel going
-- forward. Those can be merged into persons later by email if desired.
-- ============================================================================

do $$
begin
  if exists (select 1 from events where (props->>'_backfill') = 'true') then
    raise notice 'Analytics backfill already ran — skipping.';
    return;
  end if;

  -- 1. Devices seen in the app (first touch = earliest lead/activity for it).
  insert into anon_visitors (anon_id, first_property, first_seen_at)
  select cid, 'app', min(ts)
  from (
    select client_id as cid, created_at as ts from leads            where client_id is not null
    union all
    select client_id,        created_at        from practice_activity where client_id is not null
  ) s
  group by cid
  on conflict (anon_id) do nothing;

  -- 2. Persons + device map from leads that carry a client_id.
  with lead_person as (
    select distinct on (client_id)
      client_id, name, email, phone, location
    from leads
    where client_id is not null
      and client_id not in (select anon_id from person_anon_map)
    order by client_id, created_at desc
  ),
  with_ids as (
    select
      gen_random_uuid() as pid,
      lp.client_id, lp.name, lp.email, lp.phone, lp.location,
      (select min(created_at) from leads l where l.client_id = lp.client_id) as first_reg
    from lead_person lp
  ),
  ins_persons as (
    insert into persons (id, name, email, phone, location, first_registered_at, created_at)
    select pid, nullif(trim(name), ''), nullif(lower(trim(email)), ''),
           nullif(trim(phone), ''), nullif(trim(location), ''), first_reg, first_reg
    from with_ids
    returning id
  )
  insert into person_anon_map (anon_id, person_id, linked_at)
  select client_id, pid, first_reg from with_ids
  on conflict (anon_id) do nothing;

  -- 3. Persons from leads WITHOUT a client_id (keep them in the CRM), deduped
  --    against people we already have by email.
  insert into persons (name, email, phone, location, first_registered_at, created_at)
  select distinct on (lower(trim(l.email)))
         nullif(trim(l.name), ''), nullif(lower(trim(l.email)), ''),
         nullif(trim(l.phone), ''), nullif(trim(l.location), ''),
         l.created_at, l.created_at
  from leads l
  where l.client_id is null
    and nullif(lower(trim(l.email)), '') is not null
    and not exists (
      select 1 from persons p where lower(p.email) = lower(trim(l.email))
    )
  order by lower(trim(l.email)), l.created_at asc;

  -- 4. 'register' events from leads.
  insert into events (anon_id, property, event_name, occurred_at, props)
  select client_id, 'app', 'register', created_at,
         jsonb_build_object('_backfill', true)
  from leads
  where client_id is not null;

  -- 5. practice / view events from practice_activity.
  insert into events (anon_id, property, event_name, occurred_at, props)
  select
    client_id, 'app',
    case when activity_type = 'practice' then 'practice_complete' else 'view' end,
    created_at,
    jsonb_strip_nulls(jsonb_build_object(
      'category',     category,
      'mode',         mode,
      'content_type', content_type,
      'correct',      correct,
      'total',        total,
      '_backfill',    true
    ))
  from practice_activity
  where client_id is not null;

  raise notice 'Analytics backfill complete.';
end;
$$;
