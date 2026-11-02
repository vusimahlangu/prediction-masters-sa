# Prediction Masters SA v3 — deployment and security guide

## What this package delivers
- Public React/Vite website.
- Private administrator sign-in using Supabase Auth.
- Admin-only research draft creation and management.
- Database schema with Row Level Security (RLS).
- Public read-only view containing only approved/published research.
- Approval RPC with reviewer, timestamp and audit record.
- Withdraw action and audit logging.
- No public registration, betting, stakes, ticket sales, pool operation or payments.

## Important status
This is a full-stack starter project and database design. It is **not live or connected** until you create a Supabase project, apply SQL, create the admin user, configure environment variables and deploy it. No API keys, passwords or database credentials are included. The contact details, business terms and legal documents also need owner review.

## A. Create Supabase project
1. Create a project at https://supabase.com/.
2. Choose a strong database password and store it in a password manager.
3. In Project Settings -> API, copy the Project URL and publishable/anon key.
4. Never copy the `service_role` key into this frontend project.
5. Open SQL Editor and run `supabase/migrations/0001_initial_schema.sql`, then `supabase/migrations/0002_independent_review.sql`.
6. In Authentication settings, disable public sign-ups. Only administrator accounts created by the owner should be allowed; create at least two administrators for independent review.
7. Create the owner's Auth user from Authentication -> Users. Verify the email and use a strong unique password plus MFA if available.
8. Copy the Auth user's UUID and replace the placeholder in `docs/ADMIN_BOOTSTRAP.sql`; run that statement in SQL Editor.
9. Test that an unauthenticated browser cannot read `research_records`, insert, update, delete or call approval.
10. Test that a signed-in non-admin user cannot access admin tables. Do not create non-admin public accounts in this first release.

## B. Configure local project
1. Install Node.js 20 LTS or newer.
2. Extract this ZIP and open a terminal in the project folder.
3. Copy `.env.example` to `.env.local`.
4. Set `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` to the project's URL and publishable/anon key.
5. Run:
   ```bash
   npm install
   npm run dev
   ```
6. Visit the local URL shown by Vite.
7. Test the public site and admin sign-in.
8. Run a production build:
   ```bash
   npm run build
   npm run preview
   ```

## C. Deploy to Vercel
1. Create a private GitHub repository.
2. Upload the project, excluding `.env` and `node_modules`.
3. Import the repository into Vercel.
4. Framework preset: Vite.
5. Build command: `npm run build`.
6. Output directory: `dist`.
7. Add `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` as Vercel environment variables for Production and Preview as appropriate.
8. Deploy and test the public site and private admin login.
9. Configure a custom domain only after legal, privacy, security and content review.

## D. Administrator workflow
1. Sign in using the owner's Auth account.
2. Open Administrator dashboard.
3. Create a research draft with exact event, market, selection, source URL, source checked time and methodology.
4. Save the draft. It remains private.
5. Review all facts, market settlement rules, freshness, method limitations and responsible wording.
6. Submit the draft for review. A different authorised administrator must then select Approve & publish after a separate quality check. The database function sets reviewer and publication timestamps and writes an audit record.
7. Public site reads from `predictions_public`, which contains only published records.
8. Use Withdraw to remove a published record from public display. For corrections, preserve the original and create a correction record (future UI enhancement; do not silently overwrite).

## E. Security checklist before public release
- Keep the service-role key out of frontend, GitHub, Vercel client variables and all user-facing files.
- Keep public sign-ups disabled.
- Enforce MFA on administrator accounts.
- Use a unique password and password manager.
- Restrict Supabase project access to trusted owners only.
- Test RLS using anonymous, authenticated non-admin and admin sessions.
- Review Supabase Auth email confirmation, rate limits and allowed redirect URLs.
- Set backups and test restoration.
- Configure domain HTTPS and security headers at hosting layer.
- Monitor auth logs and database audit logs.
- Do not store identity numbers, bank details, passwords, payment details or sensitive personal data in research records.
- Use the enforced second-person review workflow for publication.
- Have a security professional review the system before storing customer data or monetising.

## F. Important technical caveat about the first admin
The `admin_users` table is protected by RLS and has no public self-registration route. The bootstrap SQL is a privileged manual operation. Only run it for the verified administrators’ Auth UUIDs. Keep Supabase project owner accounts protected with MFA.

## G. Data integrations
This release intentionally does not scrape or connect to bookmaker websites or regulator databases. Add only providers that give written permission for the exact API access, commercial use, caching, derivative calculations and display/redistribution required. Use official public links for verification where no API exists. The NGB's operator list is not assumed to be a public API.

## H. South African legal and privacy gate
Before public predictions, paid tips, subscriptions, affiliate promotions or other gambling-related commercial activities, obtain written advice from a South African gambling-law specialist on the exact model and advertising. Review POPIA, privacy notice, retention, deletion, security safeguards, complaints and consumer terms. The platform is intended as independent information only; it must not accept stakes, place bets, sell lottery tickets, operate pools or distribute winnings without separate legal advice and authorisation.

## I. Known limitations / items for next iteration
- Two-person approval is enforced by the v4 database function. A separate role hierarchy (researcher, reviewer, administrator) and MFA enforcement remain future enhancements.
- Corrections table exists but no correction-management UI yet.
- Source registry exists in SQL but source-management UI is not yet built.
- No model execution, sports feed, odds feed, horse-racing feed, lottery results feed, automated settlement or payments.
- No contact form submission endpoint.
- The probability field is optional and must only be populated from a documented, tested method.
- Audit log is internal and not a substitute for independent backup or tamper-evident retention.

This is a technical implementation package, not a legal opinion, licence, production security certification or completed deployment.


## v4 independent approval control

The v4 application has a two-person publication workflow. The author saves a draft and submits it for review. A second authorised administrator must approve it. The SQL migration `0002_independent_review.sql` replaces the approval function and rejects self-approval. Create at least two administrator accounts before testing publication.

## Production launch gates

Before public commercial operation, complete: (1) written legal review of South African gambling-adjacent advertising and commercial model; (2) POPIA privacy notice, lawful basis, retention schedule, data-subject process and security safeguards; (3) written data-provider permission for commercial display, derived outputs, caching and redistribution; (4) source registry and freshness/withdrawal procedures; (5) model validation and backtesting; (6) accessibility, mobile, browser and security testing; (7) custom domain, monitoring, backups and incident response.

## Coverage statement

The public service catalogue describes South African and international football, multi-sport analysis, horse racing, lottery information, pools education and live/special-market research. Listing a desk does not mean that data is connected or that predictions are currently produced. Publish only verified, timestamped material that has passed source-rights and editorial review.
