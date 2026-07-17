-- One-time migration: self-serve "Welcome back" lookup.
-- Run once in the Supabase SQL editor.
--
-- The front-door redesign lets people practice immediately (no magic link).
-- A returning customer on a fresh device types the email OR phone they used
-- before; this function confirms a matching lead and returns their name +
-- device client_id so the app can greet them and adopt the same client_id
-- (keeps their analytics/lead identity continuous). SECURITY DEFINER so it can
-- read the RLS-protected leads table; it returns only name + client_id for an
-- exact match, nothing else.
--
-- Note: this is a low-sensitivity convenience, not authentication — anyone who
-- knows a real email/phone could look up that lead's name. Accepted trade-off
-- for a frictionless return (progress itself is not exposed here).

create or replace function find_lead_by_contact(p_contact text)
returns table (name text, client_id text)
language plpgsql
security definer
set search_path = public
as $$
declare
  c text := lower(trim(coalesce(p_contact, '')));
  digits text := regexp_replace(c, '\D', '', 'g');
begin
  if c = '' then
    return;
  elsif position('@' in c) > 0 then
    return query
      select l.name, l.client_id
      from leads l
      where lower(l.email) = c
      order by l.created_at desc
      limit 1;
  elsif digits <> '' then
    return query
      select l.name, l.client_id
      from leads l
      where regexp_replace(coalesce(l.phone, ''), '\D', '', 'g') = digits
      order by l.created_at desc
      limit 1;
  end if;
end;
$$;

-- Self-serve: the anonymous public key must be able to call this.
grant execute on function find_lead_by_contact(text) to anon, authenticated;
