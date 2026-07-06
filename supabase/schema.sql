-- Run this once in the Supabase SQL editor (Project → SQL Editor → New query)
-- to create the question bank table used by the interview prep app.

create table if not exists questions (
  id bigint generated always as identity primary key,
  category text not null check (category in (
    'marriage', 'naturalization', 'asylum', 'f1', 'b1b2',
    'eng_speaking', 'eng_reading', 'eng_writing'
  )),
  question_en text not null,
  question_vi text not null,
  answer_en text not null,
  answer_vi text not null,
  created_at timestamptz default now()
);

-- No login is used by the app, so allow public read-only access to this table.
alter table questions enable row level security;

create policy "public read" on questions
  for select
  using (true);
