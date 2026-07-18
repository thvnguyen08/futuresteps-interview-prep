-- One-time migration: in-app customer feedback.
-- Run once in the Supabase SQL editor. Safe to re-run (idempotent).
--
-- After a practice round the app shows a non-blocking card asking two required
-- 1-5 questions ("How easy is the app?", "Is it helping you prepare?") plus two
-- optional fields: a 1-5 "Would you recommend FutureSteps?" and a free-text
-- comment ("What's one thing we could improve?").
-- Anyone (anon key) may INSERT their rating; there is NO SELECT policy, so the
-- public key can never read the feedback back. The dashboard snapshot reads it
-- with the service_role key (which bypasses RLS).

create table if not exists feedback (
  id         bigint generated always as identity primary key,
  client_id  text,
  email      text,
  phone      text,
  ease       smallint check (ease between 1 and 5),
  helpful    smallint check (helpful between 1 and 5),
  recommend  smallint check (recommend between 1 and 5),
  comment    text,
  created_at timestamptz default now()
);

-- Added after the initial release — bring existing installs up to date.
alter table feedback add column if not exists recommend smallint;
alter table feedback add column if not exists comment   text;
do $$ begin
  alter table feedback add constraint feedback_recommend_check check (recommend between 1 and 5);
exception when duplicate_object then null; end $$;

create index if not exists feedback_created_idx on feedback (created_at desc);

alter table feedback enable row level security;

drop policy if exists "anyone can submit feedback" on feedback;
create policy "anyone can submit feedback" on feedback
  for insert
  with check (true);

-- No SELECT/UPDATE/DELETE policy on purpose → the public key cannot read feedback.
