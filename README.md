# Interview Prep — Future Steps Services

A bilingual (English/Vietnamese) question bank quiz app for clients to practice
before their immigration interview. Covers marriage-based green card (I-485),
naturalization (N-400), asylum interviews, F-1 student visa consular
interviews, and B1/B2 visitor visa interviews. Login is optional — anyone can
practice without an account, but logging in with an email magic link syncs
flagged questions and quiz/test results across devices.

Naturalization splits into two parts, matching the real N-400 interview:

- **Civics Test** — **Study All 128 Questions** (practice the full civics
  question bank) or **Simulate Real Test** (a random 20-question round with
  a live per-question stopwatch, self-scored "I Knew It" / "I Missed It"
  buttons, and a pass/fail result requiring 12/20 correct, mirroring the real
  test). The result screen also shows total time and average time per
  question.
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

## One-time setup

1. **Create a free Supabase project** at [supabase.com](https://supabase.com) (sign up, then "New Project").
2. **Create the table.** In the Supabase dashboard, go to **SQL Editor → New query**, paste the contents of `supabase/schema.sql`, and run it.
3. **Seed the starter questions.** Open a new query, paste the contents of `supabase/seed.sql`, and run it. This adds 180+ starter questions across marriage, naturalization, asylum, and F-1, including the full official 128-question USCIS civics test (2025 version) for naturalization.
4. **Add the B1/B2 category.** Open a new query, paste the contents of `supabase/add_b1b2.sql`, and run it once. This widens the category constraint and seeds starter B1/B2 visitor visa questions.
5. **Add the English Test categories.** Open a new query, paste the contents of `supabase/add_english_test.sql`, and run it once. This widens the category constraint again and seeds Speaking/Reading/Writing practice content.
6. **Add customer login.** Open a new query, paste the contents of `supabase/add_customer_login.sql`, and run it once. This adds the `flagged_questions` and `quiz_results` tables (both scoped to the signed-in user via row-level security) so logged-in customers' progress syncs across devices. Requires the **Email** auth provider, which is enabled by default under **Authentication → Providers** — no extra SMS/email provider or cost needed.
7. **Add the admin CRM view.** Open a new query, paste the contents of `supabase/crm_view.sql`, and run it once. This creates a `get_crm_data()` function that powers the admin page. Edit the `admin_emails` array in the SQL to list the email addresses that should have admin access.
8. **Get your API credentials.** Go to **Project Settings → API**. Copy the **Project URL** and the **`anon` public key**.
9. **Configure the app.** Open `script.js` and replace:
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
