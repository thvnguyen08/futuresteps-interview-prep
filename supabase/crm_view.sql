-- One-time migration: CRM helper function for the admin page.
-- Run this once in the Supabase SQL editor (Project → SQL Editor → New query).
--
-- Creates a SECURITY DEFINER function that returns a one-row-per-customer
-- CRM view (email, phone, signup, last active, quiz stats). Because it uses
-- SECURITY DEFINER it bypasses row-level security, but it checks the
-- caller's email against an admin allowlist first and returns nothing if
-- the caller is not an admin.
--
-- ⚠  Update the admin_emails array below with the email addresses that
--    should have access to the admin page.

create or replace function get_crm_data()
returns table (
  user_id       uuid,
  email         text,
  phone         text,
  signed_up     timestamptz,
  last_active   timestamptz,
  rounds_completed bigint,
  questions_flagged bigint
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
    u.id                                       as user_id,
    u.email::text                              as email,
    (u.raw_user_meta_data->>'phone')::text     as phone,
    u.created_at                               as signed_up,
    u.last_sign_in_at                          as last_active,
    coalesce(qr.cnt, 0)                        as rounds_completed,
    coalesce(fq.cnt, 0)                        as questions_flagged
  from auth.users u
  left join lateral (
    select count(*)::bigint as cnt from quiz_results q where q.user_id = u.id
  ) qr on true
  left join lateral (
    select count(*)::bigint as cnt from flagged_questions f where f.user_id = u.id
  ) fq on true
  order by u.created_at desc;
end;
$$;
