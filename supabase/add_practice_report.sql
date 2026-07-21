-- ============================================================================
-- Migration: PRACTICE INTEREST REPORT (admin dashboard)
-- Run this once in the Supabase SQL editor (Project → SQL Editor → New query).
-- ============================================================================
--
-- Answers one question: are customers actually practicing, and with what?
--   Table 1  day → practice rounds per service + mock-interview rounds per service
--   Table 2  day → naturalization broken out by which test they used
--
-- Counts ROUNDS, not people, in every bucket -- rounds are additive, so a row
-- adds up. `people` (distinct devices) rides along on each row, plus two
-- day-level rows ('__all', '__nat') that carry the honest day headcount: a
-- person who practices two services is one person but two bucket rows, so the
-- per-bucket people counts must never be summed.
--
-- EXCLUDED on purpose: Green Flags, Red Flags and Document Checklist. They log
-- as practice rounds but they are reading, not practicing -- they were ~1/3 of
-- all rounds and inflated every number. Legacy rows with a NULL content_type
-- predate that column and are treated as real questions.
--
-- Security mirrors add_activity_rollup.sql: SECURITY DEFINER + the same admin
-- allowlist and internal-email exclusions.
-- ⚠  Keep both lists in sync with add_practice_tracking.sql / add_leads.sql.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Bucket vocabulary (the `bucket` column):
--   __all            day headcount across every counted round      (Table 1)
--   __nat            day headcount across naturalization rounds    (Table 2)
--   p_<service>      practice rounds        — naturalization | marriage | f1 | b1b2 | asylum
--   m_<service>      mock-interview rounds  — naturalization | marriage | f1 | b1b2 | asylum
--   n_civics128      the 128-civics flashcards
--   n_civicstest     Real Civics Test  (see the legacy note below)
--   n_spoken         Spoken Test
--   n_review         Review missed
--   n_reading | n_writing | n_speaking      the three English sections
--
-- ⚠ LEGACY: before the mode split shipped, the Real Civics Test AND the Spoken
--   Test both logged mode='simulate'. Those old rows all land in n_civicstest,
--   so n_spoken only fills in from the deploy forward. Old data cannot be split
--   retroactively -- the distinguishing bit was never written down.
--
-- Naturalization spans several category values: the civics side logs
-- category='naturalization', while the English sections log their own
-- category ('eng_reading' / 'eng_writing' / 'eng_speaking'). Table 1's
-- naturalization column therefore covers all four.
-- ----------------------------------------------------------------------------
create or replace function get_practice_report(p_days int default 30)
returns table (
  day    date,
  bucket text,
  rounds bigint,
  people bigint
)
language plpgsql
security definer
set search_path = public
as $$
declare
  admin_emails text[] := array[
    'thvnguyen08@gmail.com',
    'futuresteps.dallas@gmail.com'
  ];
  excluded_emails text[] := array[
    'thvnguyen08@gmail.com',
    'thang.nguyen.cv@gmail.com',
    'victor.nghv@gmail.com',
    'ngat87143@gmail.com',
    'futuresteps.dallas@gmail.com'
  ];
  window_days int;
begin
  -- coalesce() matters: an anon-key caller has no 'email' claim at all, so the
  -- comparison is NULL and `if not (NULL)` is falsy in plpgsql -- it would NOT
  -- return early, silently leaking data.
  if not (coalesce(auth.jwt()->>'email', '') = any(admin_emails)) then return; end if;

  window_days := least(greatest(coalesce(p_days, 30), 1), 365);

  return query
  with base as (
    select
      (a.created_at at time zone 'America/Chicago')::date as d,
      a.client_id,
      coalesce(a.mode, 'practice')         as m,
      coalesce(a.category, 'unknown')      as cat,
      coalesce(a.content_type, 'question') as ct
    from practice_activity a
    where a.activity_type = 'practice'
      and a.created_at >= now() - make_interval(days => window_days)
      and (a.email is null or lower(a.email) <> all(excluded_emails))
      and not exists (
        select 1 from leads l
        where l.client_id = a.client_id
          and lower(l.email) = any(excluded_emails)
      )
  ),
  kept as (
    -- Reading material (flags, checklists) is not practice.
    select * from base where ct = 'question'
  ),
  tagged as (
    select
      k.d,
      k.client_id,
      case
        when k.m = 'mock' and k.cat in ('marriage', 'f1', 'b1b2', 'asylum') then 'm_' || k.cat
        when k.m = 'mock' then 'm_naturalization'
        when k.cat in ('marriage', 'f1', 'b1b2', 'asylum') then 'p_' || k.cat
        when k.cat in ('naturalization', 'eng_speaking', 'eng_reading', 'eng_writing')
          then 'p_naturalization'
        else null
      end as t1,
      case
        -- Mock lives in Table 1 only; it is not one of the civics/English tests.
        when k.m = 'mock' then null
        -- 'simulate' is the legacy value covering BOTH civics tests (see above).
        when k.m in ('mctest', 'simulate') and k.cat = 'naturalization' then 'n_civicstest'
        when k.m = 'spoken' then 'n_spoken'
        when k.m = 'review' and k.cat = 'naturalization' then 'n_review'
        when k.cat = 'eng_reading' then 'n_reading'
        when k.cat = 'eng_writing' then 'n_writing'
        when k.cat = 'eng_speaking' then 'n_speaking'
        -- Whatever naturalization practice is left is the 128-civics flashcards.
        when k.cat = 'naturalization' then 'n_civics128'
        else null
      end as t2
    from kept k
  )
  select t.d, t.t1, count(*), count(distinct t.client_id)
    from tagged t where t.t1 is not null group by t.d, t.t1
  union all
  select t.d, t.t2, count(*), count(distinct t.client_id)
    from tagged t where t.t2 is not null group by t.d, t.t2
  union all
  select t.d, '__all', count(*), count(distinct t.client_id)
    from tagged t where t.t1 is not null group by t.d
  union all
  select t.d, '__nat', count(*), count(distinct t.client_id)
    from tagged t where t.t2 is not null group by t.d
  order by 1 desc, 2;
end;
$$;

-- Same posture as the other admin readers: admins only, never the anon key.
revoke execute on function get_practice_report(int) from public, anon;
grant  execute on function get_practice_report(int) to authenticated;
