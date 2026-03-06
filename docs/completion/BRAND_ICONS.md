# Brand Icons — Implementation Complete

**Status**: ✅ Complete (updated March 2026)
**Date**: March 3, 2026 | **Last updated**: March 6, 2026
**Version**: v1.4.0+

---

## Summary

Replaced generic Material Design icons with real brand logos for all 290 subscription
templates. Three-tier fallback: local SVG asset → SimpleIcons font icon → letter avatar.

**Current coverage (0 letter avatars remaining):**
- **174 local SVG lettermarks** in `assets/logos/` — services not in SimpleIcons (trademark
  removals, niche/regional services, fitness, telehealth, meal kits, etc.)
- **~115 SimpleIcons** — mainstream services (Netflix, Spotify, Discord, YouTube, etc.)
  use the real brand icon from the `simple_icons` font package
- **0 letter avatar fallbacks** — all gaps filled as of March 6, 2026

---

## Changes

### New files
- `lib/core/widgets/subscription_icon.dart` — reusable widget, single source of
  truth for all icon rendering across the app
- `assets/logos/disney.svg`, `hulu.svg`, `microsoft.svg`, `adobe.svg`,
  `linkedin.svg`, `xbox.svg`, `nintendo.svg`, `bumble.svg` — bundled brand logos

### Modified files
- `pubspec.yaml` — added `simple_icons: ^14.6.1`, `flutter_svg: ^2.0.0`, `assets/logos/`
- `lib/core/utils/service_icons.dart` — rewritten; maps template `iconName` values
  to `SimpleIcons` constants; legacy name-based fallback preserved
- `lib/features/home/home_screen.dart` — updated 3 tile types (upcoming,
  paused, later section)
- `lib/features/subscription_detail/widgets/header_card.dart` — detail header
- `lib/features/add_subscription/widgets/template_grid_item.dart` — template grid
- `lib/features/add_subscription/widgets/subscription_preview_card.dart` — live
  preview + added optional `iconName` prop

---

## Architecture

### Icon resolution priority (in `SubscriptionIcon`)
1. `iconName` (from template JSON) → `ServiceIcons.getIconForIconName()`
2. `name` (display string) → `ServiceIcons.getIconByName()`
3. First letter of `name` → colored letter avatar

### Display contexts

| Location | Size | Shape |
|---|---|---|
| Home upcoming tile | 48px | Circle |
| Home paused tile | 48px | Circle, 50% opacity |
| Home later tile | 40px | Circle, 75% opacity |
| Template grid | 56px | Circle |
| Subscription detail header | 80px | Rounded rect (16px radius) |
| Add subscription live preview | 48px | Circle |

Hero animation tags (`'subscription-icon-\$id'`) are preserved on all tiles and
the detail header, so shared-element transitions still work.

---

## Coverage

~80 services mapped. Key ones confirmed against `simple_icons v14.6.1`:

**Streaming / Music**: Netflix, Spotify, YouTube, Apple Music, Apple TV+, HBO,
Crunchyroll, Tidal, Twitch, Pandora

**Apple**: Apple Music, Apple TV+, Apple Arcade, iCloud

**AI tools**: ChatGPT (→ OpenAI icon), Claude, Perplexity

**Productivity**: Notion, Figma, Canva, Sketch, Framer, Miro, Loom, Airtable,
Trello, Asana, ClickUp, Linear, Basecamp, Slack, Zoom, Discord, Grammarly,
Webflow, Zapier, Typeform, Calendly, Intercom, HubSpot, Salesforce, Zendesk,
SurveyMonkey, Squarespace, Shopify, Mailchimp

**Developer**: GitHub, JetBrains, Replit

**Finance / Security**: Coinbase, Dashlane, NordVPN, ExpressVPN, Xero,
Quickbooks, 1Password

**Gaming**: PlayStation, EA, Ubisoft

**Fitness / Education**: Strava, Peloton, Headspace, Duolingo, Coursera,
Skillshare

**News / Reading**: Medium, Substack, New York Times

**Social / Dating**: Snapchat, X (Twitter), Patreon, OnlyFans, Tinder

**Retail / Delivery**: Target, Walmart, Amazon, Instacart, DoorDash, Uber,
Tesla, Ring, HelloFresh

**Streaming (TV)**: Paramount+ (→ `paramountplus`), Peacock (→ `nbc`), FuboTV

**Audiobooks**: Audible

**AI Tools (extended)**: ChatGPT (→ OpenAI), Claude, Perplexity, ElevenLabs

**Automation**: Make.com

---

## Bundled SVG logos (trademark removals covered)

11 brands now have hand-crafted SVG logos bundled in `assets/logos/` (no downloads needed):

| Brand | File | Design | Reason for local SVG |
|---|---|---|---|
| Disney+ | `assets/logos/disney.svg` | #113CCF blue, white "D+" | Trademark removal |
| Hulu | `assets/logos/hulu.svg` | #1CE783 green, white "h" | Trademark removal |
| Microsoft | `assets/logos/microsoft.svg` | white bg, 4 Windows squares | Trademark removal |
| Adobe | `assets/logos/adobe.svg` | #FA0F00 red, white "A" | Trademark removal |
| LinkedIn | `assets/logos/linkedin.svg` | #0077B5 blue, white "in" | Trademark removal |
| Xbox | `assets/logos/xbox.svg` | #107C10 green, white "X" | Trademark removal |
| Nintendo | `assets/logos/nintendo.svg` | #E4000F red, white "N" | Trademark removal |
| Bumble | `assets/logos/bumble.svg` | #FFC629 yellow, dark "B" | Trademark removal |
| ESPN | `assets/logos/espn.svg` | #FF0033 red, white "ESPN" | Not in Simple Icons |
| Hinge | `assets/logos/hinge.svg` | #FF0075 pink, white "H" | Not in Simple Icons |
| SiriusXM | `assets/logos/siriusxm.svg` | #0036A0 blue, white "SXM" | Not in Simple Icons |

**Batch 6 (March 6, 2026) — zero-coverage gap fills:**

| Brand | File | Design | Reason |
|---|---|---|---|
| Arlo Secure | `arlo.svg` | #1DB4B4 teal, white "AR" | Not in Simple Icons |
| ActiveCampaign | `activecampaign.svg` | #356AE6 blue, white "AC" | Not in Simple Icons |
| Care.com | `care.svg` | #E31837 red, white "CA" | Not in Simple Icons |
| Cocktail | `cocktail.svg` | #8B5CF6 purple, white "CK" | Not in Simple Icons |
| Cocotique | `cocotique.svg` | #E91E8C pink, white "CO" | Not in Simple Icons |
| DHC Skincare | `dhc.svg` | #C8102E red, white "DHC" | Not in Simple Icons |
| FreshBooks | `freshbooks.svg` | #1DA462 green, white "FB" | Not in Simple Icons |
| Garmin | `garmin.svg` | #007DC5 blue, white "G" | Not in Simple Icons |
| Hemper | `hemper.svg` | #2D6A4F dark green, white "HE" | Not in Simple Icons |
| LingoKids | `lingokids.svg` | #FF6B35 orange, white "LK" | Not in Simple Icons |
| Shaker | `shaker.svg` | #FF6B35 orange, white "SK" | Not in Simple Icons |
| Shine | `shine.svg` | #8B5CF6 purple, white "SH" | Not in Simple Icons |

---

## Adding a logo for a new brand (local SVG)

For any brand not in Simple Icons:

1. Create `{iconName}.svg` — 100×100 viewBox, full brand-color background, white icon/letter
2. Drop it in `assets/logos/`
3. Add (or uncomment) the iconName in `_localLogoIconNames` in
   `lib/core/utils/service_icons.dart`
4. Run `flutter pub get`

```dart
// lib/core/utils/service_icons.dart
static const Set<String> _localLogoIconNames = {
  'disney',     // assets/logos/disney.svg — already bundled
  'hinge',      // assets/logos/hinge.svg — after adding the file
  // ...
};
```

## Adding a SimpleIcons mapping (for brands already in the package)

1. Find the exact constant name:
   ```bash
   grep -i "brandname" ~/.pub-cache/hosted/pub.dev/simple_icons-14.6.1/lib/src/icon_data.g.dart
   ```
2. Add an entry to `_iconMap` in `lib/core/utils/service_icons.dart`:
   ```dart
   'iconname_from_json': SimpleIcons.constantname,
   ```
