# Prediction Masters SA — full project deployment package v4

This is a deployable **starter application and technical foundation**, not a fully operational prediction business. It includes a React/Vite public website, Supabase authentication, private research drafts, independent review/publishing, database schema, row-level security policies, audit logging and deployment instructions.

## Recommended stack
- Vercel: public website hosting and continuous deployment.
- GitHub: source-code repository connected to Vercel.
- Supabase: PostgreSQL database, authentication and access policies.

## Quick start
1. Extract this ZIP on a computer.
2. Create a private GitHub repository and upload the contents of this folder (not the ZIP file itself).
3. Create a Supabase project.
4. In Supabase SQL Editor, run `supabase/migrations/0001_initial_schema.sql`, then `supabase/migrations/0002_independent_review.sql`.
5. Create two named administrator accounts in Supabase Authentication. Disable public sign-ups.
6. For each administrator, copy the Auth user UUID and run the matching insert from `docs/ADMIN_BOOTSTRAP.sql` (repeat with each UUID).
7. Copy `.env.example` to `.env.local` and enter the Supabase Project URL and publishable/anon key. Never use the service-role key in browser code.
8. In Vercel, import the GitHub repository. Framework: Vite; Build command: `npm run build`; Output directory: `dist`.
9. Add `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` (or publishable key value) in Vercel Project Settings → Environment Variables, then redeploy.

Read `docs/DEPLOYMENT_AND_SECURITY_GUIDE.md` before making the site public.

## Local test
Requires Node.js 20+:
```bash
npm install
npm run dev
```
Production build test:
```bash
npm run build
```

## Important scope boundaries
- No live sports/racing/lottery feeds are connected.
- No odds ingestion, betting operator integration, payment processing, user wallet, stake handling, lottery ticket sales, private pools or payout features.
- No automated prediction engine is connected to this website.
- No live results settlement, automated performance claims, email delivery, correction-management UI or source-registry UI is included yet.
- Lottery pages are informational only; random lottery draws cannot be reliably predicted from historical draws.
- Live/special-market content must not be published unless a provider contract permits commercial use and redistribution and the data is sufficiently fresh.
- The app's reviewer workflow requires at least two authorised admin accounts. One person cannot approve their own draft.
- Before commercial launch, obtain South African legal review, verify company/member authority, complete POPIA/privacy and security work, and verify data-provider rights.

Do not paste credentials into source files or send passwords/API secrets in chat.
