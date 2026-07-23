-- ============================================================================
-- HOTFIX: _person_rollup() crashes on question_answered events
-- Run once in the Supabase SQL editor. Safe to re-run (idempotent).
-- ============================================================================
--
-- SYMPTOM
--   The admin dashboard's Unified Funnel renders empty and Channel Performance
--   shows "Failed to load analytics". Category Breakdown stays blank. Every
--   other panel (Overview, Practice Activity, Leads, News, Feedback) is fine.
--
-- CAUSE
--   _person_rollup()'s `ev` CTE casts props->>'correct' to int for EVERY event
--   of every identified person -- there is no event_name filter at that level:
--
--       coalesce((e.props->>'correct')::int, 0) as correct
--
--   That was safe while `correct` only ever appeared on practice_complete,
--   where it is a number. The question_answered event added on 2026-07-22
--   (script.js logQuestionAnswered) writes `correct` as a JSON BOOLEAN, so
--   props->>'correct' is the text 'true' and the cast raises
--   22P02 invalid input syntax for type integer: "true".
--
--   The CTE is referenced three times, so Postgres materialises it and the cast
--   runs over every row before any event_name filter applies. One boolean is
--   enough to take down the whole function -- and with it get_funnel_summary(),
--   get_channel_performance() and get_crm_data(), which all read through it.
--   admin.html's loadAnalytics() aborts the whole Promise.all on the first
--   error, which is why the funnel tiles vanish rather than showing an error.
--
-- FIX
--   Two guards, belt and braces:
--     1. Only cast on practice_complete -- a CASE, not a WHERE, so evaluation
--        order is guaranteed regardless of how the planner reshapes the query.
--     2. Only cast text that actually looks like an integer. A future event
--        that reuses the name `total` or `correct` with any other shape now
--        contributes 0 instead of breaking the dashboard.
--
--   get_category_breakdown() gets the same treatment. Its cast sits behind a
--   WHERE event_name = 'practice_complete' at the same query level, which
--   happens to be evaluated first today, but that ordering is not guaranteed.
--
-- ⚠ setup_analytics.sql and add_analytics_views.sql still carry the original
--   unguarded expressions. Re-running either of those files will reintroduce
--   this bug -- re-run THIS file afterwards, or patch them to match.
-- ============================================================================

-- Integer-safe extraction: NULL unless the prop is a plain integer literal on
-- the event we actually mean. Never raises.
create or replace function _event_int(
  props jsonb, event_name text, want_event text, prop_key text
) returns int
language sql
immutable
as $$
  select case
    when event_name is distinct from want_event then null
    when props->>prop_key ~ '^-?[0-9]+$' then (props->>prop_key)::int
    else null
  end;
$$;

-- ----------------------------------------------------------------------------
-- 1. _person_rollup() -- the function that actually breaks.
-- Identical to add_analytics_views.sql apart from the two cast lines in `ev`.
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
    select m.person_id, m.anon_id
    from person_anon_map m
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
      -- Guarded: question_answered writes `correct` as a boolean, and this CTE
      -- sees every event, not just practice_complete. See the header.
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
    from ev
    group by ev.person_id
  ),
  cat as (
    select ev.person_id, ev.category, count(*) as rounds
    from ev
    where ev.event_name = 'practice_complete' and ev.category is not null
    group by ev.person_id, ev.category
  ),
  top_cat as (
    select distinct on (person_id) person_id, category, rounds
    from cat
    order by person_id, rounds desc, category
  ),
  cat_json as (
    select person_id, jsonb_object_agg(category, rounds) as categories
    from cat
    group by person_id
  )
  select
    p.id,
    p.name, p.email, p.phone, p.location,
    fa.first_seen_at,
    p.first_registered_at,
    a.last_active_at,
    a.last_practice_at,
    coalesce(fa.channel, 'Direct / Word-of-mouth') as channel,
    coalesce(a.practice_rounds, 0),
    coalesce(a.questions_done, 0),
    coalesce(a.questions_right, 0),
    tc.category as top_category,
    coalesce(cj.categories, '{}'::jsonb) as categories,
    coalesce(a.practice_rounds, 0) > 0 as is_activated,
    exists (
      select 1 from ev
      where ev.person_id = p.id
        and p.first_registered_at is not null
        and ev.occurred_at::date > p.first_registered_at::date
        and ev.occurred_at <= p.first_registered_at + interval '7 days'
    ) as is_active
  from persons p
  left join first_anon fa on fa.person_id = p.id
  left join agg a       on a.person_id = p.id
  left join top_cat tc  on tc.person_id = p.id
  left join cat_json cj on cj.person_id = p.id
  where p.email is null or lower(p.email) not in (select email from excluded_emails);
$$;

-- ----------------------------------------------------------------------------
-- 2. get_category_breakdown() -- same guard, pre-emptively.
-- Body copied from add_analytics_views.sql; only the two cast lines change.
-- ----------------------------------------------------------------------------
create or replace function get_category_breakdown()
returns table (
  category        text,
  learners        bigint,
  practice_rounds bigint,
  questions_done  bigint,
  questions_right bigint,
  accuracy_pct    numeric
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
begin
  if not (coalesce(auth.jwt()->>'email', '') = any(admin_emails)) then return; end if;

  return query
  with ev as (
    select
      e.anon_id,
      nullif(e.props->>'category', '') as category,
      coalesce(_event_int(e.props, e.event_name, 'practice_complete', 'total'), 0)   as total,
      coalesce(_event_int(e.props, e.event_name, 'practice_complete', 'correct'), 0) as correct
    from events e
    where e.event_name = 'practice_complete'
      and not exists (
        select 1 from person_anon_map m
        join persons p on p.id = m.person_id
        where m.anon_id = e.anon_id
          and lower(p.email) = any(excluded_emails)
      )
  )
  select
    ev.category,
    count(distinct ev.anon_id)                                  as learners,
    count(*)                                                    as practice_rounds,
    coalesce(sum(ev.total), 0)                                  as questions_done,
    coalesce(sum(ev.correct), 0)                                as questions_right,
    round(100.0 * coalesce(sum(ev.correct), 0)
          / nullif(sum(ev.total), 0), 1)                        as accuracy_pct
  from ev
  where ev.category is not null
  group by ev.category
  order by practice_rounds desc;
end;
$$;

-- Same posture as every other reader: admins only, never the anon key.
revoke execute on function _person_rollup()            from public, anon, authenticated;
revoke execute on function _event_int(jsonb, text, text, text) from public, anon;
revoke execute on function get_category_breakdown()    from public, anon;
grant  execute on function get_category_breakdown()    to authenticated;

-- ----------------------------------------------------------------------------
-- Verify (run as an admin, or with the service_role key):
--
--   -- how many events would have broken the old cast:
--   select event_name, props->>'correct' as correct_text, count(*)
--   from events
--   where props ? 'correct' and props->>'correct' !~ '^-?[0-9]+$'
--   group by 1, 2 order by 3 desc;
--
--   -- and that the readers are healthy again:
--   select * from get_funnel_summary();
--   select * from get_channel_performance();
--   select * from get_category_breakdown();
-- ----------------------------------------------------------------------------
