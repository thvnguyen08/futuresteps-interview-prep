-- ============================================================================
-- Migration: PRACTICE OUTCOMES (admin Overview strip)
-- Run once in the Supabase SQL editor. Safe to re-run (idempotent).
-- Run AFTER align_unified_funnel.sql (this uses _is_internal_anon from it).
-- ============================================================================
--
-- Gives the admin page the same practice metrics as futuresteps-dashboard's
-- Overview tab: started → completed → quit → returned. A SQL port of
-- practiceFunnel()'s outcome split in futuresteps-dashboard/scripts/snapshot.mjs.
-- ⚠ The two must move together or the surfaces drift.
--
-- WHY A NEW READER. get_overview_summary() reads practice_activity, which has
-- no notion of a start: its rows are written in onRoundComplete() only. That is
-- why the "Learners" tile has always meant FINISHERS and why nobody who began a
-- round and quit was visible anywhere on the admin page. Starts and abandons
-- live in `events`, so this reads there instead.
--
-- THE CLAMP. practice_start and practice_abandon both shipped 2026-07-21
-- 15:48Z. Every window here is floored at that instant, so the 14/30/90-day
-- buttons will all return the same numbers until 90 days have passed — the
-- rates would otherwise measure when logging shipped rather than what customers
-- did. window_start is returned so the page can say so out loud.
--
-- THREE BUCKETS, NOT TWO. "Quit" is not 100 - "completed". A round can end with
-- no outcome event at all: the page-exit path logs a drop-off snapshot but
-- deliberately leaves the round OPEN (backgrounding a phone mid-round is not
-- abandonment), and a device practising right now has a start and nothing else.
-- Folding that residual into "quit" would report an instrumentation gap as a
-- user behaviour. The three sum to `starters`; the residual is surfaced.
-- ============================================================================

-- CREATE OR REPLACE cannot change a function's return type, and this file has
-- gained columns since it was first run (active_devices / viewers /
-- opened_service_pct). Without the drop, re-running it fails with
--   42P13 cannot change return type of existing function
--   HINT: Use DROP FUNCTION get_practice_outcomes(integer) first.
-- Keep this line: it is what makes the file safe to re-run after any change to
-- the returns-table list, which is the whole point of an idempotent migration.
drop function if exists get_practice_outcomes(int);

create or replace function get_practice_outcomes(p_days int default 30)
returns table (
  window_start         timestamptz, -- the clamped floor actually used
  active_devices       bigint,      -- devices with ANY event in window
  viewers              bigint,      -- devices that opened a service screen
  opened_service_pct   numeric,     -- viewers / active_devices -- the first leak
  starters             bigint,      -- devices with >=1 practice_start in window
  completers           bigint,      -- devices with >=1 practice_complete in window
  completed_devices    bigint,      -- starters who completed
  abandoned_devices    bigint,      -- starters who abandoned and never completed
  no_outcome_devices   bigint,      -- starters with neither -- the honesty check
  completed_pct        numeric,
  abandoned_pct        numeric,
  no_outcome_pct       numeric,
  returners            bigint,      -- completers active on a LATER calendar day
  return_pct           numeric,
  rounds_started       bigint,
  rounds_abandoned     bigint,
  rounds_abandoned_pct numeric,
  median_progress_pct  numeric      -- how far into an abandoned round they got
)
language plpgsql
security definer
set search_path = public
as $$
declare
  admin_emails text[] := array['thvnguyen08@gmail.com', 'futuresteps.dallas@gmail.com'];
  -- practice_activity carries the row's own email; _is_internal_anon covers the
  -- persons/leads side. Both are needed, same as paClean in snapshot.mjs.
  excluded_emails text[] := array[
    'thvnguyen08@gmail.com',
    'thang.nguyen.cv@gmail.com',
    'victor.nghv@gmail.com',
    'ngat87143@gmail.com',
    'futuresteps.dallas@gmail.com'
  ];
  -- Mirrors PRACTICE_START_INSTRUMENTED_AT in snapshot.mjs. Raise it, never
  -- lower it, and only to an instant where all three events are known good.
  clamp_at    timestamptz := timestamptz '2026-07-21 15:48:00+00';
  window_days int;
  today_chi   date;
  win_start   timestamptz;
begin
  -- coalesce() matters: an anon-key caller has no 'email' claim at all, so the
  -- comparison is NULL and `if not (NULL)` is falsy in plpgsql -- it would NOT
  -- return early, silently leaking data.
  if not (coalesce(auth.jwt()->>'email', '') = any(admin_emails)) then return; end if;

  window_days := least(greatest(coalesce(p_days, 30), 1), 365);
  today_chi   := (now() at time zone 'America/Chicago')::date;
  -- N whole Chicago calendar days ending today, then floored at the clamp.
  win_start   := greatest(
                   clamp_at,
                   ((today_chi - (window_days - 1))::timestamp at time zone 'America/Chicago')
                 );

  return query
  with fe as (
    select
      e.anon_id,
      e.event_name,
      e.occurred_at,
      e.props->>'round_id' as round_id,
      -- Never cast blindly: props is unconstrained jsonb and a prop name is not
      -- a type. Same lesson as _event_int() in fix_person_rollup_cast.sql.
      case when e.props->>'progress_pct' ~ '^-?[0-9]+(\.[0-9]+)?$'
           then (e.props->>'progress_pct')::numeric end as progress_pct
    from events e
    where e.event_name in ('practice_start', 'practice_abandon', 'practice_complete')
      and e.occurred_at >= win_start
      -- snapshot.mjs skips rows with no category; match it or the counts drift.
      and nullif(e.props->>'category', '') is not null
      and not _is_internal_anon(e.anon_id)
  ),
  -- Every round that ever completed, UNCLAMPED by the window: the page-exit
  -- path can log an abandon for a round the customer later finishes, and
  -- script.js says any round with a completion counts as completed. A round
  -- that completed just after the window closed was still finished.
  done_rounds as (
    select distinct e.props->>'round_id' as round_id
    from events e
    where e.event_name = 'practice_complete' and e.props->>'round_id' is not null
  ),
  /* Devices with ANY event in the window, and devices that opened a service.
     These read `events` directly rather than `fe`, which is already narrowed to
     the three practice events — the denominator here is everyone active, not
     everyone practising. Mirrors activeDevices/viewers in snapshot.mjs.

     The `view` event is the app-side mirror of practice_activity's view row
     (logActivity fires both), so this counts the same devices the dashboard's
     funnelViews does. */
  active_ids as (
    -- UNION of both activity tables, not just events. viewer_ids below reads
    -- practice_activity, and the two tables' device populations are not
    -- identical -- a practice row can predate the events mirror logActivity()
    -- now also writes. Counting only events made the denominator smaller than
    -- its own numerator and produced rates over 100%.
    select e.anon_id as id
      from events e
     where e.occurred_at >= win_start
       and not _is_internal_anon(e.anon_id)
    union
    select a.client_id
      from practice_activity a
     where a.created_at >= win_start
       and a.client_id is not null
       and (a.email is null or lower(a.email) <> all(excluded_emails))
       and not _is_internal_anon(a.client_id)
  ),
  viewer_ids as (
    -- practice_activity, matching funnelViews in snapshot.mjs. Do NOT switch
    -- this to the events mirror without switching the dashboard too.
    select distinct a.client_id as id
      from practice_activity a
     where a.activity_type = 'view'
       and a.created_at >= win_start
       and a.category is not null
       and a.client_id is not null
       and (a.email is null or lower(a.email) <> all(excluded_emails))
       and not _is_internal_anon(a.client_id)
  ),
  starter_ids   as (select distinct anon_id from fe where event_name = 'practice_start'),
  completer_ids as (select distinct anon_id from fe where event_name = 'practice_complete'),
  abandoner_ids as (select distinct anon_id from fe where event_name = 'practice_abandon'),
  split as (
    select
      s.anon_id,
      exists (select 1 from completer_ids c where c.anon_id = s.anon_id) as completed,
      exists (select 1 from abandoner_ids a where a.anon_id = s.anon_id) as abandoned
    from starter_ids s
  ),
  first_done as (
    select f.anon_id, min(f.occurred_at) as done_at
    from fe f where f.event_name = 'practice_complete' group by f.anon_id
  ),
  returner_ids as (
    -- Any activity at all on a later Chicago day than the first completion.
    -- Reads `events` unfiltered by event_name on purpose: coming back to read
    -- the news is still coming back.
    select distinct fd.anon_id
    from first_done fd
    join events e on e.anon_id = fd.anon_id
    where (e.occurred_at at time zone 'America/Chicago')::date
        > (fd.done_at     at time zone 'America/Chicago')::date
  ),
  -- One row per abandoned round, earliest abandon wins, completions retired.
  ab_rounds as (
    select distinct on (f.round_id) f.round_id, f.progress_pct
    from fe f
    where f.event_name = 'practice_abandon'
      and f.round_id is not null
      and not exists (select 1 from done_rounds d where d.round_id = f.round_id)
    order by f.round_id, f.occurred_at
  ),
  counts as (
    select
      (select count(*) from active_ids)                                 as active_devices,
      (select count(*) from viewer_ids)                                 as viewers,
      (select count(*) from starter_ids)                                as starters,
      (select count(*) from completer_ids)                              as completers,
      (select count(*) from split where completed)                      as completed_devices,
      (select count(*) from split where not completed and abandoned)    as abandoned_devices,
      (select count(*) from split where not completed and not abandoned) as no_outcome_devices,
      (select count(*) from returner_ids)                               as returners,
      (select count(distinct round_id) from fe
        where event_name = 'practice_start' and round_id is not null)   as rounds_started,
      (select count(*) from ab_rounds)                                  as rounds_abandoned,
      -- percentile_cont matches the JS median in both parities: it returns the
      -- middle value for odd counts and the mean of the two middles for even,
      -- which is exactly what snapshot.mjs computes.
      --
      -- The ::numeric is REQUIRED, not tidiness. percentile_cont has no numeric
      -- variant -- it is WITHIN GROUP (ORDER BY double precision) -> double
      -- precision -- so ordering by a numeric column casts up to double, and
      -- round(double) returns double. This column is declared numeric, and
      -- RETURN QUERY checks the tuple structure strictly:
      --   42804 structure of query does not match function result type
      --   DETAIL: Returned type double precision does not match expected type
      --           numeric in column 15.
      -- The function CREATEs fine and fails only when called, so a clean
      -- migration run proves nothing here.
      (select round(percentile_cont(0.5) within group (order by a.progress_pct)::numeric)
         from ab_rounds a where a.progress_pct is not null)             as median_progress_pct
    from (select 1) _
  )
  select
    win_start,
    c.active_devices, c.viewers,
    coalesce(round(100.0 * c.viewers / nullif(c.active_devices, 0), 1), 0),
    c.starters, c.completers,
    c.completed_devices, c.abandoned_devices, c.no_outcome_devices,
    coalesce(round(100.0 * c.completed_devices  / nullif(c.starters, 0), 1), 0),
    coalesce(round(100.0 * c.abandoned_devices  / nullif(c.starters, 0), 1), 0),
    coalesce(round(100.0 * c.no_outcome_devices / nullif(c.starters, 0), 1), 0),
    c.returners,
    coalesce(round(100.0 * c.returners / nullif(c.completers, 0), 1), 0),
    c.rounds_started, c.rounds_abandoned,
    coalesce(round(100.0 * c.rounds_abandoned / nullif(c.rounds_started, 0), 1), 0),
    c.median_progress_pct
  from counts c;
end;
$$;

-- Same posture as every other admin reader: admins only, never the anon key.
revoke execute on function get_practice_outcomes(int) from public, anon;
grant  execute on function get_practice_outcomes(int) to authenticated;

notify pgrst, 'reload schema';

-- ----------------------------------------------------------------------------
-- Verify. These should match futuresteps-dashboard's Overview tab Practice
-- activity tiles (its "All time" range; the snapshot may be hours behind, and
-- admin counts up to this second):
--
--   select * from get_practice_outcomes(30);
--
-- The three device buckets must add up to starters -- if they ever do not, the
-- split has a hole in it:
--
--   select starters, completed_devices + abandoned_devices + no_outcome_devices as sum
--   from get_practice_outcomes(30);
-- ----------------------------------------------------------------------------
