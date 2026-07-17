-- One-time migration: CRM helper function for the admin page.
-- Run this once in the Supabase SQL editor (Project → SQL Editor → New query).
--
-- Creates a SECURITY DEFINER function that returns a one-row-per-customer
-- CRM view (email, phone, state, signup, last active, quiz stats). Because it uses
-- SECURITY DEFINER it bypasses row-level security, but it checks the
-- caller's email against an admin allowlist first and returns nothing if
-- the caller is not an admin.
--
-- ⚠  Update the admin_emails array below with the email addresses that
--    should have access to the admin page.

-- Return type changed (added name, last_activity_category) -- Postgres can't
-- CREATE OR REPLACE across a column-set change, so drop first.
drop function if exists get_crm_data();

create or replace function get_crm_data()
returns table (
  user_id       uuid,
  name          text,
  email         text,
  phone         text,
  state         text,
  signed_up     timestamptz,
  last_active   timestamptz,
  rounds_completed bigint,
  questions_flagged bigint,
  last_activity_category text
)
language plpgsql
security definer
as $$
declare
  -- Who may call this function (the admin login gate).
  admin_emails text[] := array[
    'thvnguyen08@gmail.com',
    'futuresteps.dallas@gmail.com'
  ];
  -- Whose data is hidden from the results (admins + internal team/test
  -- accounts) -- a superset of admin_emails, kept separate on purpose.
  excluded_emails text[] := array[
    'thvnguyen08@gmail.com',
    'thang.nguyen.cv@gmail.com',
    'victor.nghv@gmail.com',
    'ngat87143@gmail.com',
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
    u.id                                       as user_id,
    (u.raw_user_meta_data->>'name')::text      as name,
    u.email::text                              as email,
    (u.raw_user_meta_data->>'phone')::text     as phone,
    (u.raw_user_meta_data->>'state')::text     as state,
    u.created_at                               as signed_up,
    u.last_sign_in_at                          as last_active,
    coalesce(qr.cnt, 0)                        as rounds_completed,
    coalesce(fq.cnt, 0)                        as questions_flagged,
    la.category                                as last_activity_category
  from auth.users u
  left join lateral (
    select count(*)::bigint as cnt from quiz_results q where q.user_id = u.id
  ) qr on true
  left join lateral (
    select count(*)::bigint as cnt from flagged_questions f where f.user_id = u.id
  ) fq on true
  -- Most recent thing this person viewed/practiced, by matching email —
  -- what to reference in a reminder ("come back and finish Naturalization").
  left join lateral (
    select a.category from practice_activity a
    where a.email = u.email
    order by a.created_at desc
    limit 1
  ) la on true
  where u.email is null or lower(u.email) <> all(excluded_emails)
  order by u.created_at desc;
end;
$$;

-- Defense in depth: new functions get EXECUTE from the PUBLIC pseudo-role by
-- Postgres default, and on this project also directly from `anon` (via ALTER
-- DEFAULT PRIVILEGES) -- independent of the admin check above. The check is
-- null-safe and correctly blocks anon callers, but don't rely on that alone --
-- revoke both grants too.
revoke execute on function get_crm_data() from public, anon;
