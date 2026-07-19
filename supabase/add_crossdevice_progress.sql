-- One-time migration: make practice ROUNDS + REVIEW counts follow a user across
-- devices (not just flagged/missed questions). Run once in the Supabase SQL editor.
-- Safe to re-run (idempotent).
--
-- Two changes:
--   1. practice_activity now records `reviewed` (how many questions a round
--      covered) for EVERY round — including flashcard/flag/document practice that
--      previously wasn't logged. `total`/`correct` stay reserved for SCORED rounds
--      so accuracy isn't diluted.
--   2. get_my_summary() now also returns the reviewed total and a per-category
--      breakdown, so the home Progress card can rebuild itself on a new device
--      (after the user restores with their email) with the right numbers AND the
--      category chips.

-- 1. Reviewed-questions count per round.
alter table practice_activity add column if not exists reviewed int;

-- 2. Self-serve cross-device summary (keyed by the caller's own client_id).
--    Return signature changes, so drop first (create-or-replace can't do that).
drop function if exists get_my_summary(text);

create function get_my_summary(p_client_id text)
returns table (
  practice_rounds   bigint,
  questions_done    bigint,   -- scored questions (drives accuracy)
  questions_right   bigint,
  questions_reviewed bigint,  -- every question seen across all rounds
  categories        bigint,
  top_category      text,
  by_category       jsonb,    -- { "<category>": { "rounds": n, "reviewed": n }, ... }
  last_active       timestamptz,
  first_active      timestamptz
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
    coalesce((select sum(reviewed) from acts), 0),
    (select count(distinct category) from acts where category is not null),
    (select category from acts where category is not null
       group by category order by count(*) desc, category limit 1),
    coalesce((
      select jsonb_object_agg(category, jsonb_build_object(
               'rounds', rounds, 'reviewed', reviewed))
      from (
        select category, count(*) as rounds, coalesce(sum(reviewed), 0) as reviewed
        from acts where category is not null
        group by category
      ) g
    ), '{}'::jsonb),
    (select max(created_at) from acts),
    (select min(created_at) from acts);
$$;

-- Self-serve: the anonymous public key must be able to call this for its own id.
grant execute on function get_my_summary(text) to anon, authenticated;
