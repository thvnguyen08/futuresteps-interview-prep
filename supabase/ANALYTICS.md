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
| `practice_start` | app | `{ category, mode }` | a practice round begins |
| `practice_complete` | app | `{ category, mode, content_type, correct, total }` | round finished — **drives Activated/Active** |
| `view` | app | `{ category, content_type }` | browsed content without practicing |

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
