-- One-time migration: track practice activity per lead WITHOUT requiring the
-- magic-link login. Run once in the Supabase SQL editor.
--
-- Why: the magic link was a drop-off point. Now every visitor who registers at
-- the gate gets a stable client_id (kept on their device). We stamp that id on
-- their lead row and on every practice/view event, so the CRM can see what each
-- person practiced or viewed and when — with no email verification step.
--
-- Security mirrors the leads table: anonymous visitors may INSERT their own
-- activity, but there is NO SELECT policy (the rows reference PII by email), so
-- the public key can never read the log. Admins read it via the SECURITY
-- DEFINER get_activity_data() function, gated by the same admin allowlist.
-- ⚠  Run this file exactly once. Keep the admin allowlist in sync with
--    crm_view.sql / add_leads.sql.

-- 1. Correlate a lead with the device that submitted it.
alter table leads add column if not exists client_id text;

-- 2. Per-event practice/view log.
create table if not exists practice_activity (
  id            bigint generated always as identity primary key,
  client_id     text not null,
  email         text,
  activity_type text not null check (activity_type in ('view', 'practice')),
  category      text,
  mode          text,
  content_type  text,
  correct       int,
  total         int,
  created_at    timestamptz default now()
);

create index if not exists practice_activity_client_idx on practice_activity (client_id);
create index if not exists practice_activity_created_idx on practice_activity (created_at desc);

alter table practice_activity enable row level security;

drop policy if exists "anyone can log activity" on practice_activity;
create policy "anyone can log activity" on practice_activity
  for insert
  with check (true);
-- No SELECT/UPDATE/DELETE policy on purpose → the public key cannot read it.

-- 3. Admin-only reader: detailed activity feed, newest first, with the lead's
--    name resolved from the client_id (falling back to a matching email).
create or replace function get_activity_data()
returns table (
  created_at    timestamptz,
  name          text,
  email         text,
  activity_type text,
  category      text,
  mode          text,
  content_type  text,
  correct       int,
  total         int,
  client_id     text
)
language plpgsql
security definer
as $$
declare
  admin_emails text[] := array[
    'thvnguyen08@gmail.com',
    'futuresteps.dallas@gmail.com'
  ];
  caller_email text;
begin
  caller_email := auth.jwt()->>'email';
  if caller_email is null or not (caller_email = any(admin_emails)) then
    return;
  end if;

  return query
  select
    a.created_at,
    coalesce(lc.name, le.name) as name,
    coalesce(a.email, le.email, lc.email) as email,
    a.activity_type,
    a.category,
    a.mode,
    a.content_type,
    a.correct,
    a.total,
    a.client_id
  from practice_activity a
  left join lateral (
    select l.name, l.email from leads l
    where l.client_id = a.client_id
    order by l.created_at desc limit 1
  ) lc on true
  left join lateral (
    select l.name, l.email from leads l
    where a.email is not null and l.email = a.email
    order by l.created_at desc limit 1
  ) le on true
  order by a.created_at desc
  limit 2000;
end;
$$;

-- 4. Admin-only per-lead activity summary (for enriching the Leads table:
--    last active, how many practice rounds, and which services they touched).
create or replace function get_lead_activity_summary()
returns table (
  client_id       text,
  email           text,
  last_active     timestamptz,
  practice_rounds bigint,
  questions_done  bigint,
  questions_right bigint,
  services        text
)
language plpgsql
security definer
as $$
declare
  admin_emails text[] := array[
    'thvnguyen08@gmail.com',
    'futuresteps.dallas@gmail.com'
  ];
  caller_email text;
begin
  caller_email := auth.jwt()->>'email';
  if caller_email is null or not (caller_email = any(admin_emails)) then
    return;
  end if;

  return query
  select
    a.client_id,
    max(a.email) as email,
    max(a.created_at) as last_active,
    count(*) filter (where a.activity_type = 'practice') as practice_rounds,
    coalesce(sum(a.total) filter (where a.activity_type = 'practice'), 0) as questions_done,
    coalesce(sum(a.correct) filter (where a.activity_type = 'practice'), 0) as questions_right,
    string_agg(distinct a.category, ', ') as services
  from practice_activity a
  group by a.client_id;
end;
$$;
