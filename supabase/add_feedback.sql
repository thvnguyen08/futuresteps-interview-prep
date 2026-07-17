-- One-time migration: in-app customer feedback (ease + helpfulness).
-- Run once in the Supabase SQL editor.
--
-- After a practice round the app shows a non-blocking card asking two 1-5
-- questions: "How easy is the app?" and "Is it helping you prepare?".
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
  created_at timestamptz default now()
);

create index if not exists feedback_created_idx on feedback (created_at desc);

alter table feedback enable row level security;

drop policy if exists "anyone can submit feedback" on feedback;
create policy "anyone can submit feedback" on feedback
  for insert
  with check (true);

-- No SELECT/UPDATE/DELETE policy on purpose → the public key cannot read feedback.
