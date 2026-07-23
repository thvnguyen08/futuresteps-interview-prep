-- ============================================================================
-- Migration: ALIGN THE ADMIN OVERVIEW WITH THE FUTURESTEPS DASHBOARD
-- Run once in the Supabase SQL editor. Safe to re-run (idempotent).
-- Run supabase/fix_person_rollup_cast.sql as well — different bug, same page.
-- ============================================================================
--
-- The admin page and futuresteps-dashboard.pages.dev showed tiles with the SAME
-- LABELS and different definitions. Two of them were simply wrong here, and
-- both inflated the numbers:
--
--   "Learners"        counted DISTINCT devices across every row in the window,
--                     including activity_type='view'. Someone who opened a
--                     service screen and left counted as a learner. The
--                     dashboard counts only devices that actually practised;
--                     the same mistake there once read 216 learners against 39
--                     rounds (see practiceTotals() in scripts/snapshot.mjs).
--
--   "Practice rounds" counted every activity_type='practice' row, including
--                     Green Flags, Red Flags and Document Checklists. Those are
--                     reading, not practice — get_practice_report() has always
--                     excluded them and its own header puts them at ~1/3 of all
--                     rounds, so the Overview strip disagreed with the Daily
--                     practice table directly beneath it. Questions seen and
--                     Accuracy inherited the same inflation.
--
-- This file makes both functions count a practice round the way
-- get_practice_report() and the dashboard's practiceBuckets() already do:
--
--   activity_type = 'practice'
--   AND content_type = 'question'          (NULL = legacy, treated as question)
--   AND (mode = 'mock' OR category is one we have a service column for)
--
-- The last clause is what practiceBuckets() expresses as "t1 is not null": a
-- round in an unrecognised category has no column to land in on either
-- dashboard, so counting it in the total made the total unreconcilable with the
-- table below it. Views are NOT filtered — a view is a view whatever was on
-- screen, which is also how the dashboard counts them.
--
-- ⚠ THIS RULE NOW LIVES IN FOUR PLACES. Adding a service or a mode means
--   touching all four, or the two dashboards drift apart again:
--     supabase/add_practice_report.sql        get_practice_report()  CASE arms
--     supabase/align_admin_to_dashboard.sql   this file
--     futuresteps-dashboard/scripts/snapshot.mjs        practiceBuckets()
--     futuresteps-dashboard/dashboard-query.sql         the documented SQL
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Shared predicate, so the two readers below cannot drift from each other.
-- Immutable: depends only on its arguments, so it inlines and indexes normally.
-- ----------------------------------------------------------------------------
create or replace function _is_practice_round(
  activity_type text, mode text, category text, content_type text
) returns boolean
language sql
immutable
as $$
  select activity_type = 'practice'
     -- Legacy rows predate the column; they are all real questions.
     and coalesce(content_type, 'question') = 'question'
     and (
       coalesce(mode, 'practice') = 'mock'
       or coalesce(category, 'unknown') in (
         'naturalization', 'marriage', 'f1', 'b1b2', 'asylum',
         'eng_speaking', 'eng_reading', 'eng_writing'
       )
     );
$$;

-- ----------------------------------------------------------------------------
-- 1. get_overview_summary(p_days) — the Overview strip.
-- Gains a `viewers` column (distinct devices that opened a service screen), so
-- the Service views tile can carry the same footnote as the dashboard's.
-- Adding a column changes the return type, which CREATE OR REPLACE cannot do.
-- ----------------------------------------------------------------------------
drop function if exists get_overview_summary(int);

create or replace function get_overview_summary(p_days int default 30)
returns table (
  period          text,      -- 'current' | 'previous'
  day_from        date,
  day_to          date,
  practice_rounds bigint,    -- real practice rounds — see the header
  view_events     bigint,    -- activity_type = 'view', unfiltered
  questions       bigint,    -- scored answers + unscored reviews (seen)
  scored          bigint,    -- sum(total) only -- the accuracy denominator
  correct         bigint,
  accuracy_pct    numeric,   -- NULL when nothing scored, never 0
  learners        bigint,    -- DISTINCT devices that PRACTISED in the period
  viewers         bigint,    -- DISTINCT devices that opened a service screen
  active_days     bigint     -- days with at least one practice round
)
language plpgsql
security definer
set search_path = public
as $$
declare
  admin_emails text[] := array[
    'thvnguyen08@gmail.com',
    'futuresteps.dallas@gmail.com'
  ];
  excluded_emails text[] := array[
    'thvnguyen08@gmail.com',
    'thang.nguyen.cv@gmail.com',
    'victor.nghv@gmail.com',
    'ngat87143@gmail.com',
    'futuresteps.dallas@gmail.com'
  ];
  window_days int;
  today_chi   date;
begin
  -- coalesce() matters: an anon-key caller has no 'email' claim at all, so the
  -- comparison is NULL and `if not (NULL)` is falsy in plpgsql -- it would NOT
  -- return early, silently leaking data.
  if not (coalesce(auth.jwt()->>'email', '') = any(admin_emails)) then return; end if;

  window_days := least(greatest(coalesce(p_days, 30), 1), 365);
  today_chi   := (now() at time zone 'America/Chicago')::date;

  return query
  with bounds as (
    select
      'current'::text as period,
      today_chi - (window_days - 1)     as d_from,
      today_chi                         as d_to
    union all
    select
      'previous'::text,
      today_chi - (2 * window_days - 1),
      today_chi - window_days
  ),
  rows_in_window as (
    select
      (a.created_at at time zone 'America/Chicago')::date as d,
      a.activity_type,
      a.client_id,
      a.total,
      a.reviewed,
      a.correct,
      -- Tag once; every aggregate below reads the tag rather than repeating the
      -- rule, so "round" means exactly one thing in this function.
      _is_practice_round(a.activity_type, a.mode, a.category, a.content_type) as is_round
    from practice_activity a
    where (a.created_at at time zone 'America/Chicago')::date
            >= today_chi - (2 * window_days - 1)
      and (a.created_at at time zone 'America/Chicago')::date <= today_chi
      and (a.email is null or lower(a.email) <> all(excluded_emails))
      and not exists (
        select 1 from leads l
        where l.client_id = a.client_id
          and lower(l.email) = any(excluded_emails)
      )
  )
  select
    b.period,
    b.d_from,
    b.d_to,
    -- count(*) filter, not sum() -- one row in practice_activity is one round.
    count(*) filter (where r.is_round),
    count(*) filter (where r.activity_type = 'view'),
    -- Questions / scored / correct now come off practice rounds only. Reading
    -- rows carry no total anyway, but stating the filter keeps the accuracy
    -- denominator honest if a checklist ever starts scoring itself.
    coalesce(sum(coalesce(r.total, r.reviewed, 0)) filter (where r.is_round), 0),
    coalesce(sum(coalesce(r.total, 0))            filter (where r.is_round), 0),
    coalesce(sum(coalesce(r.correct, 0))          filter (where r.is_round), 0),
    case
      when coalesce(sum(r.total) filter (where r.is_round), 0) > 0
      then round(100.0 * sum(coalesce(r.correct, 0)) filter (where r.is_round)
                       / sum(r.total) filter (where r.is_round), 1)
      else null
    end,
    -- A learner practised. A viewer opened a screen. Keeping them apart is the
    -- whole point of this migration.
    count(distinct r.client_id) filter (where r.is_round),
    count(distinct r.client_id) filter (where r.activity_type = 'view'),
    count(distinct r.d)         filter (where r.is_round)
  from bounds b
  -- LEFT JOIN so an empty period still returns its row (zeros, NULL accuracy)
  -- instead of vanishing and leaving the caller to infer why.
  left join rows_in_window r
    on r.d between b.d_from and b.d_to
  group by b.period, b.d_from, b.d_to;
end;
$$;

-- ----------------------------------------------------------------------------
-- 2. get_activity_rollup(p_days) — the Daily activity chart and sparklines.
-- Same shape as before (CREATE OR REPLACE is enough). Two changes:
--
--   a. 'practice' rows are now real practice rounds, so the chart's Practised
--      line no longer sits above the dashboard's for the same day and data.
--   b. the window is N CALENDAR DAYS in America/Chicago, not a rolling
--      `now() - interval N days`. The rolling cut started mid-day, so the
--      oldest day came back partial — and admin.html fills its x-axis with N
--      whole local days, so that partial day was silently plotted as if it
--      were a full one, and the tiles (calendar-day) could not be reconciled
--      with the chart (rolling) even in principle.
-- ----------------------------------------------------------------------------
create or replace function get_activity_rollup(p_days int default 30)
returns table (
  day           date,
  activity_type text,     -- NULL = all actions
  category      text,     -- NULL = all services
  events        bigint,
  learners      bigint,   -- distinct devices, so one person practicing 5x counts once
  questions     bigint,
  correct       bigint,
  accuracy_pct  numeric
)
language plpgsql
security definer
set search_path = public
as $$
declare
  admin_emails text[] := array[
    'thvnguyen08@gmail.com',
    'futuresteps.dallas@gmail.com'
  ];
  excluded_emails text[] := array[
    'thvnguyen08@gmail.com',
    'thang.nguyen.cv@gmail.com',
    'victor.nghv@gmail.com',
    'ngat87143@gmail.com',
    'futuresteps.dallas@gmail.com'
  ];
  window_days int;
  today_chi   date;
begin
  if not (coalesce(auth.jwt()->>'email', '') = any(admin_emails)) then return; end if;

  window_days := least(greatest(coalesce(p_days, 30), 1), 365);
  today_chi   := (now() at time zone 'America/Chicago')::date;

  return query
  with rows_in_window as (
    select
      (a.created_at at time zone 'America/Chicago')::date as d,
      a.activity_type                as action,
      coalesce(a.category, 'unknown') as svc,
      a.client_id,
      a.total,
      a.reviewed,
      a.correct
    from practice_activity a
    where (a.created_at at time zone 'America/Chicago')::date
            >= today_chi - (window_days - 1)
      and (a.created_at at time zone 'America/Chicago')::date <= today_chi
      -- Reading material and unbucketable categories are not practice rounds.
      -- Views pass through untouched.
      and (a.activity_type = 'view'
           or _is_practice_round(a.activity_type, a.mode, a.category, a.content_type))
      and (a.email is null or lower(a.email) <> all(excluded_emails))
      and not exists (
        select 1 from leads l
        where l.client_id = a.client_id
          and lower(l.email) = any(excluded_emails)
      )
  )
  select
    r.d,
    r.action,
    r.svc,
    count(*),
    count(distinct r.client_id),
    coalesce(sum(coalesce(r.total, r.reviewed, 0)), 0),
    coalesce(sum(coalesce(r.correct, 0)), 0),
    case
      when coalesce(sum(r.total), 0) > 0
      then round(100.0 * sum(coalesce(r.correct, 0)) / sum(r.total), 1)
      else null
    end
  from rows_in_window r
  group by grouping sets (
    (r.d, r.action, r.svc),
    (r.d, r.action),
    (r.d, r.svc),
    (r.d)
  )
  order by r.d desc, r.action nulls first, r.svc nulls first;
end;
$$;

-- ----------------------------------------------------------------------------
-- 3. get_practice_report(p_days) — the Daily practice / Naturalization tables.
-- The bucket CASE arms are UNCHANGED (they were already right, and they are
-- what the dashboard's practiceBuckets() was ported from). Only the window
-- moves, for the same reason as the rollup above: all three admin readers now
-- cover the same N calendar days, so the strip, the chart and the tables can
-- finally be added up against each other.
-- ----------------------------------------------------------------------------
create or replace function get_practice_report(p_days int default 30)
returns table (
  day    date,
  bucket text,
  rounds bigint,
  people bigint
)
language plpgsql
security definer
set search_path = public
as $$
declare
  admin_emails text[] := array[
    'thvnguyen08@gmail.com',
    'futuresteps.dallas@gmail.com'
  ];
  excluded_emails text[] := array[
    'thvnguyen08@gmail.com',
    'thang.nguyen.cv@gmail.com',
    'victor.nghv@gmail.com',
    'ngat87143@gmail.com',
    'futuresteps.dallas@gmail.com'
  ];
  window_days int;
  today_chi   date;
begin
  if not (coalesce(auth.jwt()->>'email', '') = any(admin_emails)) then return; end if;

  window_days := least(greatest(coalesce(p_days, 30), 1), 365);
  today_chi   := (now() at time zone 'America/Chicago')::date;

  return query
  with base as (
    select
      (a.created_at at time zone 'America/Chicago')::date as d,
      a.client_id,
      coalesce(a.mode, 'practice')         as m,
      coalesce(a.category, 'unknown')      as cat,
      coalesce(a.content_type, 'question') as ct
    from practice_activity a
    where a.activity_type = 'practice'
      and (a.created_at at time zone 'America/Chicago')::date
            >= today_chi - (window_days - 1)
      and (a.created_at at time zone 'America/Chicago')::date <= today_chi
      and (a.email is null or lower(a.email) <> all(excluded_emails))
      and not exists (
        select 1 from leads l
        where l.client_id = a.client_id
          and lower(l.email) = any(excluded_emails)
      )
  ),
  kept as (
    -- Reading material (flags, checklists) is not practice.
    select * from base where ct = 'question'
  ),
  tagged as (
    select
      k.d,
      k.client_id,
      case
        when k.m = 'mock' and k.cat in ('marriage', 'f1', 'b1b2', 'asylum') then 'm_' || k.cat
        when k.m = 'mock' then 'm_naturalization'
        when k.cat in ('marriage', 'f1', 'b1b2', 'asylum') then 'p_' || k.cat
        when k.cat in ('naturalization', 'eng_speaking', 'eng_reading', 'eng_writing')
          then 'p_naturalization'
        else null
      end as t1,
      case
        -- Mock lives in Table 1 only; it is not one of the civics/English tests.
        when k.m = 'mock' then null
        -- 'simulate' is the legacy value covering BOTH civics tests.
        when k.m in ('mctest', 'simulate') and k.cat = 'naturalization' then 'n_civicstest'
        when k.m = 'spoken' then 'n_spoken'
        when k.m = 'review' and k.cat = 'naturalization' then 'n_review'
        when k.cat = 'eng_reading' then 'n_reading'
        when k.cat = 'eng_writing' then 'n_writing'
        when k.cat = 'eng_speaking' then 'n_speaking'
        -- Whatever naturalization practice is left is the 128-civics flashcards.
        when k.cat = 'naturalization' then 'n_civics128'
        else null
      end as t2
    from kept k
  )
  select t.d, t.t1, count(*), count(distinct t.client_id)
    from tagged t where t.t1 is not null group by t.d, t.t1
  union all
  select t.d, t.t2, count(*), count(distinct t.client_id)
    from tagged t where t.t2 is not null group by t.d, t.t2
  union all
  select t.d, '__all', count(*), count(distinct t.client_id)
    from tagged t where t.t1 is not null group by t.d
  union all
  select t.d, '__nat', count(*), count(distinct t.client_id)
    from tagged t where t.t2 is not null group by t.d
  order by 1 desc, 2;
end;
$$;

-- Same posture as every other admin reader: admins only, never the anon key.
revoke execute on function _is_practice_round(text, text, text, text) from public, anon;
revoke execute on function get_overview_summary(int) from public, anon;
revoke execute on function get_activity_rollup(int)  from public, anon;
revoke execute on function get_practice_report(int)  from public, anon;
grant  execute on function get_overview_summary(int) to authenticated;
grant  execute on function get_activity_rollup(int)  to authenticated;
grant  execute on function get_practice_report(int)  to authenticated;

-- ----------------------------------------------------------------------------
-- Verify (as an admin). The first query is the size of the correction: how many
-- rows the Overview used to count as practice and no longer does.
--
--   select coalesce(content_type, 'question') as content_type,
--          coalesce(category, 'unknown')      as category,
--          count(*)
--   from practice_activity
--   where activity_type = 'practice'
--     and not _is_practice_round(activity_type, mode, category, content_type)
--   group by 1, 2 order by 3 desc;
--
-- And the reconciliation that was previously impossible — the Overview's
-- practice_rounds should now equal the '__all' rounds in get_practice_report()
-- over the same window:
--
--   select (select practice_rounds from get_overview_summary(30) where period = 'current') as overview,
--          (select sum(rounds) from get_practice_report(30) where bucket = '__all')        as report;
-- ----------------------------------------------------------------------------
