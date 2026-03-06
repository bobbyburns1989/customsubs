# Template Price Verification — March 2026

**Date:** March 3, 2026
**Status:** ✅ Complete
**Scope:** `assets/data/subscription_templates.json` — all 260 templates audited

---

## Overview

Full audit and price correction of all 260 subscription templates. 32 services had outdated prices (reflecting 2023–early 2024 launch-era pricing). Updated via web research to current US rates as of March 2026.

---

## Pricing Convention (Established)

Going forward, all template prices follow these rules:

| Scenario | Rule |
|----------|------|
| Multi-tier service | Use the most popular paid individual tier |
| Ad-supported vs ad-free | Default to the most popular (varies per service — see notes below) |
| Monthly vs annual available | Show monthly billing rate |
| Annual-only service | Keep `defaultCycle: "yearly"` with annual price |
| Variable/dynamic pricing | Use the entry-level plan for typical users |

### Tier Decisions for Key Services

| Service | Tier Used | Rationale |
|---------|-----------|-----------|
| Netflix | Standard | Mid-tier, most popular |
| Disney+ | Standard (with ads) | Most popular by subscriber count |
| Hulu | Standard (with ads) | Lowest entry point for live content |
| Max | Standard (ad-free) | Ad-free is primary product positioning |
| Paramount+ | Essential (with ads) | Most popular entry tier |
| PlayStation Plus | Essential | Most popular; Extra/Premium are niche |
| Xbox Game Pass | Ultimate | Only tier worth subscribing to |

---

## Changes Applied — 32 Updates

### Streaming & Entertainment

| Service | Was | Now | Notes |
|---------|-----|-----|-------|
| Netflix | $15.49 | $17.99 | Standard plan price increase |
| Spotify | $10.99 | $12.99 | Individual (increased Feb 2026) |
| Disney+ | $10.99 | $11.99 | Standard with ads (tier clarification) |
| Apple TV+ | $9.99 | $12.99 | Price increase |
| Hulu | $7.99 | $11.99 | Standard with ads (price increase) |
| Max (HBO Max) | $15.99 | $18.49 | Standard ad-free (price increase) |
| Paramount+ | $11.99 | $8.99 | Essential with ads (tier switch down) |
| Peacock | $5.99 | $10.99 | Premium plan (price increase) |
| Crunchyroll | $7.99 | $13.99 | Mega Fan mid-tier (price increase) |
| Twitch Turbo | $8.99 | $11.99 | Price increase |
| FuboTV | $84.99 | $73.99 | Pro base plan |
| Sling TV | $50.99 | $45.99 | Orange or Blue base |
| AMC+ | $8.99 | $10.99 | Premium ad-free (Feb 2026 increase) |

### Productivity & Tools

| Service | Was | Now | Notes |
|---------|-----|-----|-------|
| Adobe Creative Cloud | $54.99 | $59.99 | All Apps plan |
| Microsoft 365 | $6.99 | $9.99 | Personal (April 2024 increase) |
| LinkedIn Premium | $29.99 | $39.99 | Career tier |
| 1Password | $2.99 | $3.99 | Individual (increasing further Mar 27) |
| NordPass | $1.49 | $1.99 | Individual annual effective rate |
| ExpressVPN | $12.95 | $12.99 | Monthly plan (minor correction) |

### Gaming

| Service | Was | Now | Notes |
|---------|-----|-----|-------|
| Xbox Game Pass Ultimate | $16.99 | $19.99 | Price increase (Jan 2024) |
| PlayStation Plus | $17.99 | $9.99 | Tier switch: Premium → Essential |
| EA Play | $4.99 | $5.99 | Standard individual |

### Fitness & Health

| Service | Was | Now | Notes |
|---------|-----|-----|-------|
| Calm | $14.99 | $16.99 | Premium monthly |
| ClassPass | $79.00 | $35.00 | Entry tier (15 credits/mo) |
| Noom | $60.00 | $42.00 | Monthly rate |
| Beachbody On Demand | $99.00 | $179.00 | Annual plan (BODi full — kept yearly cycle) |
| Rosetta Stone | $12.00 | $15.99 | Monthly plan |

### Finance & Other

| Service | Was | Now | Notes |
|---------|-----|-----|-------|
| Monarch Money | $14.95 | $14.99 | Minor correction |
| PocketGuard Premium | $7.99 | $12.99 | Plus monthly |
| Bumble Premium | $29.99 | $39.99 | Premium tier |
| Ring Protect | $3.99 | $4.99 | Solo camera (March 2026 increase) |
| Nest Aware | $6.00 | $10.00 | Standard plan |

---

## Intentionally Left Unchanged

**B2B/Developer tools** — pricing varies by team size and is negotiated:
HubSpot, Salesforce, Zendesk, Intercom, Mailchimp, ActiveCampaign, Typeform, SurveyMonkey, QuickBooks, Xero, FreshBooks, Shopify, Webflow, Framer, Sketch, Monday, Asana, ClickUp, Airtable, Trello, Zapier, Make

**Annual-only antivirus** (complex promotional/renewal pricing, no true monthly):
Bitdefender, McAfee, Norton 360

**AI tools** — confirmed accurate at current rates:
ChatGPT Plus ($20), Claude Pro ($20), Midjourney ($30 Standard), GitHub Copilot ($10), Perplexity Pro ($20), Google AI Pro ($19.99), Cursor ($20), Jasper ($59)

**Dating apps** (dynamic pricing by age/region — defaults are reasonable):
Tinder Gold ($39.99), Hinge Preferred ($34.99), Bumble (updated above), Match.com ($25)

**Stable prices confirmed** (no changes needed):
Apple Music ($10.99), Apple One ($19.95), iCloud+ ($2.99), Google One ($9.99), Amazon Prime ($14.99), Notion ($10), Audible ($14.95), Kindle Unlimited ($11.99), Strava ($11.99), Peloton App ($12.99), Headspace ($12.99), Duolingo Plus ($12.99), Coursera Plus ($59), NYT ($17), WSJ ($38.99), Tidal ($10.99), Discord Nitro ($9.99), Pandora Plus ($4.99), Zoom Pro ($14.99), Slack Pro ($8.75), NordVPN ($12.99), DoorDash DashPass ($9.99), Uber One ($9.99), YNAB ($14.99)

---

## Files Changed

| File | Change |
|------|--------|
| `assets/data/subscription_templates.json` | 32 `defaultAmount` values updated |

---

## Next Review

**Recommended: Q3 2026** — streaming prices are especially volatile. Services most likely to change again: Netflix, Spotify, Apple services, Xbox Game Pass.
