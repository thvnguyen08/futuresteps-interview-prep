-- ============================================================================
-- Migration: PRACTICE ACTIVITY ROLLUP (admin dashboard)
-- Run this once in the Supabase SQL editor (Project → SQL Editor → New query).
-- ============================================================================
--
-- Replaces the admin dashboard's row-per-event Practice Activity table with a
-- daily rollup grouped by day × action × service.
--
-- Two reasons this is a rollup and not a filter over get_activity_data():
--   1. The detail table sent every learner's name + email to the browser to
--      render a list nobody read row-by-row. The rollup answers the actual
--      question ("what got practiced, when") without shipping any PII.
--   2. It stays cheap as practice_activity grows — the aggregate happens in
--      Postgres over an indexed date range, not over the full table in JS.
--
-- get_activity_data() is intentionally LEFT IN PLACE but is no longer called by
-- admin.html (the CSV export now exports this rollup too). It stays because it
-- is the only per-person view if we ever need to debug one learner's history --
-- drop it only if you're sure nothing else calls it.
--
-- Security mirrors add_practice_tracking.sql: SECURITY DEFINER + the same admin
-- allowlist, and the same internal-email exclusions so our own testing does not
-- inflate the numbers.
-- ⚠  Keep both lists in sync with add_practice_tracking.sql / add_leads.sql.
-- ============================================================================

-- The rollup always filters by created_at >= now() - interval, so a plain
-- descending date index already serves it (practice_activity_created_idx from
-- add_practice_tracking.sql). No new index needed.

-- ----------------------------------------------------------------------------
-- get_activity_rollup(p_days) — pre-aggregated at FOUR levels via grouping sets:
--
--   (day, action, service)   both filters set
--   (day, action)            service = All
--   (day, service)           action  = All
--   (day)                    both    = All
--
-- A NULL activity_type/category marks an "all" row. (Real NULL categories are
-- coalesced to 'unknown' first, so NULL is unambiguous.)
--
-- Why all four instead of letting the client sum the detail rows: `learners` is
-- a DISTINCT device count and therefore NOT additive. One person who practices
-- naturalization and marriage on the same day is 1 learner for that day but
-- appears in two detail rows -- summing them would double-count. Postgres has
-- to compute each level's distinct count itself. events/questions/correct are
-- additive and would have been fine either way.
--
-- Days with no activity are simply absent; the client fills the gaps so the
-- chart's x-axis stays continuous (a missing day is zero, not a skipped point).
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
begin
  -- coalesce() matters: an anon-key caller has no 'email' claim at all, so the
  -- comparison is NULL and `if not (NULL)` is falsy in plpgsql -- it would NOT
  -- return early, silently leaking data. Coalescing to '' makes it compare false
  -- against every admin email instead.
  if not (coalesce(auth.jwt()->>'email', '') = any(admin_emails)) then return; end if;

  -- Clamp: a caller-supplied huge/negative window shouldn't scan the table.
  window_days := least(greatest(coalesce(p_days, 30), 1), 365);

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
    where a.created_at >= now() - make_interval(days => window_days)
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
    -- `total` is the scored-question count; `reviewed` covers rounds that were
    -- seen but not scored (flashcards, self-scored modes). Prefer total, fall
    -- back to reviewed, so "Questions" means "questions actually seen".
    coalesce(sum(coalesce(r.total, r.reviewed, 0)), 0),
    coalesce(sum(coalesce(r.correct, 0)), 0),
    -- Accuracy only means anything over scored rounds, so it divides by
    -- sum(total) -- NOT the questions column above, which mixes in unscored
    -- reviews and would understate every self-scored mode.
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

-- Same posture as the other admin readers: admins only, never the anon key.
revoke execute on function get_activity_rollup(int) from public, anon;
grant  execute on function get_activity_rollup(int) to authenticated;
