-- ============================================================================
-- Migration: IMMIGRATION NEWS ANALYTICS (admin dashboard panel)
-- Run this once in the Supabase SQL editor (Project → SQL Editor → New query).
-- ============================================================================
--
-- Reads the three news events already logged by the app (see the "News
-- analytics" block in script.js):
--   news_impression — card scrolled into view on home (once per story/session)
--   news_open       — the story modal was opened
--   news_beacon     — a click inside/on the story: props.part = 'faq' | 'source'
--
-- Every event carries props: slot, title (English — the stable label), category,
-- featured. Stories are grouped by TITLE, not slot: the weekly news sync rotates
-- a new story into an existing slot, so slot alone would merge two different
-- articles into one row.
--
-- Security mirrors add_analytics_views.sql: SECURITY DEFINER + the same admin
-- allowlist, and the same internal-email exclusions so our own testing does not
-- inflate the numbers.
-- ⚠  Keep both lists in sync with add_analytics_views.sql / add_leads.sql.
-- ⚠  Run order: add_analytics_core.sql → add_analytics_views.sql → this file.
-- ============================================================================

-- Reading news props out of jsonb is the hot path for all three functions.
create index if not exists events_news_idx
  on events (event_name, occurred_at desc)
  where event_name in ('news_impression', 'news_open', 'news_beacon');

-- ----------------------------------------------------------------------------
-- get_news_summary() — headline totals for the panel's stat cards.
-- ----------------------------------------------------------------------------
create or replace function get_news_summary()
returns table (
  impressions   bigint,
  opens         bigint,
  readers       bigint,   -- distinct devices that opened at least one story
  faq_expands   bigint,
  source_clicks bigint,
  stories       bigint    -- distinct stories that have been seen at all
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
  -- coalesce() matters: an anon-key caller has no 'email' claim at all, so the
  -- comparison is NULL and `if not (NULL)` is falsy in plpgsql -- it would NOT
  -- return early, silently leaking data. Coalescing to '' makes it compare false
  -- against every admin email instead.
  if not (coalesce(auth.jwt()->>'email', '') = any(admin_emails)) then return; end if;

  return query
  with ev as (
    select e.anon_id, e.event_name, e.props
    from events e
    where e.event_name in ('news_impression', 'news_open', 'news_beacon')
      and not exists (
        select 1 from person_anon_map m
        join persons p on p.id = m.person_id
        where m.anon_id = e.anon_id
          and lower(p.email) = any(excluded_emails)
      )
  )
  select
    count(*) filter (where event_name = 'news_impression'),
    count(*) filter (where event_name = 'news_open'),
    count(distinct anon_id) filter (where event_name = 'news_open'),
    count(*) filter (where event_name = 'news_beacon' and props->>'part' = 'faq'),
    count(*) filter (where event_name = 'news_beacon' and props->>'part' = 'source'),
    count(distinct nullif(props->>'title', ''))
  from ev;
end;
$$;

-- ----------------------------------------------------------------------------
-- get_news_performance() — one row per story, ranked by opens.
-- Open rate is the real signal: it says the headline earned the tap.
-- ----------------------------------------------------------------------------
create or replace function get_news_performance()
returns table (
  title         text,
  category      text,
  slot          int,
  featured      boolean,
  impressions   bigint,
  opens         bigint,
  readers       bigint,
  open_rate_pct numeric,
  faq_expands   bigint,
  source_clicks bigint,
  last_seen_at  timestamptz
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
  with ev as (
    select
      e.anon_id,
      e.event_name,
      e.occurred_at,
      nullif(e.props->>'title', '')    as title,
      nullif(e.props->>'category', '') as category,
      (e.props->>'slot')::int          as slot,
      (e.props->>'featured')::boolean  as featured,
      e.props->>'part'                 as part
    from events e
    where e.event_name in ('news_impression', 'news_open', 'news_beacon')
      and nullif(e.props->>'title', '') is not null
      and not exists (
        select 1 from person_anon_map m
        join persons p on p.id = m.person_id
        where m.anon_id = e.anon_id
          and lower(p.email) = any(excluded_emails)
      )
  )
  select
    ev.title,
    -- A story keeps its category/slot/featured flag, but take the most recent
    -- values in case the weekly sync edited the story in place.
    (array_agg(ev.category order by ev.occurred_at desc) filter (where ev.category is not null))[1],
    (array_agg(ev.slot     order by ev.occurred_at desc) filter (where ev.slot is not null))[1],
    bool_or(ev.featured),
    count(*) filter (where ev.event_name = 'news_impression'),
    count(*) filter (where ev.event_name = 'news_open'),
    count(distinct ev.anon_id) filter (where ev.event_name = 'news_open'),
    case
      when count(*) filter (where ev.event_name = 'news_impression') > 0
      then round(
        100.0 * count(*) filter (where ev.event_name = 'news_open')
              / count(*) filter (where ev.event_name = 'news_impression'), 1)
      else null
    end,
    count(*) filter (where ev.event_name = 'news_beacon' and ev.part = 'faq'),
    count(*) filter (where ev.event_name = 'news_beacon' and ev.part = 'source'),
    max(ev.occurred_at)
  from ev
  group by ev.title
  order by count(*) filter (where ev.event_name = 'news_open') desc,
           count(*) filter (where ev.event_name = 'news_impression') desc;
end;
$$;

-- ----------------------------------------------------------------------------
-- get_news_faq_engagement(p_limit) — which student questions actually get
-- expanded. This is the panel's most actionable output: it says what people
-- want explained, which feeds both future news FAQs and practice content.
-- ----------------------------------------------------------------------------
create or replace function get_news_faq_engagement(p_limit int default 25)
returns table (
  question   text,
  story      text,
  expands    bigint,
  readers    bigint,
  last_at    timestamptz
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
    nullif(e.props->>'faq_question', '') as question,
    (array_agg(nullif(e.props->>'title', '') order by e.occurred_at desc))[1] as story,
    count(*)                   as expands,
    count(distinct e.anon_id)  as readers,
    max(e.occurred_at)         as last_at
  from events e
  where e.event_name = 'news_beacon'
    and e.props->>'part' = 'faq'
    and nullif(e.props->>'faq_question', '') is not null
    and not exists (
      select 1 from person_anon_map m
      join persons p on p.id = m.person_id
      where m.anon_id = e.anon_id
        and lower(p.email) = any(excluded_emails)
    )
  group by nullif(e.props->>'faq_question', '')
  order by count(*) desc, max(e.occurred_at) desc
  limit greatest(p_limit, 0);
end;
$$;

-- Same posture as the other analytics readers: admins only, never the anon key.
revoke execute on function get_news_summary()          from public, anon;
revoke execute on function get_news_performance()      from public, anon;
revoke execute on function get_news_faq_engagement(int) from public, anon;

grant execute on function get_news_summary()           to authenticated;
grant execute on function get_news_performance()       to authenticated;
grant execute on function get_news_faq_engagement(int) to authenticated;
