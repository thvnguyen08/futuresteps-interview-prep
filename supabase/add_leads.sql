-- One-time migration: lead capture for the "register to start practicing" gate.
-- Run this once in the Supabase SQL editor (Project → SQL Editor → New query).
--
-- Before anyone can practice, the app collects Name + (Email or Phone) +
-- Location and inserts a row here, then lets them start immediately (no email
-- verification). This gives Future Steps a contactable list of genuinely
-- interested people, surfaced on the admin page.
--
-- Security: anonymous visitors may INSERT their own lead, but there is NO
-- SELECT policy, so the anon/public key can never read the list (it holds PII).
-- Admins read it through the SECURITY DEFINER get_leads_data() function below,
-- which checks the caller's email against the same admin allowlist as the CRM.

create table if not exists leads (
  id          bigint generated always as identity primary key,
  name        text not null,
  email       text,
  phone       text,
  location    text,
  created_at  timestamptz default now()
);

alter table leads enable row level security;

-- Anyone (including the anonymous public key) can submit a lead from the gate.
drop policy if exists "anyone can submit a lead" on leads;
create policy "anyone can submit a lead" on leads
  for insert
  with check (true);

-- No SELECT/UPDATE/DELETE policy on purpose → the public key cannot read leads.

-- Admin-only reader. Mirrors get_crm_data(): SECURITY DEFINER bypasses RLS, but
-- returns nothing unless the caller's email is in the admin allowlist.
-- ⚠  Keep this allowlist in sync with crm_view.sql.
create or replace function get_leads_data()
returns table (
  id         bigint,
  name       text,
  email      text,
  phone      text,
  location   text,
  created_at timestamptz
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
  select l.id, l.name, l.email, l.phone, l.location, l.created_at
  from leads l
  where l.email is null or lower(l.email) <> all(admin_emails)
  order by l.created_at desc;
end;
$$;

-- Defense in depth: new functions get EXECUTE from the PUBLIC pseudo-role by
-- Postgres default, and on this project also directly from `anon` (via ALTER
-- DEFAULT PRIVILEGES) -- independent of the admin check above. The check is
-- null-safe and correctly blocks anon callers, but don't rely on that alone --
-- revoke both grants too.
revoke execute on function get_leads_data() from public, anon;
