# Implementation checklist

## Phase 1 — deploy the controlled public shell
- [ ] Create private GitHub repository.
- [ ] Create Supabase project and apply both migrations in order.
- [ ] Create two administrator users and bootstrap both UUIDs.
- [ ] Disable public sign-ups and verify admin access.
- [ ] Import repository into Vercel and set environment variables.
- [ ] Verify public site loads on mobile and desktop.
- [ ] Verify anonymous visitor cannot access private research tables.
- [ ] Verify draft is invisible publicly, author cannot approve, second admin can approve, withdrawal removes it from public listing.

## Phase 2 — editorial and compliance controls
- [ ] Add source registry management interface.
- [ ] Add correction and public correction-notice interface.
- [ ] Add role separation (researcher, reviewer, administrator) and MFA enforcement.
- [ ] Add publication checklist and source-rights approval gate.
- [ ] Publish privacy notice, terms, responsible-use notice and contact channel after legal review.

## Phase 3 — licensed data and model services
- [ ] Select data provider only after written commercial display/redistribution permission.
- [ ] Build server-side ingestion (never put provider secret keys in browser code).
- [ ] Store provider, source URL/reference, retrieval timestamp, event timestamp and freshness status.
- [ ] Build normalized competition/team/event/market schemas.
- [ ] Build and validate sport-specific models; do not use illustrative model inputs as real forecasts.
- [ ] Add monitoring, retries, rate limits, stale-data suppression and audit trails.

## Phase 4 — controlled commercial launch
- [ ] Independent South African legal opinion on business model, advertising, subscriptions and affiliate arrangements.
- [ ] POPIA impact/security assessment and incident response plan.
- [ ] Terms, privacy, retention and complaint/correction processes.
- [ ] Security review, backup restore test, accessibility and load testing.
- [ ] Domain, email, analytics with privacy controls, uptime monitoring.
- [ ] Written sign-off by owner and independent reviewer.
