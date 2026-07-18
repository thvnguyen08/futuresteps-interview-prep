-- One-time migration: cross-device restore of flagged + missed questions.
-- Run once in the Supabase SQL editor.
--
-- The magic-link login is gone, so progress can no longer be keyed to auth.uid.
-- These tables key it to the device client_id instead (the same id a lead is
-- stamped with, and that a returning user adopts on restore). All access goes
-- through SECURITY DEFINER functions — the tables themselves are locked (RLS on,
-- no policies), so the anon key can't read/scan them directly. The functions
-- take an unguessable client_id (writes) or a contact that must match a real
-- lead (reads), and return only question ids (no PII).

create table if not exists flagged_by_client (
  client_id   text not null,
  question_id int  not null,
  created_at  timestamptz default now(),
  primary key (client_id, question_id)
);
create table if not exists missed_by_client (
  client_id   text not null,
  question_id int  not null,
  created_at  timestamptz default now(),
  primary key (client_id, question_id)
);
alter table flagged_by_client enable row level security;
alter table missed_by_client  enable row level security;
-- No policies on purpose → only the SECURITY DEFINER functions below touch them.

-- Internal helper: the client_ids a person registered with, by email or phone.
-- Not granted to anon (called only from the definer functions below), so nobody
-- can enumerate client_ids from a contact directly.
create or replace function client_ids_for_contact(p_contact text)
returns setof text
language sql
security definer
set search_path = public
as $$
  select l.client_id
  from leads l
  where l.client_id is not null
    and case
      when position('@' in lower(trim(p_contact))) > 0
        then lower(l.email) = lower(trim(p_contact))
      else regexp_replace(coalesce(l.phone, ''), '\D', '', 'g') = regexp_replace(p_contact, '\D', '', 'g')
           and regexp_replace(p_contact, '\D', '', 'g') <> ''
    end;
$$;

create or replace function save_flag(p_client_id text, p_question_id int, p_flagged boolean)
returns void language plpgsql security definer set search_path = public as $$
begin
  if coalesce(p_client_id, '') = '' then return; end if;
  if p_flagged then
    insert into flagged_by_client(client_id, question_id) values (p_client_id, p_question_id)
      on conflict do nothing;
  else
    delete from flagged_by_client where client_id = p_client_id and question_id = p_question_id;
  end if;
end; $$;

create or replace function save_missed(p_client_id text, p_question_id int, p_missed boolean)
returns void language plpgsql security definer set search_path = public as $$
begin
  if coalesce(p_client_id, '') = '' then return; end if;
  if p_missed then
    insert into missed_by_client(client_id, question_id) values (p_client_id, p_question_id)
      on conflict do nothing;
  else
    delete from missed_by_client where client_id = p_client_id and question_id = p_question_id;
  end if;
end; $$;

create or replace function get_my_flagged(p_contact text)
returns table (question_id int)
language sql security definer set search_path = public as $$
  select distinct f.question_id from flagged_by_client f
  where f.client_id in (select client_ids_for_contact(p_contact));
$$;

create or replace function get_my_missed(p_contact text)
returns table (question_id int)
language sql security definer set search_path = public as $$
  select distinct m.question_id from missed_by_client m
  where m.client_id in (select client_ids_for_contact(p_contact));
$$;

grant execute on function save_flag(text, int, boolean)   to anon, authenticated;
grant execute on function save_missed(text, int, boolean) to anon, authenticated;
grant execute on function get_my_flagged(text)            to anon, authenticated;
grant execute on function get_my_missed(text)             to anon, authenticated;
-- internal helper stays private
revoke execute on function client_ids_for_contact(text) from public, anon, authenticated;
