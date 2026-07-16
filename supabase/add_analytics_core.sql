-- ============================================================================
-- One-time migration: UNIFIED ANALYTICS + IDENTITY CORE (web + app)
-- Run this once in the Supabase SQL editor (Project → SQL Editor → New query).
-- ============================================================================
--
-- Goal: track how / who / when customers engage with BOTH the website (llc-web)
-- and the app (interview-prep), under ONE person identity, so the funnel
--   Visitor → Lead → Activated → Active
-- can be measured end to end and reused as a CRM.
--
-- Identity model (privacy-first, no third-party pixels):
--   • anon_id   – a random id kept in localStorage, created on the first visit
--                 to EITHER property. The website CTA link to the app appends
--                 ?aid=<anon_id>, and the app adopts it, so one human shares a
--                 single anon_id across web + app.
--   • persons   – one row per identified human (created when they register /
--                 submit a lead, matched on email or phone).
--   • person_anon_map – links every device/browser (anon_id) to its person.
--
-- Security mirrors leads / practice_activity: the anon/public key may INSERT
-- its own rows but there is NO SELECT policy, so it can never read the data
-- (it holds PII). Admins read through the SECURITY DEFINER get_* functions in
-- add_analytics_views.sql, gated by the same admin allowlist used elsewhere.
-- ⚠  Keep the admin allowlist in sync with crm_view.sql / add_leads.sql.
-- ⚠  Run order: this file → add_analytics_views.sql → add_analytics_backfill.sql
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. anon_visitors — one row per device/browser, storing FIRST-TOUCH context.
--    Insert-once: the first visit wins (attribution never gets overwritten).
--    Last-seen / activity is derived from events, so no UPDATE policy is needed.
-- ----------------------------------------------------------------------------
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
-- No SELECT/UPDATE/DELETE policy → public key cannot read the visitor list.

-- ----------------------------------------------------------------------------
-- 2. persons — one row per identified human (created at registration).
-- ----------------------------------------------------------------------------
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
-- No policies at all → only SECURITY DEFINER functions (identify + get_*) touch
-- this table. The public key can neither read nor write persons directly.

-- ----------------------------------------------------------------------------
-- 3. person_anon_map — links each device (anon_id) to its person.
--    One anon_id maps to exactly one person; a person may own many anon_ids
--    (e.g. their phone browser + the app on the same phone + a laptop).
-- ----------------------------------------------------------------------------
create table if not exists person_anon_map (
  anon_id   text primary key,
  person_id uuid not null references persons(id) on delete cascade,
  linked_at timestamptz not null default now()
);

create index if not exists person_anon_map_person_idx on person_anon_map (person_id);

alter table person_anon_map enable row level security;
-- No policies → written only by identify(); read only by get_* functions.

-- ----------------------------------------------------------------------------
-- 4. events — the spine. Every tracked interaction on web or app lands here.
--    person_id is intentionally NOT stored; a person is resolved at read time
--    by joining anon_id → person_anon_map, so late identification retroactively
--    attributes ALL of a device's earlier anonymous events for free.
-- ----------------------------------------------------------------------------
create table if not exists events (
  id           bigint generated always as identity primary key,
  anon_id      text not null,
  property     text not null check (property in ('web', 'app')),
  event_name   text not null,          -- see ANALYTICS.md for the taxonomy
  session_id   text,
  page_path    text,
  referrer     text,
  utm_source   text,
  utm_medium   text,
  utm_campaign text,
  utm_content  text,
  utm_term     text,
  props        jsonb not null default '{}'::jsonb,  -- flexible per-event payload
  occurred_at  timestamptz not null default now(),
  created_at   timestamptz not null default now()
);

create index if not exists events_anon_idx      on events (anon_id);
create index if not exists events_name_idx      on events (event_name);
create index if not exists events_occurred_idx  on events (occurred_at desc);
create index if not exists events_property_idx  on events (property);

alter table events enable row level security;

drop policy if exists "anyone can log an event" on events;
create policy "anyone can log an event" on events
  for insert with check (true);
-- No SELECT/UPDATE/DELETE policy → public key writes events but can never read.

-- ----------------------------------------------------------------------------
-- 5. identify() — called by the client the moment someone registers or logs in.
--    Upserts the person (matched on email/phone), links this device to them,
--    and records a 'register' event. SECURITY DEFINER so it bypasses RLS;
--    it exposes nothing sensitive (returns only the new/existing person id).
-- ----------------------------------------------------------------------------
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

  -- Make sure the device is on record (first touch may have been missed).
  insert into anon_visitors (anon_id, first_property)
  values (p_anon_id, p_property)
  on conflict (anon_id) do nothing;

  -- Already linked to a person?
  select person_id into v_person from person_anon_map where anon_id = p_anon_id;

  -- Else try to match an existing person by email, then phone.
  if v_person is null then
    select id into v_person
    from persons
    where (v_email is not null and lower(email) = v_email)
       or (v_phone is not null and phone = v_phone)
    order by created_at
    limit 1;
  end if;

  -- Else create a new person.
  if v_person is null then
    insert into persons (name, email, phone, location, first_registered_at)
    values (nullif(trim(p_name), ''), v_email, v_phone,
            nullif(trim(p_location), ''), now())
    returning id into v_person;
  else
    -- Enrich without clobbering values we already have.
    update persons set
      name                = coalesce(name, nullif(trim(p_name), '')),
      email               = coalesce(email, v_email),
      phone               = coalesce(phone, v_phone),
      location            = coalesce(location, nullif(trim(p_location), '')),
      first_registered_at = coalesce(first_registered_at, now()),
      updated_at          = now()
    where id = v_person;
  end if;

  -- Link this device to the person.
  insert into person_anon_map (anon_id, person_id)
  values (p_anon_id, v_person)
  on conflict (anon_id) do update set person_id = excluded.person_id;

  -- Record the identification as an event.
  insert into events (anon_id, property, event_name, occurred_at)
  values (p_anon_id, p_property, 'register', now());

  return v_person;
end;
$$;

-- Callable by the public (anon) and logged-in (authenticated) keys.
grant execute on function identify(text, text, text, text, text, text)
  to anon, authenticated;

-- ----------------------------------------------------------------------------
-- 6. analytics_channel() — canonical channel classifier, reused by every
--    reporting function so "FB Posts" vs "FB Ads" is defined in ONE place.
-- ----------------------------------------------------------------------------
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
    -- Paid Facebook: an ad's utm carries a paid medium.
    when lower(coalesce(p_utm_medium, '')) in
           ('cpc','ppc','paid','paidsocial','paid_social','paid-social')
     and (lower(coalesce(p_utm_source, '')) like '%facebook%'
       or lower(coalesce(p_utm_source, '')) in ('fb','meta','ig','instagram'))
      then 'FB Ads'

    -- Organic Facebook (your real channel): FB posts / shares, no paid medium.
    when lower(coalesce(p_utm_source, '')) like '%facebook%'
      or lower(coalesce(p_utm_source, '')) in ('fb','meta')
      or lower(coalesce(p_referrer, ''))   like '%facebook.%'
      or lower(coalesce(p_referrer, ''))   like '%//fb.%'
      or lower(coalesce(p_referrer, ''))   like '%l.facebook%'
      or lower(coalesce(p_referrer, ''))   like '%lm.facebook%'
      then 'FB Posts'

    -- Any other paid traffic.
    when lower(coalesce(p_utm_medium, '')) in ('cpc','ppc','paid')
      then 'Paid'

    -- Organic search.
    when lower(coalesce(p_referrer, '')) ~ '(google|bing|yahoo|duckduckgo|ecosia)\.'
      then 'Organic Search'

    -- No referrer and no campaign → typed the URL or came from word-of-mouth.
    when coalesce(p_referrer, '') = '' and coalesce(p_utm_source, '') = ''
      then 'Direct / Word-of-mouth'

    else 'Referral'
  end;
$$;
