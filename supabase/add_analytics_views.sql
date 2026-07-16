-- ============================================================================
-- One-time migration: ANALYTICS READER FUNCTIONS (funnel + channels + CRM)
-- Run AFTER add_analytics_core.sql, in the Supabase SQL editor.
-- ============================================================================
--
-- All readers are SECURITY DEFINER + gated by the admin allowlist, exactly like
-- get_crm_data() / get_leads_data(). They power the admin dashboard.
--
-- Funnel stages (see ANALYTICS.md):
--   Visitor   – any device seen (anon_visitors)
--   Lead      – identified person (registered)
--   Activated – person with ≥ 1 practice_complete event
--   Active    – person who RETURNED within 7 days of registering
--               (an event on a later calendar day, ≤ 7 days after register)
--
-- ⚠  Keep admin_emails in sync with crm_view.sql / add_leads.sql.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Helper (internal): per-person rollup used by every reader below.
-- SECURITY DEFINER so it can read the RLS-protected tables. Has no admin check
-- of its own -- callers must gate access. EXECUTE is explicitly revoked from
-- anon/authenticated further down; only the get_* wrappers below should call it.
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
  with anon_of_person as (
    select m.person_id, m.anon_id
    from person_anon_map m
  ),
  -- Earliest device per person → its first-touch attribution = person's channel.
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
      count(*) filter (where ev.event_name = 'practice_complete')  as practice_rounds,
      coalesce(sum(ev.total)   filter (where ev.event_name = 'practice_complete'), 0) as questions_done,
      coalesce(sum(ev.correct) filter (where ev.event_name = 'practice_complete'), 0) as questions_right
    from ev
    group by ev.person_id
  ),
  -- Per-person practice rounds grouped by category (drives "engages with most").
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
  left join cat_json cj on cj.person_id = p.id;
$$;

-- ----------------------------------------------------------------------------
-- get_funnel_summary() — one-row funnel snapshot for the top of the dashboard.
-- ----------------------------------------------------------------------------
create or replace function get_funnel_summary()
returns table (
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
  -- coalesce() matters: an anon-key caller has no 'email' claim at all, so the
  -- comparison is NULL and `if not (NULL)` is falsy in plpgsql -- it would NOT
  -- return early, silently leaking data. Coalescing to '' makes it compare false
  -- against every admin email instead.
  if not (coalesce(auth.jwt()->>'email', '') = any(admin_emails)) then return; end if;

  return query
  select
    (select count(*) from anon_visitors)::bigint,
    (select count(*) from persons)::bigint,
    (select count(*) from _person_rollup() where is_activated)::bigint,
    (select count(*) from _person_rollup() where is_active)::bigint;
end;
$$;

-- ----------------------------------------------------------------------------
-- get_channel_performance() — the key report: which channel produces ACTIVE
-- users. Visitors are counted by each device's first-touch channel; the funnel
-- stages by the person's first-touch channel.
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
  -- coalesce() matters: an anon-key caller has no 'email' claim at all, so the
  -- comparison is NULL and `if not (NULL)` is falsy in plpgsql -- it would NOT
  -- return early, silently leaking data. Coalescing to '' makes it compare false
  -- against every admin email instead.
  if not (coalesce(auth.jwt()->>'email', '') = any(admin_emails)) then return; end if;

  return query
  with visitor_channel as (
    select analytics_channel(first_utm_source, first_utm_medium, first_referrer) as channel,
           count(*) as visitors
    from anon_visitors
    group by 1
  ),
  person_channel as (
    select r.channel,
           count(*)                             as leads,
           count(*) filter (where r.is_activated) as activated,
           count(*) filter (where r.is_active)    as active
    from _person_rollup() r
    group by 1
  )
  select
    coalesce(vc.channel, pc.channel)      as channel,
    coalesce(vc.visitors, 0)              as visitors,
    coalesce(pc.leads, 0)                 as leads,
    coalesce(pc.activated, 0)             as activated,
    coalesce(pc.active, 0)                as active
  from visitor_channel vc
  full outer join person_channel pc on pc.channel = vc.channel
  order by active desc, visitors desc;
end;
$$;

-- ----------------------------------------------------------------------------
-- get_person_crm() — one row per person for the working contact list:
-- who they are, where they came from, their stage, and their practice stats.
-- ----------------------------------------------------------------------------
create or replace function get_person_crm()
returns table (
  name                text,
  email               text,
  phone               text,
  location            text,
  channel             text,
  stage               text,
  top_category        text,
  categories          jsonb,
  first_seen_at       timestamptz,
  first_registered_at timestamptz,
  last_active_at      timestamptz,
  last_practice_at    timestamptz,
  days_since_practice int,
  practice_rounds     bigint,
  questions_done      bigint,
  questions_right     bigint
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
    r.name, r.email, r.phone, r.location, r.channel,
    case
      when r.is_active    then 'Active'
      when r.is_activated then 'Activated'
      else 'Lead'
    end as stage,
    r.top_category, r.categories,
    r.first_seen_at, r.first_registered_at, r.last_active_at,
    r.last_practice_at,
    (current_date - r.last_practice_at::date)::int as days_since_practice,
    r.practice_rounds, r.questions_done, r.questions_right
  from _person_rollup() r
  order by r.last_active_at desc nulls last;
end;
$$;

-- ----------------------------------------------------------------------------
-- get_practice_reminders(days_inactive) — the re-engagement list: people who
-- registered, practiced at least once, gave an email, and haven't practiced in
-- >= N days. Feed straight into the reminder-email automation.
-- ----------------------------------------------------------------------------
create or replace function get_practice_reminders(days_inactive int default 7)
returns table (
  name                text,
  email               text,
  top_category        text,
  last_practice_at    timestamptz,
  days_since_practice int,
  practice_rounds     bigint
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
    r.name, r.email, r.top_category, r.last_practice_at,
    (current_date - r.last_practice_at::date)::int as days_since_practice,
    r.practice_rounds
  from _person_rollup() r
  where r.email is not null
    and r.last_practice_at is not null
    and (current_date - r.last_practice_at::date) >= days_inactive
  order by days_since_practice desc;
end;
$$;

-- ----------------------------------------------------------------------------
-- get_category_breakdown() — which categories customers engage with the most,
-- across everyone (registered + anonymous). Ranked by practice rounds.
-- ----------------------------------------------------------------------------
create or replace function get_category_breakdown()
returns table (
  category        text,
  learners        bigint,   -- distinct devices that practiced it
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
  admin_emails text[] := array['thvnguyen08@gmail.com', 'futuresteps.dallas@gmail.com'];
begin
  -- coalesce() matters: an anon-key caller has no 'email' claim at all, so the
  -- comparison is NULL and `if not (NULL)` is falsy in plpgsql -- it would NOT
  -- return early, silently leaking data. Coalescing to '' makes it compare false
  -- against every admin email instead.
  if not (coalesce(auth.jwt()->>'email', '') = any(admin_emails)) then return; end if;

  return query
  with ev as (
    select
      e.anon_id,
      nullif(e.props->>'category', '')        as category,
      coalesce((e.props->>'total')::int, 0)   as total,
      coalesce((e.props->>'correct')::int, 0) as correct
    from events e
    where e.event_name = 'practice_complete'
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

-- ----------------------------------------------------------------------------
-- get_event_feed(limit) — raw recent activity, with the person resolved.
-- ----------------------------------------------------------------------------
create or replace function get_event_feed(p_limit int default 500)
returns table (
  occurred_at timestamptz,
  name        text,
  email       text,
  property    text,
  event_name  text,
  channel     text,
  page_path   text,
  props       jsonb
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
    e.occurred_at,
    p.name,
    p.email,
    e.property,
    e.event_name,
    analytics_channel(e.utm_source, e.utm_medium, e.referrer) as channel,
    e.page_path,
    e.props
  from events e
  left join person_anon_map m on m.anon_id = e.anon_id
  left join persons p         on p.id = m.person_id
  order by e.occurred_at desc
  limit greatest(1, least(p_limit, 5000));
end;
$$;

-- ----------------------------------------------------------------------------
-- Lock down access. Supabase grants EXECUTE on every new function directly to
-- `anon` and `authenticated` by default (ALTER DEFAULT PRIVILEGES on the public
-- schema) -- NOT via the PUBLIC pseudo-role, so `revoke ... from public` alone
-- does nothing here. Without this block, the admin-only functions above are
-- callable by anyone holding the public anon key, and _person_rollup() -- which
-- has no admin check of its own, relying entirely on its callers to gate it --
-- is fully exposed with zero protection.
-- ----------------------------------------------------------------------------
revoke execute on function _person_rollup()             from anon, authenticated;
revoke execute on function get_funnel_summary()         from anon;
revoke execute on function get_channel_performance()    from anon;
revoke execute on function get_person_crm()             from anon;
revoke execute on function get_category_breakdown()     from anon;
revoke execute on function get_practice_reminders(int)  from anon;
revoke execute on function get_event_feed(int)          from anon;

grant execute on function get_funnel_summary()          to authenticated;
grant execute on function get_channel_performance()     to authenticated;
grant execute on function get_person_crm()              to authenticated;
grant execute on function get_category_breakdown()      to authenticated;
grant execute on function get_practice_reminders(int)   to authenticated;
grant execute on function get_event_feed(int)           to authenticated;
