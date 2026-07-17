-- One-time migration: self-serve practice summary for the "Welcome back" recap.
-- Run once in the Supabase SQL editor.
--
-- When a returning customer restores by email/phone, the app adopts their device
-- client_id and calls this to show "X rounds · Y categories · last active …".
-- practice_activity is keyed by client_id, so this works across devices.
--
-- Returns ONLY aggregate practice stats + the top category (no name/email/phone),
-- so it is safe to expose to the anon key. It takes the caller's own client_id.

create or replace function get_my_summary(p_client_id text)
returns table (
  practice_rounds bigint,
  questions_done  bigint,
  questions_right bigint,
  categories      bigint,
  top_category    text,
  last_active     timestamptz,
  first_active    timestamptz
)
language sql
security definer
set search_path = public
as $$
  with acts as (
    select * from practice_activity
    where client_id = p_client_id and activity_type = 'practice'
  )
  select
    (select count(*) from acts),
    coalesce((select sum(total) from acts), 0),
    coalesce((select sum(correct) from acts), 0),
    (select count(distinct category) from acts where category is not null),
    (select category from acts where category is not null
       group by category order by count(*) desc, category limit 1),
    (select max(created_at) from acts),
    (select min(created_at) from acts);
$$;

-- Self-serve: the anonymous public key must be able to call this for its own id.
grant execute on function get_my_summary(text) to anon, authenticated;
