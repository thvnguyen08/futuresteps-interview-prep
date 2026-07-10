-- One-time migration: state/territory officials lookup for localizing the
-- state-specific civics answers. Run this once in the Supabase SQL editor
-- (Project → SQL Editor → New query).
--
-- The 2025 USCIS civics test has three questions whose correct answer depends
-- on where the applicant lives:
--   • "Who is the governor of your state now?"
--   • "Who is one of your state's U.S. senators now?"
--   • "What is the capital of your state?"
-- When a signed-in customer has saved their state, the app reads this table
-- and fills in the correct answer instead of showing a generic "look it up"
-- pointer. ("Name your U.S. representative" is district-level, not just
-- state-level, so it intentionally stays a pointer for now.)
--
-- ⚠  MAINTENANCE: capitals never change, but GOVERNORS and SENATORS change
--    with elections, appointments, and resignations. The data below is current
--    as of JULY 2026 and must be verified/updated by the Future Steps team over
--    time — update a row with a single UPDATE statement, no redeploy needed,
--    e.g.:  update state_officials set governor = 'New Name' where code = 'TX';
--    The app also shows a "verify before your interview" note next to the
--    governor and senator answers as a safety net.
--
-- Special cases handled by NULLs (the app generates the right sentence from
-- the state name):
--   • Washington, D.C.: no governor, no U.S. senators, not a state (no capital).
--   • Territories (PR, GU, VI, AS, MP): have a governor and a capital, but no
--     U.S. senators.

create table if not exists state_officials (
  code      text primary key,           -- 'TX', 'DC', 'PR', ...
  name      text not null,              -- display name, same in both languages
  capital   text,                       -- null only for D.C.
  governor  text,                       -- null for D.C.
  senators  text[]                      -- null for D.C. and territories
);

-- Public read-only, same as the questions table (no login needed to read;
-- the app only uses it for signed-in users, but the policy is simple/open).
alter table state_officials enable row level security;

drop policy if exists "public read officials" on state_officials;
create policy "public read officials" on state_officials
  for select
  using (true);

insert into state_officials (code, name, capital, governor, senators) values
('AL', 'Alabama',        'Montgomery',     'Kay Ivey',                array['Tommy Tuberville','Katie Britt']),
('AK', 'Alaska',         'Juneau',         'Mike Dunleavy',           array['Lisa Murkowski','Dan Sullivan']),
('AZ', 'Arizona',        'Phoenix',        'Katie Hobbs',             array['Mark Kelly','Ruben Gallego']),
('AR', 'Arkansas',       'Little Rock',    'Sarah Huckabee Sanders',  array['John Boozman','Tom Cotton']),
('CA', 'California',      'Sacramento',     'Gavin Newsom',            array['Alex Padilla','Adam Schiff']),
('CO', 'Colorado',       'Denver',         'Jared Polis',             array['Michael Bennet','John Hickenlooper']),
('CT', 'Connecticut',    'Hartford',       'Ned Lamont',              array['Richard Blumenthal','Chris Murphy']),
('DE', 'Delaware',       'Dover',          'Matt Meyer',              array['Chris Coons','Lisa Blunt Rochester']),
('FL', 'Florida',        'Tallahassee',    'Ron DeSantis',            array['Rick Scott','Ashley Moody']),
('GA', 'Georgia',        'Atlanta',        'Brian Kemp',              array['Jon Ossoff','Raphael Warnock']),
('HI', 'Hawaii',         'Honolulu',       'Josh Green',              array['Brian Schatz','Mazie Hirono']),
('ID', 'Idaho',          'Boise',          'Brad Little',             array['Mike Crapo','Jim Risch']),
('IL', 'Illinois',       'Springfield',    'JB Pritzker',             array['Dick Durbin','Tammy Duckworth']),
('IN', 'Indiana',        'Indianapolis',   'Mike Braun',              array['Todd Young','Jim Banks']),
('IA', 'Iowa',           'Des Moines',     'Kim Reynolds',            array['Chuck Grassley','Joni Ernst']),
('KS', 'Kansas',         'Topeka',         'Laura Kelly',             array['Jerry Moran','Roger Marshall']),
('KY', 'Kentucky',       'Frankfort',      'Andy Beshear',            array['Mitch McConnell','Rand Paul']),
('LA', 'Louisiana',      'Baton Rouge',    'Jeff Landry',             array['Bill Cassidy','John Kennedy']),
('ME', 'Maine',          'Augusta',        'Janet Mills',             array['Susan Collins','Angus King']),
('MD', 'Maryland',       'Annapolis',      'Wes Moore',               array['Chris Van Hollen','Angela Alsobrooks']),
('MA', 'Massachusetts',  'Boston',         'Maura Healey',            array['Elizabeth Warren','Ed Markey']),
('MI', 'Michigan',       'Lansing',        'Gretchen Whitmer',        array['Gary Peters','Elissa Slotkin']),
('MN', 'Minnesota',      'Saint Paul',     'Tim Walz',                array['Amy Klobuchar','Tina Smith']),
('MS', 'Mississippi',    'Jackson',        'Tate Reeves',             array['Roger Wicker','Cindy Hyde-Smith']),
('MO', 'Missouri',       'Jefferson City', 'Mike Kehoe',              array['Josh Hawley','Eric Schmitt']),
('MT', 'Montana',        'Helena',         'Greg Gianforte',          array['Steve Daines','Tim Sheehy']),
('NE', 'Nebraska',       'Lincoln',        'Jim Pillen',              array['Deb Fischer','Pete Ricketts']),
('NV', 'Nevada',         'Carson City',    'Joe Lombardo',            array['Catherine Cortez Masto','Jacky Rosen']),
('NH', 'New Hampshire',  'Concord',        'Kelly Ayotte',            array['Jeanne Shaheen','Maggie Hassan']),
('NJ', 'New Jersey',     'Trenton',        'Mikie Sherrill',          array['Cory Booker','Andy Kim']),
('NM', 'New Mexico',     'Santa Fe',       'Michelle Lujan Grisham',  array['Martin Heinrich','Ben Ray Lujan']),
('NY', 'New York',       'Albany',         'Kathy Hochul',            array['Chuck Schumer','Kirsten Gillibrand']),
('NC', 'North Carolina', 'Raleigh',        'Josh Stein',              array['Thom Tillis','Ted Budd']),
('ND', 'North Dakota',   'Bismarck',       'Kelly Armstrong',         array['John Hoeven','Kevin Cramer']),
('OH', 'Ohio',           'Columbus',       'Mike DeWine',             array['Bernie Moreno','Jon Husted']),
('OK', 'Oklahoma',       'Oklahoma City',  'Kevin Stitt',             array['James Lankford','Markwayne Mullin']),
('OR', 'Oregon',         'Salem',          'Tina Kotek',              array['Ron Wyden','Jeff Merkley']),
('PA', 'Pennsylvania',   'Harrisburg',     'Josh Shapiro',            array['Dave McCormick','John Fetterman']),
('RI', 'Rhode Island',   'Providence',     'Dan McKee',               array['Jack Reed','Sheldon Whitehouse']),
('SC', 'South Carolina', 'Columbia',       'Henry McMaster',          array['Lindsey Graham','Tim Scott']),
('SD', 'South Dakota',   'Pierre',         'Larry Rhoden',            array['John Thune','Mike Rounds']),
('TN', 'Tennessee',      'Nashville',      'Bill Lee',                array['Marsha Blackburn','Bill Hagerty']),
('TX', 'Texas',          'Austin',         'Greg Abbott',             array['John Cornyn','Ted Cruz']),
('UT', 'Utah',           'Salt Lake City', 'Spencer Cox',             array['Mike Lee','John Curtis']),
('VT', 'Vermont',        'Montpelier',     'Phil Scott',              array['Bernie Sanders','Peter Welch']),
('VA', 'Virginia',       'Richmond',       'Abigail Spanberger',      array['Mark Warner','Tim Kaine']),
('WA', 'Washington',     'Olympia',        'Bob Ferguson',            array['Patty Murray','Maria Cantwell']),
('WV', 'West Virginia',  'Charleston',     'Patrick Morrisey',        array['Shelley Moore Capito','Jim Justice']),
('WI', 'Wisconsin',      'Madison',        'Tony Evers',              array['Ron Johnson','Tammy Baldwin']),
('WY', 'Wyoming',        'Cheyenne',       'Mark Gordon',             array['John Barrasso','Cynthia Lummis']),
-- District of Columbia: not a state — no governor, no U.S. senators, no state capital.
('DC', 'Washington, D.C.', null,           null,                      null),
-- U.S. territories: have a governor and a capital, but no U.S. senators.
('PR', 'Puerto Rico',              'San Juan',        'Jenniffer Gonzalez-Colon', null),
('GU', 'Guam',                     'Hagatna',         'Lou Leon Guerrero',        null),
('VI', 'U.S. Virgin Islands',      'Charlotte Amalie','Albert Bryan Jr.',         null),
('AS', 'American Samoa',           'Pago Pago',       'Nikolao Pula',             null),
('MP', 'Northern Mariana Islands', 'Saipan',          'Arnold Palacios',          null)
on conflict (code) do update
  set name = excluded.name,
      capital = excluded.capital,
      governor = excluded.governor,
      senators = excluded.senators;
