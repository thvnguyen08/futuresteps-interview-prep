# Interview Prep — Future Steps Services

A bilingual (English/Vietnamese) question bank quiz app for clients to practice
before their immigration interview. Covers marriage-based green card (I-485),
naturalization (N-400), asylum interviews, F-1 student visa consular
interviews, and B1/B2 visitor visa interviews. Login is optional — anyone can
practice without an account, but logging in with an email magic link syncs
flagged questions and quiz/test results across devices.

Naturalization splits into two parts, matching the real N-400 interview:

- **Civics Test** — **Study All 129 Questions** (practice the full civics
  question bank as **multiple choice**: each question shows the correct answer
  plus three distractors auto-drawn from other civics answers; picking one marks
  it right/wrong and reveals the official answer — a low-pressure way to learn
  the material), **Simulate Real Test** (a random 20-question round with a live
  per-question stopwatch; you **type your answer and Submit**, it **auto-grades**
  against the official USCIS answer and pops up the correct answer, and you get a
  pass/fail result requiring 12/20 correct, mirroring the real test), or
  **Spoken Test (Auto-Scored)** — the officer's question is read aloud, you
  answer **out loud**, and the browser's speech recognition transcribes it and
  auto-grades it (with a one-tap confirm/override). Both Simulate and Spoken feed
  the same 20-question, 12/20 pass result. The 8 civics questions whose answer
  depends on a lookup (the current President, your Senator, your Governor, etc.)
  can't be auto-graded — Study skips multiple choice for them, and Simulate/Spoken
  fall back to self-scoring. Spoken mode uses the browser Web Speech API (best in
  Chrome/Edge; the button hides where unsupported). No AI/backend and no extra
  cost — the auto-grading is keyword matching in the browser. The result screen
  also shows total time and average time per question. A fourth mode,
  **Review Missed (N)**, appears once you've missed civics questions: it quizzes
  only the ones you got wrong (self-scored reveal) and drops each from the list
  the next time you answer it correctly — adaptive, spaced-repetition-lite
  review. The missed list persists per device and syncs to your account when
  logged in.
- **English Test** — three self-scored practice sections: **Speaking**
  (common biographic questions asked in English during the interview),
  **Reading** (practice sentences built from the official USCIS reading
  vocabulary list), and **Writing** (practice sentences built from the
  official USCIS writing vocabulary list — the app reads each sentence aloud
  via the browser's text-to-speech and hides the text until you reveal it,
  mirroring the real dictation-style writing test). Each section's result
  shows a percentage and a level: Excellent (90%+), Good (70–89%), or Needs
  Practice (under 70%).

Static HTML/CSS/JS (no build step, no server) — the question bank lives in a
free Supabase (Postgres) database and is queried directly from the browser.

## SEO & installable app (PWA)

The site is tuned for discoverability and can be installed to a phone home
screen:

- **SEO** — `index.html` carries a keyword-focused title/description, canonical
  URL, Open Graph + Twitter cards (with a generated 1200×630 share image at
  `icons/og-image.png`), and **FAQ structured data** (`schema.org` `FAQPage`)
  seeded with representative marriage/asylum/F-1/B1-B2 questions so they can
  surface as rich results for the non-civics long tail. `robots.txt` +
  `sitemap.xml` point crawlers at the site and keep `admin.html` out of the
  index.
- **PWA / "Add to Home Screen"** — `manifest.webmanifest` + brand icons in
  `icons/` (192, 512, and a maskable 512) + `sw.js` (a service worker that
  caches the app shell for instant repeat loads and offline access; live
  question data always comes fresh from Supabase). `netlify.toml` sets
  cache/`Content-Type` headers so worker and manifest updates ship on the next
  visit.
- Icons/OG image were generated from the brand mark with the Pillow scripts in
  the session scratchpad; to regenerate, re-run them and copy the output into
  `icons/`. If you move to a custom domain, update the absolute URLs in
  `index.html` (canonical, `og:*`), `robots.txt`, and `sitemap.xml`.

## One-time setup

1. **Create a free Supabase project** at [supabase.com](https://supabase.com) (sign up, then "New Project").
2. **Create the table.** In the Supabase dashboard, go to **SQL Editor → New query**, paste the contents of `supabase/schema.sql`, and run it.
3. **Seed the starter questions.** Open a new query, paste the contents of `supabase/seed.sql`, and run it. This adds 180+ starter questions across marriage, naturalization, asylum, and F-1, including the full official 128-question USCIS civics test (2025 version) for naturalization.
4. **Add the B1/B2 category.** Open a new query, paste the contents of `supabase/add_b1b2.sql`, and run it once. This widens the category constraint and seeds starter B1/B2 visitor visa questions.
5. **Add the English Test categories.** Open a new query, paste the contents of `supabase/add_english_test.sql`, and run it once. This widens the category constraint again and seeds Speaking/Reading/Writing practice content.
6. **Add customer login.** Open a new query, paste the contents of `supabase/add_customer_login.sql`, and run it once. This adds the `flagged_questions` and `quiz_results` tables (both scoped to the signed-in user via row-level security) so logged-in customers' progress syncs across devices. Requires the **Email** auth provider, which is enabled by default under **Authentication → Providers** — no extra SMS/email provider or cost needed.
7. **Add the admin CRM view.** Open a new query, paste the contents of `supabase/crm_view.sql`, and run it once. This creates a `get_crm_data()` function that powers the admin page. Edit the `admin_emails` array in the SQL to list the email addresses that should have admin access. (If you added the state officials table below after already running this, re-run `crm_view.sql` — it now also returns each customer's saved state.)
8. **Add the state officials lookup.** Open a new query, paste the contents of `supabase/add_state_officials.sql`, and run it once. This adds a `state_officials` table (public read-only) mapping each state/territory to its capital, Governor, and U.S. Senators. When a signed-in customer saves their state on the account panel, the app fills in the correct answer for the three state-specific civics questions (Governor, one of your Senators, state capital) instead of a generic "look it up" pointer. **Governors and Senators change with elections — update rows in this table over time** (e.g. `update state_officials set governor = 'New Name' where code = 'TX';`, no redeploy needed).
9. **Expand the question banks and add Red Flags / Documents.** These migrations add a `content_type` column to the `questions` table (`question` | `red_flag` | `checklist`) and seed the fuller content for the "open field" categories: ~55 practice questions each plus a set of **red flags** (common mistakes officers watch for) and a **document checklist** (what to bring). In the app they appear as a per-category sub-toggle — **Practice Questions / Red Flags / Documents** — that shows automatically for any category with this content. Run each of these **exactly once** (the `content_type` column part is idempotent, but the `INSERT`s duplicate rows if re-run):
   - `supabase/add_marriage_expansion.sql`
   - `supabase/add_asylum_expansion.sql`
   - `supabase/add_f1_expansion.sql`
   - `supabase/add_b1b2_expansion.sql`
10. **Add adaptive review of missed questions.** Open a new query, paste the contents of `supabase/add_missed_questions.sql`, and run it once. This adds a `missed_questions` table (scoped to the signed-in user via row-level security), like `flagged_questions`. A civics question is added when the customer answers it wrong on the Simulate or Spoken test and removed the next time they get it right; the app's **Review Missed** civics mode quizzes only those. Logged-out customers keep the list in `localStorage` and it merges to the account on first login.
11. **Add the registration gate (lead capture).** Open a new query, paste the contents of `supabase/add_leads.sql`, and run it once. **Run this before deploying the gate** — it creates the `leads` table (anonymous visitors may INSERT, but the public key can never SELECT it — PII stays private) plus a `get_leads_data()` admin-only reader (keep its `admin_emails` array in sync with `crm_view.sql`). Visitors get **one free preview question**, then to continue (next question, switch category, or switch mode) the app requires **Name + (Email or Phone) + Location** (US state, Vietnam, or Other) and saves the lead here; they then keep practicing immediately (no email verification). The single free question keeps the page useful for SEO/first impressions while still capturing interested visitors. Logged-in users and returning visitors on the same device skip the gate. Leads appear in a **Registration Leads** table on `admin.html` (with search + CSV export). The gate fails open — if the save errors (e.g. this migration hasn't been run), the customer is still let through rather than trapped, but the lead won't be recorded, so run this migration.
12. **Get your API credentials.** Go to **Project Settings → API**. Copy the **Project URL** and the **`anon` public key**.
13. **Configure the app.** Open `script.js` and replace:
   ```js
   const SUPABASE_URL = "YOUR_SUPABASE_PROJECT_URL";
   const SUPABASE_ANON_KEY = "YOUR_SUPABASE_ANON_KEY";
   ```
   with your actual values.

## Running locally

Open `index.html` directly in a browser, or serve it with any static server, e.g.:

```bash
python3 -m http.server 8000
```

then visit `http://localhost:8000`.

## Editing the question bank later

No redeploy needed — edit rows directly in the Supabase dashboard under
**Table Editor → questions**, or run more `insert`/`update` SQL statements.

## Notes

- Without logging in, each visitor's browser remembers which questions they've flagged for review (via `localStorage`), so it persists across visits on the same device but not across devices. Logging in with an email magic link (self-signup — no password, no separate invite step) syncs flagged questions and quiz/test result history to the account instead, and merges any local flags in on first login. Logging out reverts to the local, per-device behavior.
- Login only covers quiz progress for now — there's no client case/document portal yet (e.g. application status, documents). That would need a separate table and is a bigger addition for later if wanted.
- Marriage, asylum, F-1, and B1/B2 questions are personal-history/judgment questions with no single "correct" answer, so their answer column holds **coaching tips** on how to answer well. Naturalization questions are civics questions with an **official answer** — this is the full 128-question 2025 USCIS civics test (Form M-1778, effective for Form N-400 filed on or after October 20, 2025; the officer asks 20 of the 128 and the applicant must get 12 correct). It replaced the older 2008 test (100 questions, 10 asked, 6 correct) — if you ever see other study material online referencing "100 questions," it's the outdated version. A few answers (current President, Governor, Speaker of the House, etc.) intentionally point clients to uscis.gov/citizenship/testupdates for the up-to-date fact instead of hardcoding something that will go stale.
- The English Test's Reading and Writing sentences are built only from words in the official USCIS vocabulary lists (M-1178, verified live from uscis.gov). USCIS does not publish the exact sentences used in the real test — only the vocabulary — so these are illustrative practice sentences, not verbatim test content.
- Deployed and git-backed. Live at `futuresteps-interview-prep.netlify.app`, auto-deploying on every push to `main` (same pipeline as the main `llc-web` site).
