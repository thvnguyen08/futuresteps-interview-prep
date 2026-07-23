# Unified Analytics & Identity — Data Structure

Tracks **how / who / when** customers engage across the **website (`llc-web`)** and
the **app (`interview-prep`)**, under one person identity, to measure the funnel:

```
Visitor ──► Lead ──► Activated ──► Active
(seen)     (register)  (≥1 practice)  (returned ≤7 days after register)
```

Everything lives in your existing Supabase project. No third-party pixels, no
cookie banner needed: a random anonymous id in `localStorage`, PII readable only
through the admin-gated `get_*` functions you already use.

## Run order (Supabase → SQL Editor)

1. `add_analytics_core.sql` — tables, `identify()`, `analytics_channel()`
2. `add_analytics_views.sql` — admin reader functions
3. `add_analytics_backfill.sql` — imports existing `leads` + `practice_activity`

## Tables

| Table | Grain | Holds |
|---|---|---|
| `anon_visitors` | 1 / device | **first-touch** attribution (utm, referrer, landing) |
| `persons` | 1 / human | name, email, phone, location, first_registered_at |
| `person_anon_map` | 1 / device | links `anon_id` → `person_id` |
| `events` | 1 / interaction | the spine: name, props, utm, `occurred_at` |

A person is resolved at **read time** by `anon_id → person_anon_map`, so when
someone registers, *all* their earlier anonymous events attribute to them for free.

## Identity — the web↔app stitch

1. On first visit to **either** site, generate `anon_id` (e.g. `crypto.randomUUID()`)
   and store it in `localStorage`.
2. The website's **"Practice now" CTA** to the app must append the id:
   `https://futuresteps-interview-prep.netlify.app/?aid=<anon_id>`
3. The **app**, on load, prefers `?aid=` from the URL over any local id, so one
   human keeps a single `anon_id` across web → app.
4. On register/login, call `identify()` — it matches or creates the person and
   links this device. Any other device the person uses later links on its own
   `identify()` and is merged by matching email/phone.

## Client contract

**First touch** (once per device, on first visit — `INSERT … ON CONFLICT DO NOTHING`):

```js
await supabase.from('anon_visitors').insert({
  anon_id, first_property: 'web',           // or 'app'
  first_referrer: document.referrer || null,
  first_landing_path: location.pathname,
  first_utm_source: p.get('utm_source'), first_utm_medium: p.get('utm_medium'),
  first_utm_campaign: p.get('utm_campaign'),
  first_utm_content: p.get('utm_content'), first_utm_term: p.get('utm_term'),
});   // ignore the duplicate-key error — first visit wins
```

**Every event:**

```js
await supabase.from('events').insert({
  anon_id, property: 'web',                  // or 'app'
  event_name, session_id, page_path: location.pathname,
  referrer: document.referrer || null,
  utm_source, utm_medium, utm_campaign, utm_content, utm_term,
  props: { /* event-specific, see below */ },
});
```

**Register / login** (creates + links the person):

```js
const { data: personId } = await supabase.rpc('identify', {
  p_anon_id: anon_id, p_name: name, p_email: email,
  p_phone: phone, p_location: location, p_property: 'app',
});
```

## Event taxonomy (`event_name`)

| `event_name` | Property | `props` | Fired when |
|---|---|---|---|
| `page_view` | web, app | — | every page / route load |
| `cta_click` | web | `{ target: 'app' }` | "Practice now" clicked |
| `contact_submit` | web | `{ service }` | contact form submitted → also call `identify()` |
| `register` | app | — | emitted **by `identify()`** — don't send manually |
| `login` | app | — | returning login |
| `practice_start` | app | `{ round_id, category, mode, content_type, total }` | a round begins with ≥1 question |
| `practice_complete` | app | `{ round_id, category, mode, content_type, correct, total }` | round finished — **drives Activated/Active** |
| `practice_abandon` | app | `{ round_id, category, mode, content_type, answered, total, progress_pct, seconds, reason }` | a started round was left unfinished |
| `practice_empty` | app | `{ category, mode, content_type }` | a round was requested but the question pool was empty (dead end, not an abandon) |
| `question_answered` | app | `{ round_id, question_id, category, mode, content_type, index }` + at most one of `correct` / `self_rating` | one question was worked — see below |
| `outcome_prompt_shown` | app | `{ days_since_signup, category }` | the 30-day outcome prompt became visible (the denominator) |
| `outcome_reported` | app | `{ result, category }` | the customer answered it — `result` is `not_yet` / `passed` / `did_not_pass` |
| `outcome_dismissed` | app | `{ category }` | they closed it without answering |

**`device`.** Every event — new and pre-existing — now carries
`props.device` = `mobile` \| `tablet` \| `desktop`, stamped centrally in
`logEvent()`. ~69% of traffic arrives from Facebook and is therefore mobile, so
any funnel step can now be split by form factor without new instrumentation.
Events logged before 2026-07-22 have no `device` key; treat missing as unknown
rather than desktop.

**`question_answered`** is the per-question grain the North Star depends on. The
outcome field depends on the mode, and is deliberately not always present:

- `correct` (boolean) — scored and study multiple-choice, self-marked civics,
  and the English sections. Logged for *unscored* study MC too: correctness is
  known either way, and `mode` separates them on the read side.
- `self_rating` (`confident` \| `okay` \| `needs_work`) — mock modes only. Three
  values, matching the buttons and the mock done-screen that already shipped.
  This is the learner's own read, shown back to them as progress; nothing is
  gated on it.
- **neither** — the unscored decks (flashcards, open-field question decks), where
  advancing is the only signal a question was worked. Count these as volume, not
  as accuracy.

`index` is the position within the round, so per-position drop-off and
per-question difficulty are histograms over `question_answered` alone, without
joining back to `practice_abandon`.

**Mode vocabulary alignment (2026-07-22).** `practice_start` and
`practice_abandon` previously logged the coarse label, which collapsed the Real
Civics Test and the Spoken Test both into `simulate`, while `practice_complete`
had always logged the finer `mctest` / `spoken`. All three now use the finer
label, so a round's start, completion and abandon are directly comparable and
share the vocabulary `practiceBuckets()` in the dashboard already understands.
Rows written before this date keep `simulate` on the start/abandon and cannot be
split retroactively.

**Reading the practice funnel.** `round_id` joins the three round events.
`reason` on an abandon is `left_round` (tapped Home), `restart` (started another
round), or `left_page` (closed/backgrounded the tab). A `left_page` abandon is a
*snapshot*, not a verdict — the round stays open, so a customer who returns and
finishes emits `practice_complete` for the same `round_id`. **Any round_id with a
completion counts as completed, even if an abandon exists for it.** `answered` is
how far they got, so per-question drop-off is a histogram over that field.
| `view` | app | `{ category, content_type }` | browsed content without practicing |
| `news_impression` | app | `{ slot, title, category, featured }` | a news card scrolled ≥50% into view (once per story per session) |
| `news_open` | app | `{ slot, title, category, featured, faqs }` | the story was opened (card, keyboard, or breaking banner) |
| `news_beacon` | app | `{ slot, title, …, part, surface }` | which part of the story was clicked — `part: 'faq'` (+`faq_index`, `faq_question`) or `'source'` (+`source_name`, `surface: 'card'\|'modal'`) |

News events carry the **English** `title` / `faq_question` so the dashboard keeps
a stable label after the weekly sync rotates a slot to a different story — `slot`
alone is not a durable article identifier.

Add new event names freely; the schema doesn't need changing. Keep
`practice_complete` fields stable — the funnel depends on them.

## Reading the data (admin only)

| Function | Returns |
|---|---|
| `get_funnel_summary()` | visitors / leads / activated / active counts |
| `get_channel_performance()` | the above **split by channel** — your key report |
| `get_person_crm()` | one row per person: stage, channel, **top_category**, **categories** (jsonb of category→rounds), **last_practice_at**, **days_since_practice**, last active, stats |
| `get_category_breakdown()` | which categories customers engage with most: learners, rounds, questions, accuracy — ranked |
| `get_practice_reminders(days)` | re-engagement list: people with an email who haven't practiced in ≥ `days` days (default 7), most-lapsed first — feed to the reminder-email automation |
| `get_event_feed(limit)` | raw recent activity with the person resolved |
| `get_overview_summary(days)` | the Overview strip: rounds, questions, accuracy, learners, viewers, active days — current vs previous period |
| `get_activity_rollup(days)` | day × action × service rollup behind the Daily activity chart |
| `get_practice_report(days)` | day × bucket rounds behind the Daily practice and Naturalization tables |

### What counts as a practice round

One row in `practice_activity` is one round, but not every row is *practice*:

```
activity_type = 'practice'
AND content_type = 'question'              -- NULL = legacy, treated as question
AND (mode = 'mock' OR category is one of
     naturalization | marriage | f1 | b1b2 | asylum |
     eng_speaking | eng_reading | eng_writing)
```

Green Flags, Red Flags and Document Checklists log as practice but are reading,
not practice — about a third of all rows. A round in any other category has no
column to land in on either dashboard, so counting it made the totals
unreconcilable with the tables under them. **A learner practised; a viewer only
opened a screen** — never count `activity_type = 'view'` toward learners.

This rule lives in four places and they must move together: `get_practice_report`
(the CASE arms), `align_admin_to_dashboard.sql` (`_is_practice_round`), and in
futuresteps-dashboard, `scripts/snapshot.mjs` (`practiceBuckets`) plus
`dashboard-query.sql`.

### Two things that have bitten

**Days are America/Chicago, everywhere.** Every reader buckets on
`(created_at at time zone 'America/Chicago')::date`, and the windows are N whole
calendar days, not a rolling `now() - interval`. The dashboard snapshot bucketed
in UTC until 2026-07-23, which put anything practised after 7pm CT on the next
day and made the two products disagree on most days.

**Never cast an event prop without checking the event.** `props` is
unconstrained jsonb, so a prop name is not a type. `question_answered` writes
`correct` as a *boolean* while `practice_complete` writes it as a *number*; an
unguarded `(props->>'correct')::int` over all events took out `_person_rollup()`
and with it the whole Unified Funnel (see `fix_person_rollup_cast.sql`). Filter
on `event_name` in the same expression, not in a WHERE the planner is free to
reorder around.

## Channels

`analytics_channel()` classifies first-touch into:
**Organic Search · FB Posts · FB Ads · Direct / Word-of-mouth · Referral**.

- **FB Posts** (your real channel) = organic Facebook: `utm_source=facebook`
  *without* a paid medium, or a `facebook.com` / `l.facebook.com` referrer.
- **FB Ads** = Facebook with a paid medium (`utm_medium=cpc|paid|paidsocial`).
  Tag ad links so they're distinguishable, e.g.
  `?utm_source=facebook&utm_medium=paid&utm_campaign=<name>`.
- For **FB posts**, add `?utm_source=facebook&utm_campaign=<post>` to links you
  share so you can compare individual posts (referrer alone still classifies
  correctly if you forget).
- **Word-of-mouth** lands in *Direct* (no referrer, no utm). To measure it
  explicitly, share a tagged link like `?utm_source=referral&utm_campaign=wom`.
```
