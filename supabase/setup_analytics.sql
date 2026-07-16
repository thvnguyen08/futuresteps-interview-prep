-- ============================================================================
-- FUTURE STEPS — UNIFIED ANALYTICS SETUP (run once, top to bottom)
-- Paste this whole file into Supabase → SQL Editor → New query → Run.
-- It bundles, in order:
--   1) add_analytics_core.sql      (tables + identify() + analytics_channel())
--   2) add_analytics_views.sql     (admin-gated reader functions)
--   3) add_analytics_backfill.sql  (imports existing leads + practice_activity)
-- Safe to re-run: tables use IF NOT EXISTS, functions CREATE OR REPLACE, and
-- the backfill is guarded so it only imports once.
-- ============================================================================


-- ############################################################################
-- ## 1. CORE — tables, write path, helpers
-- ############################################################################

create table if not exists anon_visitors (
  anon_id            text primary key,
  first_property     text check (first_property in ('web', 'app')),
  first_seen_at      timestamptz not null default now(),
  first_referrer     text,
  first_landing_path text,
  first_utm_source   text,
  first_utm_medium   text,
  first_utm_campaign text,
  first_utm_content  text,
  first_utm_term     text
);

alter table anon_visitors enable row level security;
drop policy if exists "anyone can record first touch" on anon_visitors;
create policy "anyone can record first touch" on anon_visitors
  for insert with check (true);

create table if not exists persons (
  id                  uuid primary key default gen_random_uuid(),
  name                text,
  email               text,
  phone               text,
  location            text,
  first_registered_at timestamptz,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);
create index if not exists persons_email_idx on persons (lower(email));
create index if not exists persons_phone_idx on persons (phone);
alter table persons enable row level security;

create table if not exists person_anon_map (
  anon_id   text primary key,
  person_id uuid not null references persons(id) on delete cascade,
  linked_at timestamptz not null default now()
);
create index if not exists person_anon_map_person_idx on person_anon_map (person_id);
alter table person_anon_map enable row level security;

create table if not exists events (
  id           bigint generated always as identity primary key,
  anon_id      text not null,
  property     text not null check (property in ('web', 'app')),
  event_name   text not null,
  session_id   text,
  page_path    text,
  referrer     text,
  utm_source   text,
  utm_medium   text,
  utm_campaign text,
  utm_content  text,
  utm_term     text,
  props        jsonb not null default '{}'::jsonb,
  occurred_at  timestamptz not null default now(),
  created_at   timestamptz not null default now()
);
create index if not exists events_anon_idx     on events (anon_id);
create index if not exists events_name_idx     on events (event_name);
create index if not exists events_occurred_idx on events (occurred_at desc);
create index if not exists events_property_idx on events (property);
alter table events enable row level security;
drop policy if exists "anyone can log an event" on events;
create policy "anyone can log an event" on events
  for insert with check (true);

create or replace function identify(
  p_anon_id  text,
  p_name     text,
  p_email    text,
  p_phone    text,
  p_location text,
  p_property text default 'app'
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_email  text := nullif(lower(trim(p_email)), '');
  v_phone  text := nullif(trim(p_phone), '');
  v_person uuid;
begin
  if p_anon_id is null or length(trim(p_anon_id)) = 0 then
    raise exception 'identify(): anon_id is required';
  end if;

  insert into anon_visitors (anon_id, first_property)
  values (p_anon_id, p_property)
  on conflict (anon_id) do nothing;

  select person_id into v_person from person_anon_map where anon_id = p_anon_id;

  if v_person is null then
    select id into v_person
    from persons
    where (v_email is not null and lower(email) = v_email)
       or (v_phone is not null and phone = v_phone)
    order by created_at
    limit 1;
  end if;

  if v_person is null then
    insert into persons (name, email, phone, location, first_registered_at)
    values (nullif(trim(p_name), ''), v_email, v_phone,
            nullif(trim(p_location), ''), now())
    returning id into v_person;
  else
    update persons set
      name                = coalesce(name, nullif(trim(p_name), '')),
      email               = coalesce(email, v_email),
      phone               = coalesce(phone, v_phone),
      location            = coalesce(location, nullif(trim(p_location), '')),
      first_registered_at = coalesce(first_registered_at, now()),
      updated_at          = now()
    where id = v_person;
  end if;

  insert into person_anon_map (anon_id, person_id)
  values (p_anon_id, v_person)
  on conflict (anon_id) do update set person_id = excluded.person_id;

  insert into events (anon_id, property, event_name, occurred_at)
  values (p_anon_id, p_property, 'register', now());

  return v_person;
end;
$$;

grant execute on function identify(text, text, text, text, text, text)
  to anon, authenticated;

create or replace function analytics_channel(
  p_utm_source text,
  p_utm_medium text,
  p_referrer   text
)
returns text
language sql
immutable
as $$
  select case
    when lower(coalesce(p_utm_medium, '')) in
           ('cpc','ppc','paid','paidsocial','paid_social','paid-social')
     and (lower(coalesce(p_utm_source, '')) like '%facebook%'
       or lower(coalesce(p_utm_source, '')) in ('fb','meta','ig','instagram'))
      then 'FB Ads'
    when lower(coalesce(p_utm_source, '')) like '%facebook%'
      or lower(coalesce(p_utm_source, '')) in ('fb','meta')
      or lower(coalesce(p_referrer, ''))   like '%facebook.%'
      or lower(coalesce(p_referrer, ''))   like '%//fb.%'
      or lower(coalesce(p_referrer, ''))   like '%l.facebook%'
      or lower(coalesce(p_referrer, ''))   like '%lm.facebook%'
      then 'FB Posts'
    when lower(coalesce(p_utm_medium, '')) in ('cpc','ppc','paid')
      then 'Paid'
    when lower(coalesce(p_referrer, '')) ~ '(google|bing|yahoo|duckduckgo|ecosia)\.'
      then 'Organic Search'
    when coalesce(p_referrer, '') = '' and coalesce(p_utm_source, '') = ''
      then 'Direct / Word-of-mouth'
    else 'Referral'
  end;
$$;


-- ############################################################################
-- ## 2. READERS — admin-gated funnel / channel / CRM functions
-- ## ⚠  Keep admin_emails in sync with crm_view.sql / add_leads.sql.
-- ####################################################$#######################

create or replace function _person_rollup()
returns table (
  person_id           uuid,
  name                text,
  email               text,
  phone               text,
  location            text,
  first_seen_at       timestamptz,
  first_registered_at timestamptz,
  last_active_at      timestamptz,
  last_practice_at    timestamptz,
  channel             text,
  practice_rounds     bigint,
  questions_done      bigint,
  questions_right     bigint,
  top_category        text,
  categories          jsonb,
  is_activated        boolean,
  is_active           boolean
)
language sql
security definer
set search_path = public
as $$
  with anon_of_person as (
    select m.person_id, m.anon_id from person_anon_map m
  ),
  first_anon as (
    select distinct on (ap.person_id)
      ap.person_id,
      v.first_seen_at,
      analytics_channel(v.first_utm_source, v.first_utm_medium, v.first_referrer) as channel
    from anon_of_person ap
    join anon_visitors v on v.anon_id = ap.anon_id
    order by ap.person_id, v.first_seen_at asc
  ),
  ev as (
    select
      ap.person_id, e.event_name, e.occurred_at,
      nullif(e.props->>'category', '')        as category,
      coalesce((e.props->>'total')::int, 0)   as total,
      coalesce((e.props->>'correct')::int, 0) as correct
    from anon_of_person ap
    join events e on e.anon_id = ap.anon_id
  ),
  agg as (
    select
      ev.person_id,
      max(ev.occurred_at) as last_active_at,
      max(ev.occurred_at) filter (where ev.event_name = 'practice_complete') as last_practice_at,
      count(*) filter (where ev.event_name = 'practice_complete') as practice_rounds,
      coalesce(sum(ev.total)   filter (where ev.event_name = 'practice_complete'), 0) as questions_done,
      coalesce(sum(ev.correct) filter (where ev.event_name = 'practice_complete'), 0) as questions_right
    from ev group by ev.person_id
  ),
  cat as (
    select ev.person_id, ev.category, count(*) as rounds
    from ev
    where ev.event_name = 'practice_complete' and ev.category is not null
    group by ev.person_id, ev.category
  ),
  top_cat as (
    select distinct on (person_id) person_id, category, rounds
    from cat order by person_id, rounds desc, category
  ),
  cat_json as (
    select person_id, jsonb_object_agg(category, rounds) as categories
    from cat group by person_id
  )
  select
    p.id, p.name, p.email, p.phone, p.location,
    fa.first_seen_at, p.first_registered_at, a.last_active_at,
    a.last_practice_at,
    coalesce(fa.channel, 'Direct / Word-of-mouth'),
    coalesce(a.practice_rounds, 0),
    coalesce(a.questions_done, 0),
    coalesce(a.questions_right, 0),
    tc.category,
    coalesce(cj.categories, '{}'::jsonb),
    coalesce(a.practice_rounds, 0) > 0,
    exists (
      select 1 from ev
      where ev.person_id = p.id
        and p.first_registered_at is not null
        and ev.occurred_at::date > p.first_registered_at::date
        and ev.occurred_at <= p.first_registered_at + interval '7 days'
    )
  from persons p
  left join first_anon fa on fa.person_id = p.id
  left join agg a       on a.person_id = p.id
  left join top_cat tc  on tc.person_id = p.id
  left join cat_json cj on cj.person_id = p.id;
$$;

create or replace function get_funnel_summary()
returns table (visitors bigint, leads bigint, activated bigint, active bigint)
language plpgsql security definer set search_path = public
as $$
declare admin_emails text[] := array['thvnguyen08@gmail.com', 'futuresteps.dallas@gmail.com'];
begin
  -- coalesce() matters: an anon-key caller has no 'email' claim, so the
  -- comparison is NULL and `if not (NULL)` is falsy in plpgsql -- it would NOT
  -- return early, silently leaking data.
  if not (coalesce(auth.jwt()->>'email', '') = any(admin_emails)) then return; end if;
  return query
  select
    (select count(*) from anon_visitors)::bigint,
    (select count(*) from persons)::bigint,
    (select count(*) from _person_rollup() where is_activated)::bigint,
    (select count(*) from _person_rollup() where is_active)::bigint;
end;
$$;

create or replace function get_channel_performance()
returns table (channel text, visitors bigint, leads bigint, activated bigint, active bigint)
language plpgsql security definer set search_path = public
as $$
declare admin_emails text[] := array['thvnguyen08@gmail.com', 'futuresteps.dallas@gmail.com'];
begin
  -- coalesce() matters: an anon-key caller has no 'email' claim, so the
  -- comparison is NULL and `if not (NULL)` is falsy in plpgsql -- it would NOT
  -- return early, silently leaking data.
  if not (coalesce(auth.jwt()->>'email', '') = any(admin_emails)) then return; end if;
  return query
  with visitor_channel as (
    select analytics_channel(first_utm_source, first_utm_medium, first_referrer) as channel,
           count(*) as visitors
    from anon_visitors group by 1
  ),
  person_channel as (
    select r.channel,
           count(*) as leads,
           count(*) filter (where r.is_activated) as activated,
           count(*) filter (where r.is_active)    as active
    from _person_rollup() r group by 1
  )
  select
    coalesce(vc.channel, pc.channel),
    coalesce(vc.visitors, 0), coalesce(pc.leads, 0),
    coalesce(pc.activated, 0), coalesce(pc.active, 0)
  from visitor_channel vc
  full outer join person_channel pc on pc.channel = vc.channel
  order by 5 desc, 2 desc;
end;
$$;

create or replace function get_person_crm()
returns table (
  name text, email text, phone text, location text, channel text, stage text,
  top_category text, categories jsonb,
  first_seen_at timestamptz, first_registered_at timestamptz, last_active_at timestamptz,
  last_practice_at timestamptz, days_since_practice int,
  practice_rounds bigint, questions_done bigint, questions_right bigint
)
language plpgsql security definer set search_path = public
as $$
declare admin_emails text[] := array['thvnguyen08@gmail.com', 'futuresteps.dallas@gmail.com'];
begin
  -- coalesce() matters: an anon-key caller has no 'email' claim, so the
  -- comparison is NULL and `if not (NULL)` is falsy in plpgsql -- it would NOT
  -- return early, silently leaking data.
  if not (coalesce(auth.jwt()->>'email', '') = any(admin_emails)) then return; end if;
  return query
  select
    r.name, r.email, r.phone, r.location, r.channel,
    case when r.is_active then 'Active'
         when r.is_activated then 'Activated'
         else 'Lead' end,
    r.top_category, r.categories,
    r.first_seen_at, r.first_registered_at, r.last_active_at,
    r.last_practice_at,
    (current_date - r.last_practice_at::date)::int,
    r.practice_rounds, r.questions_done, r.questions_right
  from _person_rollup() r
  order by r.last_active_at desc nulls last;
end;
$$;

create or replace function get_practice_reminders(days_inactive int default 7)
returns table (
  name text, email text, top_category text,
  last_practice_at timestamptz, days_since_practice int, practice_rounds bigint
)
language plpgsql security definer set search_path = public
as $$
declare admin_emails text[] := array['thvnguyen08@gmail.com', 'futuresteps.dallas@gmail.com'];
begin
  -- coalesce() matters: an anon-key caller has no 'email' claim, so the
  -- comparison is NULL and `if not (NULL)` is falsy in plpgsql -- it would NOT
  -- return early, silently leaking data.
  if not (coalesce(auth.jwt()->>'email', '') = any(admin_emails)) then return; end if;
  return query
  select
    r.name, r.email, r.top_category, r.last_practice_at,
    (current_date - r.last_practice_at::date)::int,
    r.practice_rounds
  from _person_rollup() r
  where r.email is not null
    and r.last_practice_at is not null
    and (current_date - r.last_practice_at::date) >= days_inactive
  order by 5 desc;
end;
$$;

create or replace function get_category_breakdown()
returns table (
  category text, learners bigint, practice_rounds bigint,
  questions_done bigint, questions_right bigint, accuracy_pct numeric
)
language plpgsql security definer set search_path = public
as $$
declare admin_emails text[] := array['thvnguyen08@gmail.com', 'futuresteps.dallas@gmail.com'];
begin
  -- coalesce() matters: an anon-key caller has no 'email' claim, so the
  -- comparison is NULL and `if not (NULL)` is falsy in plpgsql -- it would NOT
  -- return early, silently leaking data.
  if not (coalesce(auth.jwt()->>'email', '') = any(admin_emails)) then return; end if;
  return query
  with ev as (
    select e.anon_id,
           nullif(e.props->>'category', '')        as category,
           coalesce((e.props->>'total')::int, 0)   as total,
           coalesce((e.props->>'correct')::int, 0) as correct
    from events e
    where e.event_name = 'practice_complete'
  )
  select ev.category,
         count(distinct ev.anon_id),
         count(*),
         coalesce(sum(ev.total), 0),
         coalesce(sum(ev.correct), 0),
         round(100.0 * coalesce(sum(ev.correct), 0) / nullif(sum(ev.total), 0), 1)
  from ev
  where ev.category is not null
  group by ev.category
  order by 3 desc;
end;
$$;

create or replace function get_event_feed(p_limit int default 500)
returns table (
  occurred_at timestamptz, name text, email text, property text,
  event_name text, channel text, page_path text, props jsonb
)
language plpgsql security definer set search_path = public
as $$
declare admin_emails text[] := array['thvnguyen08@gmail.com', 'futuresteps.dallas@gmail.com'];
begin
  -- coalesce() matters: an anon-key caller has no 'email' claim, so the
  -- comparison is NULL and `if not (NULL)` is falsy in plpgsql -- it would NOT
  -- return early, silently leaking data.
  if not (coalesce(auth.jwt()->>'email', '') = any(admin_emails)) then return; end if;
  return query
  select
    e.occurred_at, p.name, p.email, e.property, e.event_name,
    analytics_channel(e.utm_source, e.utm_medium, e.referrer),
    e.page_path, e.props
  from events e
  left join person_anon_map m on m.anon_id = e.anon_id
  left join persons p on p.id = m.person_id
  order by e.occurred_at desc
  limit greatest(1, least(p_limit, 5000));
end;
$$;

-- Supabase grants EXECUTE on every new function directly to `anon` and
-- `authenticated` by default (ALTER DEFAULT PRIVILEGES on the public schema) --
-- NOT via the PUBLIC pseudo-role -- so without these explicit revokes, the
-- admin-only functions above (and _person_rollup(), which has no admin check of
-- its own) are callable by anyone holding the public anon key.
revoke execute on function _person_rollup()             from anon, authenticated;
revoke execute on function get_funnel_summary()         from anon;
revoke execute on function get_channel_performance()    from anon;
revoke execute on function get_person_crm()             from anon;
revoke execute on function get_category_breakdown()     from anon;
revoke execute on function get_practice_reminders(int)  from anon;
revoke execute on function get_event_feed(int)          from anon;

grant execute on function get_funnel_summary()      to authenticated;
grant execute on function get_channel_performance() to authenticated;
grant execute on function get_person_crm()          to authenticated;
grant execute on function get_category_breakdown()  to authenticated;
grant execute on function get_practice_reminders(int) to authenticated;
grant execute on function get_event_feed(int)       to authenticated;


-- ####################################$#######################################
-- ## 3. BACKFILL — import existing leads + practice_activity (once)
-- ####################################$#######################################

do $$
begin
  if exists (select 1 from events where (props->>'_backfill') = 'true') then
    raise notice 'Analytics backfill already ran — skipping.';
    return;
  end if;

  insert into anon_visitors (anon_id, first_property, first_seen_at)
  select cid, 'app', min(ts)
  from (
    select client_id as cid, created_at as ts from leads            where client_id is not null
    union all
    select client_id,        created_at        from practice_activity where client_id is not null
  ) s
  group by cid
  on conflict (anon_id) do nothing;

  with lead_person as (
    select distinct on (client_id) client_id, name, email, phone, location
    from leads
    where client_id is not null
      and client_id not in (select anon_id from person_anon_map)
    order by client_id, created_at desc
  ),
  with_ids as (
    select gen_random_uuid() as pid, lp.client_id, lp.name, lp.email, lp.phone, lp.location,
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

  insert into persons (name, email, phone, location, first_registered_at, created_at)
  select distinct on (lower(trim(l.email)))
         nullif(trim(l.name), ''), nullif(lower(trim(l.email)), ''),
         nullif(trim(l.phone), ''), nullif(trim(l.location), ''),
         l.created_at, l.created_at
  from leads l
  where l.client_id is null
    and nullif(lower(trim(l.email)), '') is not null
    and not exists (select 1 from persons p where lower(p.email) = lower(trim(l.email)))
  order by lower(trim(l.email)), l.created_at asc;

  insert into events (anon_id, property, event_name, occurred_at, props)
  select client_id, 'app', 'register', created_at, jsonb_build_object('_backfill', true)
  from leads where client_id is not null;

  insert into events (anon_id, property, event_name, occurred_at, props)
  select client_id, 'app',
    case when activity_type = 'practice' then 'practice_complete' else 'view' end,
    created_at,
    jsonb_strip_nulls(jsonb_build_object(
      'category', category, 'mode', mode, 'content_type', content_type,
      'correct', correct, 'total', total, '_backfill', true))
  from practice_activity where client_id is not null;

  raise notice 'Analytics backfill complete.';
end;
$$;


-- ############################################################################
-- ## DONE. Verify with:
-- ##   select * from get_funnel_summary();
-- ##   select * from get_channel_performance();
-- ## (must be signed in as an admin email for these to return rows)
-- ############################################################################
