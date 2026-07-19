-- Fill in the CURRENT national officeholders for the four civics questions
-- whose answers change with the government. Run once in the Supabase SQL editor.
-- Safe to re-run (idempotent — plain UPDATEs matched on the question text).
--
-- Names current as of July 2026:
--   President ........ Donald J. Trump
--   Vice President ... JD Vance
--   Speaker .......... Mike Johnson
--   Chief Justice .... John Roberts
--
-- ⚠ REVISIT AFTER A GOVERNMENT CHANGE (election, resignation, appointment):
-- edit the names below and re-run. No app deploy is needed — the app reads
-- these rows directly, and giving them concrete names (instead of the old
-- "check uscis.gov" text) automatically makes them auto-scorable, so they now
-- appear in the Real Civics Test multiple choice and are graded in the Spoken
-- Test, and show the real name on the 128-question flashcards.
--
-- (State-dependent answers — your Senators / Governor / capital — stay handled
-- by the state_officials lookup; "Name your U.S. representative" is
-- district-specific, so it keeps the look-it-up guidance.)

update questions set
  answer_en = 'Donald J. Trump; Donald Trump; Trump.',
  answer_vi = 'Donald J. Trump; Donald Trump; Trump.'
where category = 'naturalization'
  and question_en = 'What is the name of the President of the United States now?';

update questions set
  answer_en = 'JD Vance; J.D. Vance; Vance.',
  answer_vi = 'JD Vance; J.D. Vance; Vance.'
where category = 'naturalization'
  and question_en = 'What is the name of the Vice President of the United States now?';

update questions set
  answer_en = 'Mike Johnson; Johnson.',
  answer_vi = 'Mike Johnson; Johnson.'
where category = 'naturalization'
  and question_en = 'What is the name of the Speaker of the House of Representatives now?';

update questions set
  answer_en = 'John Roberts; John G. Roberts, Jr.; Roberts.',
  answer_vi = 'John Roberts; John G. Roberts, Jr.; Roberts.'
where category = 'naturalization'
  and question_en = 'Who is the Chief Justice of the United States now?';

-- Verify: all four rows should show the new names.
select id, question_en, answer_en
from questions
where category = 'naturalization'
  and question_en in (
    'What is the name of the President of the United States now?',
    'What is the name of the Vice President of the United States now?',
    'What is the name of the Speaker of the House of Representatives now?',
    'Who is the Chief Justice of the United States now?'
  )
order by id;
