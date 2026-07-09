-- One-time migration: service-level CRM access for the scheduled task.
-- Run this once in the Supabase SQL editor.
--
-- Creates a SECURITY DEFINER function identical to get_crm_data() but
-- authenticates via a shared secret instead of JWT, so automated tasks
-- (no browser session) can pull customer data.

create or replace function get_crm_data_service(api_secret text)
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
begin
  if api_secret is null or api_secret != 'RYm1pAxn_SzSAeCh5w-9_Uz62X7NXfbwiSgGyEEL2Os' then
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
