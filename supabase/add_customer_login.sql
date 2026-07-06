-- One-time migration to add customer login (email magic-link via Supabase
-- Auth) and per-account progress sync. Run this once in the Supabase SQL
-- editor (Project → SQL Editor → New query).
--
-- Requires the Email auth provider enabled, which is on by default
-- (Authentication → Providers → Email). Magic-link emails are sent using
-- Supabase's built-in mailer — no third-party SMS/email provider or extra
-- cost needed for normal usage volume. Accounts are created automatically
-- the first time someone signs in with a new email (self-signup).
--
-- Two tables, both scoped to the signed-in user via row-level security so
-- each customer can only ever see or modify their own rows:
--   - flagged_questions: mirrors the "flag for review" star, synced across
--     devices instead of living only in browser localStorage.
--   - quiz_results: one row per finished self-scored round (civics
--     Simulate Real Test, or an English Test section), so a customer can
--     see their practice history over time.

create table if not exists flagged_questions (
  user_id uuid not null references auth.users(id) on delete cascade,
  question_id bigint not null references questions(id) on delete cascade,
  created_at timestamptz default now(),
  primary key (user_id, question_id)
);

alter table flagged_questions enable row level security;

create policy "users manage their own flags" on flagged_questions
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create table if not exists quiz_results (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  category text not null,
  mode text not null check (mode in ('simulate', 'english')),
  correct int not null,
  total int not null,
  taken_at timestamptz default now()
);

alter table quiz_results enable row level security;

create policy "users manage their own results" on quiz_results
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
