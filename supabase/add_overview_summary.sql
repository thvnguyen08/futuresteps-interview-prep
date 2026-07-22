-- ============================================================================
-- Migration: OVERVIEW SUMMARY (admin dashboard "what changed" strip)
-- Run this once in the Supabase SQL editor (Project → SQL Editor → New query).
-- ============================================================================
--
-- Backs the Overview tiles at the top of admin.html with EXACT period totals
-- for the current window and the equal-length window before it.
--
-- Why this is a new function rather than more columns on get_activity_rollup:
--
--   1. Two of these numbers cannot be computed from daily rows at all.
--      `learners` is a distinct device count, so summing it across days
--      double-counts anyone who practised on more than one day -- the same
--      non-additivity that forced get_activity_rollup's four grouping sets.
--      Postgres has to do the period-level distinct count itself.
--
--   2. Accuracy needs sum(total) as its denominator, and the rollup does not
--      expose it -- its `questions` column is coalesce(total, reviewed, 0), so
--      it mixes scored answers with unscored reviews (flashcards, self-scored
--      modes). Dividing by that understates every self-scored mode. This
--      function returns `scored` (= sum(total)) as its own column so the
--      denominator is never ambiguous.
--
--   3. get_activity_rollup's RETURNS TABLE cannot gain a column under
--      `create or replace` -- it would need a drop + recreate, and until the
--      drop ran, prod would keep serving the old shape to new client code.
--      Adding a separate function keeps both deploy orders safe.
--
-- Before this existed, admin.html approximated the comparison by fetching 2x
-- the window from get_activity_rollup and splitting it client-side. That gave
-- correct ADDITIVE totals (rounds, questions, views) but could only report
-- learners as a daily average, and could not report accuracy at all.
--
-- The client still fetches 2x the window from the rollup, deliberately: it needs
-- the current half for the sparkline shapes, and keeping the older half means
-- that if this migration has NOT been run yet, admin.html falls back to the old
-- client-side split and the Overview keeps working (minus accuracy, with
-- learners shown as a daily average) instead of rendering an error. Once this
-- function exists it supersedes those numbers.
--
-- Security mirrors add_activity_rollup.sql: SECURITY DEFINER + the same admin
-- allowlist, and the same internal-email exclusions so our own testing does not
-- inflate the numbers.
-- ⚠  Keep both lists in sync with add_activity_rollup.sql / add_leads.sql.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- get_overview_summary(p_days) — exactly two rows, 'current' and 'previous'.
--
-- Windows are CALENDAR DAYS in America/Chicago, matching how every other panel
-- buckets days (get_activity_rollup, get_practice_report):
--
--   current  = [today - (p_days - 1)      .. today]
--   previous = [today - (2*p_days - 1)    .. today - p_days]
--
-- Equal length, non-overlapping, adjacent. Note this is calendar-day aligned
-- rather than the rolling `now() - interval` cut the rollup uses for its own
-- filter -- a period comparison has to sit on day boundaries or "the 30 days
-- before" would start mid-day and silently borrow part of a day from the
-- current window.
--
-- A period with no activity still returns its row, with zeros and a NULL
-- accuracy -- the caller needs the row to render "no change" rather than
-- guessing whether the period was empty or the query failed.
-- ----------------------------------------------------------------------------
create or replace function get_overview_summary(p_days int default 30)
returns table (
  period          text,      -- 'current' | 'previous'
  day_from        date,
  day_to          date,
  practice_rounds bigint,    -- activity_type = 'practice'
  view_events     bigint,    -- activity_type = 'view'
  questions       bigint,    -- scored answers + unscored reviews (seen)
  scored          bigint,    -- sum(total) only -- the accuracy denominator
  correct         bigint,
  accuracy_pct    numeric,   -- NULL when nothing scored, never 0
  learners        bigint,    -- DISTINCT devices across the whole period
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
  -- return early, silently leaking data. Coalescing to '' makes it compare false
  -- against every admin email instead.
  if not (coalesce(auth.jwt()->>'email', '') = any(admin_emails)) then return; end if;

  -- Clamp: the scan covers 2x this, so 365 here means at most ~2 years of rows.
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
      a.correct
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
    count(*) filter (where r.activity_type = 'practice'),
    count(*) filter (where r.activity_type = 'view'),
    coalesce(sum(coalesce(r.total, r.reviewed, 0)), 0),
    coalesce(sum(coalesce(r.total, 0)), 0),
    coalesce(sum(coalesce(r.correct, 0)), 0),
    -- Divides by sum(total), NOT by the questions column above.
    case
      when coalesce(sum(r.total), 0) > 0
      then round(100.0 * sum(coalesce(r.correct, 0)) / sum(r.total), 1)
      else null
    end,
    -- The whole point of this function: a period-level distinct count, which
    -- no amount of client-side summing over daily rows can reproduce.
    count(distinct r.client_id),
    count(distinct r.d) filter (where r.activity_type = 'practice')
  from bounds b
  -- LEFT JOIN so an empty period still returns its row (zeros, NULL accuracy)
  -- instead of vanishing and leaving the caller to infer why.
  left join rows_in_window r
    on r.d between b.d_from and b.d_to
  group by b.period, b.d_from, b.d_to;
end;
$$;

-- Same posture as the other admin readers: admins only, never the anon key.
revoke execute on function get_overview_summary(int) from public, anon;
grant  execute on function get_overview_summary(int) to authenticated;
