# Interview Prep — Future Steps Services

A bilingual (English/Vietnamese) question bank quiz app for clients to practice
before their immigration interview. Covers marriage-based green card (I-485),
naturalization (N-400), asylum interviews, and F-1 student visa consular
interviews. No login required.

Static HTML/CSS/JS (no build step, no server) — the question bank lives in a
free Supabase (Postgres) database and is queried directly from the browser.

## One-time setup

1. **Create a free Supabase project** at [supabase.com](https://supabase.com) (sign up, then "New Project").
2. **Create the table.** In the Supabase dashboard, go to **SQL Editor → New query**, paste the contents of `supabase/schema.sql`, and run it.
3. **Seed the starter questions.** Open a new query, paste the contents of `supabase/seed.sql`, and run it. This adds 180+ starter questions across all four categories, including the full official 128-question USCIS civics test (2025 version) for naturalization.
4. **Get your API credentials.** Go to **Project Settings → API**. Copy the **Project URL** and the **`anon` public key**.
5. **Configure the app.** Open `script.js` and replace:
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

- No user accounts or login. Progress isn't synced anywhere, but each visitor's browser remembers which questions they've flagged for review (via `localStorage`), so it persists across visits on the same device.
- Marriage, asylum, and F-1 questions are personal-history/judgment questions with no single "correct" answer, so their answer column holds **coaching tips** on how to answer well. Naturalization questions are civics questions with an **official answer** — this is the full 128-question 2025 USCIS civics test (Form M-1778, effective for Form N-400 filed on or after October 20, 2025; the officer asks 20 of the 128 and the applicant must get 12 correct). It replaced the older 2008 test (100 questions, 10 asked, 6 correct) — if you ever see other study material online referencing "100 questions," it's the outdated version. A few answers (current President, Governor, Speaker of the House, etc.) intentionally point clients to uscis.gov/citizenship/testupdates for the up-to-date fact instead of hardcoding something that will go stale.
- Not deployed yet. When ready to host, this can follow the same pattern as the main `llc-web` site: `git init`, push to a new GitHub repo, and connect it to a new Netlify site for auto-deploy on push.
