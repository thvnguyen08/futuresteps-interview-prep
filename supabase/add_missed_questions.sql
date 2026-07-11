-- One-time migration: per-customer "missed questions" for adaptive review.
-- Run this once in the Supabase SQL editor (Project → SQL Editor → New query).
--
-- Mirrors flagged_questions: a civics question is added here when the customer
-- answers it incorrectly on the Simulate or Spoken test, and removed the next
-- time they get it right. The app's "Review Missed" civics mode quizzes only
-- these. Scoped to the signed-in user via row-level security; logged-out
-- customers keep the same list in browser localStorage and it merges up on
-- first login (same as flagged questions).

create table if not exists missed_questions (
  user_id uuid not null references auth.users(id) on delete cascade,
  question_id bigint not null references questions(id) on delete cascade,
  created_at timestamptz default now(),
  primary key (user_id, question_id)
);

alter table missed_questions enable row level security;

create policy "users manage their own missed" on missed_questions
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
