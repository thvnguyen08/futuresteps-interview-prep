-- One-time migration for the admin page refresh (2026-07).
-- Run once in the Supabase SQL editor. Safe to re-run (idempotent).
--
-- Two changes:
--   1. get_funnel_summary() gains a `weekly_active` count (distinct people with
--      any event in the trailing 7 days) so the dashboard can show a
--      Weekly-Active-Users stickiness ratio (weekly_active / activated).
--   2. Two new admin-gated readers for the in-app `feedback` table
--      (see add_feedback.sql). Feedback has NO public SELECT policy on purpose,
--      so these run `security definer` and are gated to the admin emails, exactly
--      like the other get_* analytics functions.

-- ----------------------------------------------------------------------------
-- 1. Funnel summary + weekly-active users.
-- Adding the weekly_active column changes the return type, and CREATE OR REPLACE
-- can't do that, so drop the old signature first.
-- ----------------------------------------------------------------------------
drop function if exists get_funnel_summary();

create or replace function get_funnel_summary()
returns table (
  visitors      bigint,
  leads         bigint,
  activated     bigint,
  active        bigint,
  weekly_active bigint
)
language plpgsql
security definer
set search_path = public
as $$
declare
  admin_emails text[] := array['thvnguyen08@gmail.com', 'futuresteps.dallas@gmail.com'];
begin
  -- coalesce() matters: an anon-key caller has no 'email' claim at all, so the
  -- comparison is NULL and `if not (NULL)` is falsy in plpgsql -- it would NOT
  -- return early, silently leaking data. Coalescing to '' makes it compare false
  -- against every admin email instead.
  if not (coalesce(auth.jwt()->>'email', '') = any(admin_emails)) then return; end if;

  return query
  select
    (select count(*) from anon_visitors)::bigint,
    -- Must read through _person_rollup(), not `persons` directly, or the
    -- excluded_emails filter it applies gets bypassed here.
    (select count(*) from _person_rollup())::bigint,
    (select count(*) from _person_rollup() where is_activated)::bigint,
    (select count(*) from _person_rollup() where is_active)::bigint,
    -- Trailing-7-day active people (the WAU numerator). Distinct from `active`
    -- above, which counts people who RETURNED within 7 days of registering.
    (select count(*) from _person_rollup()
      where last_active_at >= now() - interval '7 days')::bigint;
end;
$$;

-- ----------------------------------------------------------------------------
-- 2a. get_feedback_summary() — one-row average of in-app ratings.
-- ----------------------------------------------------------------------------
create or replace function get_feedback_summary()
returns table (
  total         bigint,
  avg_ease      numeric,
  avg_helpful   numeric,
  avg_recommend numeric,
  recommend_n   bigint
)
language plpgsql
security definer
set search_path = public
as $$
declare
  admin_emails text[] := array['thvnguyen08@gmail.com', 'futuresteps.dallas@gmail.com'];
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
  select
    count(*)::bigint,
    round(avg(f.ease), 1),
    round(avg(f.helpful), 1),
    round(avg(f.recommend), 1),
    count(f.recommend)::bigint
  from feedback f
  where f.email is null or lower(f.email) <> all(excluded_emails);
end;
$$;

-- ----------------------------------------------------------------------------
-- 2b. get_feedback_comments(p_limit) — recent ratings that left a comment,
-- with the person's name resolved by email when we have one.
-- ----------------------------------------------------------------------------
create or replace function get_feedback_comments(p_limit int default 100)
returns table (
  created_at timestamptz,
  name       text,
  email      text,
  ease       smallint,
  helpful    smallint,
  recommend  smallint,
  comment    text
)
language plpgsql
security definer
set search_path = public
as $$
declare
  admin_emails text[] := array['thvnguyen08@gmail.com', 'futuresteps.dallas@gmail.com'];
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
  select
    f.created_at,
    (select p.name from persons p
       where lower(p.email) = lower(f.email) and p.name is not null
       limit 1) as name,
    f.email,
    f.ease, f.helpful, f.recommend, f.comment
  from feedback f
  where (f.email is null or lower(f.email) <> all(excluded_emails))
    and nullif(btrim(f.comment), '') is not null
  order by f.created_at desc
  limit greatest(1, least(p_limit, 500));
end;
$$;

-- ----------------------------------------------------------------------------
-- Lock down access — same two-grant revoke as the other analytics functions.
-- ----------------------------------------------------------------------------
revoke execute on function get_funnel_summary()      from public, anon;
revoke execute on function get_feedback_summary()     from public, anon;
revoke execute on function get_feedback_comments(int) from public, anon;

grant execute on function get_funnel_summary()       to authenticated;
grant execute on function get_feedback_summary()      to authenticated;
grant execute on function get_feedback_comments(int) to authenticated;
