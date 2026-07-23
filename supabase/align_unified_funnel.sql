-- ============================================================================
-- Migration: UNIFIED FUNNEL = THE DASHBOARD'S KPI ROW
-- Run once in the Supabase SQL editor. Safe to re-run (idempotent).
-- Run AFTER fix_person_rollup_cast.sql (this file carries its guard forward).
-- ============================================================================
--
-- The admin page's Unified Funnel and futuresteps-dashboard's Overview KPI row
-- answer the same question with different arithmetic. This makes the admin side
-- match, metric for metric:
--
--   Unique visitors · Signups · Contact capture · Activation · Active within 7d
--
-- FOUR CORRECTIONS, all of which moved a number:
--
--   visitors    counted every row in anon_visitors, our own phones included.
--               Every other stage already excluded internal accounts, so the
--               top of the funnel was measured against a different population
--               than the rest of it.
--
--   signups     counted every person in the rollup, including those with no
--               first_registered_at at all. A person who was never registered
--               is not a signup.
--
--   activation  divided by ALL leads. Two cohorts in that denominator could not
--               possibly have activated: people who signed up before practice
--               shipped on 2026-07-17 (it did not exist yet), and people who
--               signed up in the last few hours (activation here is a day-0
--               phenomenon 100% of the time -- the signup→first-practice lag
--               histogram is {0: 39}, nobody has EVER come back on a later day
--               to practise for the first time). Counting either is counting a
--               failure that was never offered. This is the correction that
--               produced the dashboard's honest 8.6% in place of a number that
--               was mostly measuring the calendar.
--
--   contact     did not exist here at all. The one-tap front door means most
--               signups never hand over contact details, so "how many can we
--               actually reach" is a separate question from "how many signed
--               up" -- and it is the one that decides whether the reminder
--               emails have anyone to go to.
--
-- Also: is_active now compares calendar days in America/Chicago rather than the
-- session timezone (UTC), matching every other reader and the dashboard. A
-- signup at 8pm CT who returned at 1am CT was being counted as a next-day
-- return because UTC had already rolled over.
--
-- ⚠ The three constants below are FACTS ABOUT THIS DATASET, not about the
--   metric, and they are duplicated in futuresteps-dashboard/scripts/snapshot.mjs
--   (PRACTICE_LAUNCH_DATE / ACTIVATION_MIN_AGE_DAYS / ACTIVE_WINDOW_DAYS).
--   Change one, change both, or the two dashboards diverge again. When the
--   pre-launch cohort ages out (~Aug 2026) the launch filter can be dropped.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Is this device one of ours? A device is internal if it belongs to a person
-- with an internal email, or to a lead with one. Both paths matter: a teammate
-- who registered shows up under persons, a teammate who only left an email at
-- the front door shows up under leads.
-- ----------------------------------------------------------------------------
create or replace function _is_internal_anon(p_anon text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from person_anon_map m
    join persons p on p.id = m.person_id
    where m.anon_id = p_anon
      and lower(p.email) = any(array[
        'thvnguyen08@gmail.com','thang.nguyen.cv@gmail.com','victor.nghv@gmail.com',
        'ngat87143@gmail.com','futuresteps.dallas@gmail.com'])
  ) or exists (
    select 1 from leads l
    where l.client_id = p_anon
      and lower(l.email) = any(array[
        'thvnguyen08@gmail.com','thang.nguyen.cv@gmail.com','victor.nghv@gmail.com',
        'ngat87143@gmail.com','futuresteps.dallas@gmail.com'])
  );
$$;

-- ----------------------------------------------------------------------------
-- _person_rollup() — unchanged signature, two changes in the body:
--   * the _event_int() guard from fix_person_rollup_cast.sql, carried forward
--     (do NOT drop it -- question_answered writes `correct` as a boolean and an
--     unguarded cast takes the whole funnel down)
--   * is_active compares America/Chicago calendar days, not session-timezone
--     ones
-- ----------------------------------------------------------------------------
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
  with excluded_emails as (
    select unnest(array[
      'thvnguyen08@gmail.com',
      'thang.nguyen.cv@gmail.com',
      'victor.nghv@gmail.com',
      'ngat87143@gmail.com',
      'futuresteps.dallas@gmail.com'
    ]) as email
  ),
  anon_of_person as (
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
      ap.person_id,
      e.event_name,
      e.occurred_at,
      nullif(e.props->>'category', '') as category,
      coalesce(_event_int(e.props, e.event_name, 'practice_complete', 'total'), 0)   as total,
      coalesce(_event_int(e.props, e.event_name, 'practice_complete', 'correct'), 0) as correct
    from anon_of_person ap
    join events e on e.anon_id = ap.anon_id
  ),
  agg as (
    select
      ev.person_id,
      max(ev.occurred_at) as last_active_at,
      max(ev.occurred_at) filter (where ev.event_name = 'practice_complete') as last_practice_at,
      count(*) filter (where ev.event_name = 'practice_complete')  as practice_rounds,
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
    fa.first_seen_at,
    p.first_registered_at,
    a.last_active_at,
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
        -- Chicago calendar days on BOTH sides. Bare ::date would use the
        -- session timezone (UTC on Supabase), which rolls over at 7pm CT and
        -- turned a same-evening return into a next-day one.
        and (ev.occurred_at          at time zone 'America/Chicago')::date
          > (p.first_registered_at   at time zone 'America/Chicago')::date
        and ev.occurred_at <= p.first_registered_at + interval '7 days'
    )
  from persons p
  left join first_anon fa on fa.person_id = p.id
  left join agg a       on a.person_id = p.id
  left join top_cat tc  on tc.person_id = p.id
  left join cat_json cj on cj.person_id = p.id
  where p.email is null or lower(p.email) not in (select email from excluded_emails);
$$;

-- ----------------------------------------------------------------------------
-- get_funnel_summary() — the five metrics, in the dashboard's order.
-- The config values ride along so admin.html can print the same footnotes
-- instead of hardcoding a date that would silently rot.
-- ----------------------------------------------------------------------------
drop function if exists get_funnel_summary();

create or replace function get_funnel_summary()
returns table (
  visitors                bigint,
  signups                 bigint,
  identified              bigint,
  identified_pct          numeric,
  activation_eligible     bigint,
  activation_activated    bigint,
  activation_rate_pct     numeric,
  active_7d               bigint,
  active_7d_pct           numeric,
  practice_launch_date    date,
  activation_min_age_days int,
  active_window_days      int
)
language plpgsql
security definer
set search_path = public
as $$
declare
  admin_emails text[] := array['thvnguyen08@gmail.com', 'futuresteps.dallas@gmail.com'];
  -- See the header: facts about this dataset, mirrored in snapshot.mjs.
  launch_at    timestamptz := timestamptz '2026-07-17 00:00:00+00';
  min_age_days int := 1;
  active_days  int := 7;
begin
  if not (coalesce(auth.jwt()->>'email', '') = any(admin_emails)) then return; end if;

  return query
  with people as (
    -- Signups only: a person with no registration timestamp never signed up.
    select * from _person_rollup() r where r.first_registered_at is not null
  ),
  eligible as (
    select *
    from people p
    where p.first_registered_at >= launch_at                                  -- practice existed
      and p.first_registered_at <= now() - make_interval(days => min_age_days) -- had its chance
  )
  select
    (select count(*) from anon_visitors v where not _is_internal_anon(v.anon_id))::bigint,
    (select count(*) from people)::bigint,
    -- Contactable: any of the three, matching the dashboard's isIdentified.
    (select count(*) from people p where p.name is not null or p.email is not null or p.phone is not null)::bigint,
    coalesce(round(100.0 * (select count(*) from people p
                             where p.name is not null or p.email is not null or p.phone is not null)
                 / nullif((select count(*) from people), 0), 1), 0),
    (select count(*) from eligible)::bigint,
    (select count(*) from eligible e where e.is_activated)::bigint,
    coalesce(round(100.0 * (select count(*) from eligible e where e.is_activated)
                 / nullif((select count(*) from eligible), 0), 1), 0),
    (select count(*) from people p where p.is_active)::bigint,
    coalesce(round(100.0 * (select count(*) from people p where p.is_active)
                 / nullif((select count(*) from people), 0), 1), 0),
    launch_at::date,
    min_age_days,
    active_days;
end;
$$;

-- ----------------------------------------------------------------------------
-- get_channel_performance() — same two population fixes, so the channel table's
-- visitor column adds up to the funnel's visitor tile. They sat on one page
-- disagreeing with each other.
-- ----------------------------------------------------------------------------
create or replace function get_channel_performance()
returns table (
  channel   text,
  visitors  bigint,
  leads     bigint,
  activated bigint,
  active    bigint
)
language plpgsql
security definer
set search_path = public
as $$
declare
  admin_emails text[] := array['thvnguyen08@gmail.com', 'futuresteps.dallas@gmail.com'];
begin
  if not (coalesce(auth.jwt()->>'email', '') = any(admin_emails)) then return; end if;

  return query
  with visitor_channel as (
    select analytics_channel(first_utm_source, first_utm_medium, first_referrer) as channel,
           count(*) as visitors
    from anon_visitors v
    where not _is_internal_anon(v.anon_id)
    group by 1
  ),
  person_channel as (
    select r.channel,
           count(*)                              as leads,
           count(*) filter (where r.is_activated) as activated,
           count(*) filter (where r.is_active)    as active
    from _person_rollup() r
    where r.first_registered_at is not null
    group by 1
  )
  select
    coalesce(vc.channel, pc.channel),
    coalesce(vc.visitors, 0),
    coalesce(pc.leads, 0),
    coalesce(pc.activated, 0),
    coalesce(pc.active, 0)
  from visitor_channel vc
  full outer join person_channel pc on pc.channel = vc.channel
  order by active desc, visitors desc;
end;
$$;

-- Same posture as every other reader: admins only, never the anon key.
revoke execute on function _is_internal_anon(text)      from public, anon;
revoke execute on function _person_rollup()             from public, anon, authenticated;
revoke execute on function get_funnel_summary()         from public, anon;
revoke execute on function get_channel_performance()    from public, anon;
grant  execute on function get_funnel_summary()         to authenticated;
grant  execute on function get_channel_performance()    to authenticated;

-- PostgREST caches the schema, and get_funnel_summary's return type changed.
-- Without this the API answers PGRST202 and admin.html quietly shows the old
-- shape instead of the new one.
notify pgrst, 'reload schema';

-- ----------------------------------------------------------------------------
-- Verify. These should match futuresteps-dashboard's Overview tiles exactly
-- (its "All time" range; the dashboard snapshot may be a few hours behind):
--
--   select * from get_funnel_summary();
--
-- and the channel table's visitors should now sum to the funnel's visitors:
--
--   select (select sum(visitors) from get_channel_performance()) as channel_sum,
--          (select visitors from get_funnel_summary())           as funnel_total;
-- ----------------------------------------------------------------------------
