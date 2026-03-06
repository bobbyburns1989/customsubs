# Smart Insights — Analytics Optimization Feature

**Status**: ✅ Complete
**Date**: March 6, 2026
**Version**: v1.4.3+47
**Relevant to**: Developers

Adds a "Smart Insights" card to the bottom of the Analytics screen surfacing four 100% offline, rule-based subscription optimization insights.

---

## Overview

Users with many subscriptions often have redundant services or are paying more than necessary. Smart Insights surfaces actionable, honest recommendations without any network calls, AI, or external data — fully consistent with the app's offline-first, privacy-first architecture.

The card hides itself entirely when no insights apply. No empty state is ever shown.

---

## The Four Insights

### 1. Overlap / Duplicate Detection

**Logic**: Matches `sub.iconName?.toLowerCase()` against hardcoded service group sets. Flags when threshold is reached:

| Group | Threshold | Rationale |
|-------|-----------|-----------|
| Music streaming | 2+ | Two music services is always redundant |
| Video streaming | 3+ | 2 is common (e.g. Netflix + Disney); 3+ is worth surfacing |
| Cloud storage | 3+ | 2 cloud services is reasonable; 3+ is excess |

**Service groups** (in `smart_insights_controller.dart`):
- `_videoServices`: netflix, hulu, disney, max, peacock, paramount, apple_tv, tubi, sling, funimation, crunchyroll, mubi, youtube_premium, britbox, acorn, shudder
- `_musicServices`: spotify, apple_music, youtube_music, amazon_music, tidal, pandora, deezer, soundcloud
- `_cloudServices`: icloud, google_one, google_drive, dropbox, onedrive, box

Custom subscriptions (no `iconName`) are skipped — only template-based subs are matched.

---

### 2. Annual Billing Savings Calculator

**Logic**: Filters active subs where `cycle == SubscriptionCycle.monthly`. Sums their total monthly spend in the primary currency. Applies 15%–20% discount range (industry standard).

**Formula**:
```
minSavings = totalMonthlySpend × 12 × 0.15
maxSavings = totalMonthlySpend × 12 × 0.20
```

Displayed as `"Est. save $X–$Y/year"`. Always labeled with a disclaimer: *"Estimated — check provider for exact annual pricing."*

Returns `null` (row hidden) when no monthly-cycle subs exist.

---

### 3. Bundle Opportunity Detection

**Data source**: `assets/data/bundles.json` — 20 curated bundle definitions. Parsed once and cached at the module level (`_cachedBundles`). Covered by the existing `assets/data/` wildcard in `pubspec.yaml`.

**Bundle JSON structure**:
```json
{
  "id": "apple_one_individual",
  "name": "Apple One Individual",
  "amount": 19.95,
  "currency": "USD",
  "components": ["apple_music", "apple_tv", "icloud", "apple_arcade"],
  "minComponentsRequired": 2,
  "description": "Apple Music, TV+, Arcade & iCloud+",
  "url": "https://www.apple.com/apple-one/"
}
```

**Bundles included** (~20):
- Apple One Individual / Family
- Disney Bundle Duo Basic / Premium / Trio Basic / Premium
- YouTube Premium Family
- Max + Discovery+
- Microsoft 365 Family + OneDrive
- Amazon Prime (video + music + kindle)
- Google One 2TB
- Hulu + Live TV
- Paramount+ with Showtime
- Xbox Game Pass Ultimate
- PlayStation Plus Premium
- Adobe Creative Cloud All Apps
- Verizon +play Bundle

**Matching logic**:
1. Build `userIconNames` set from all active subs' `iconName` values
2. For each bundle, find matched components: `bundle.components` ∩ `userIconNames`
3. Skip if `matchedComponents.length < bundle.minComponentsRequired`
4. Sum the user's current cost for those matched components (converted to primary currency)
5. Convert bundle price from USD to primary currency
6. Only show if `currentCost - bundleAmount > 0` (real savings)
7. Sort by savings descending

The bundle detail sheet includes a "Check current pricing" button using `url_launcher` (already a project dependency).

---

### 4. High-Spend Category Flag

**Logic**: Groups active subs by `SubscriptionCategory`. For each category, calculates what fraction of total monthly spend it represents. Flags the category with the highest percentage if it exceeds **40%**.

- The `other` category is excluded (catch-all, not actionable)
- Only the single highest-percentage category is surfaced (not multiple)
- Returns `null` when no category meets the threshold

---

## Architecture

### Provider

```dart
// lib/features/analytics/smart_insights_controller.dart
final smartInsightsProvider = FutureProvider.autoDispose<SmartInsightsData>((ref) async {
  final repository = await ref.watch(subscriptionRepositoryProvider.future);
  final subs = repository.getAllActive();
  final primaryCurrency = ref.watch(primaryCurrencyProvider);
  final bundles = await _loadBundles(); // module-level cache
  ...
});
```

Uses functional `FutureProvider` (not `@riverpod` annotation) — **no `build_runner` step needed**.

### Data Models

All defined in `smart_insights_controller.dart`:
- `SmartInsightsData` — container with `hasAnyInsight` getter
- `OverlapInsight` — groupLabel, names, combinedMonthly
- `AnnualSavingsInsight` — minSavings, maxSavings, subscriptionCount
- `BundleInsight` — bundleName, bundleAmount, currentCost, potentialSavings, description, url
- `HighSpendInsight` — categoryName, percentage, monthlyAmount, subscriptionNames

### UI

`SmartInsightsCard` (`lib/features/analytics/widgets/smart_insights_card.dart`):
- `ConsumerWidget` watching `smartInsightsProvider`
- Returns `SizedBox.shrink()` on loading, error, or no insights
- Each insight type has a dedicated `_InsightRow` (tappable) and `_BottomSheet` (detail)
- Color coding: warning amber for overlap/high-spend; primary green for savings/bundles

### Analytics Screen Integration

`analytics_screen.dart` changes:
- Import added for `SmartInsightsCard`
- Animation list: `List.generate(5, ...)` → `List.generate(6, ...)`
- `SmartInsightsCard()` added at end of card column (always mounted, manages own visibility)

---

## Files Changed

| File | Type | Description |
|------|------|-------------|
| `assets/data/bundles.json` | **New** | 13 bundle definitions (post-review: 7 invalid entries removed/fixed) |
| `lib/features/analytics/smart_insights_controller.dart` | **New** | Provider, all logic, all data models |
| `lib/features/analytics/widgets/smart_insights_card.dart` | **New** | Card UI + 4 detail bottom sheets |
| `lib/features/analytics/analytics_screen.dart` | **Modified** | Import + animation slot + card wired in |

No `pubspec.yaml` changes — `assets/data/` wildcard already covers `bundles.json`, and `url_launcher` was already a dependency.

---

## Verification Scenarios

| Scenario | Expected |
|----------|---------|
| Add Spotify + Apple Music | Overlap row: "2 music streaming services" |
| Add Netflix + Max + Disney+ | Overlap row: "3 video streaming services · $X/mo" |
| Add Disney+ ($11.99) + Hulu ($9.99) | Bundle row: "Disney Bundle Trio Basic · save ~$X/mo" |
| All subs on yearly cycle | Annual savings row hidden |
| 5 entertainment subs = 65% of spend | High-spend row: "Entertainment = 65% of spend" |
| Remove all subs | Entire Smart Insights card invisible |
| No insights triggered | Card returns SizedBox.shrink() — no empty card shown |
| Tap bundle row | Bottom sheet with price comparison + "Check current pricing" button |

---

## Maintenance Notes

- **Bundle data updates**: Edit `assets/data/bundles.json` and ship with the next app release. No code changes required unless structure changes.
- **⚠️ Always use `iconName`, NOT template `id`**: When adding components to `bundles.json` or service group sets, look up the `"iconName"` field in `subscription_templates.json` — it is often different from the template `"id"` (e.g. id=`amazon_prime`, iconName=`amazon`; id=`microsoft_365`, iconName=`microsoft`; id=`youtube_premium`, iconName=`youtube`).
- **Service groups**: Add new `iconName` values to `_videoServices`, `_musicServices`, or `_cloudServices` constants in `smart_insights_controller.dart` as new templates are added.
- **Bundle prices**: Review quarterly — streaming bundle prices change frequently. Note the disclaimer in the UI ("Check current pricing") means minor staleness is acceptable.
- **Overlap thresholds**: Adjust `_videoOverlapThreshold`, `_musicOverlapThreshold`, `_cloudOverlapThreshold` constants if user feedback suggests different sensitivity.

---

## Post-Review Bug Fixes (same session)

Five bugs were found and fixed immediately after initial implementation via cross-referencing against `subscription_templates.json`:

### iconName Mismatches — Silent Logic Failures

| Location | Wrong value | Correct value | Impact |
|----------|-------------|---------------|--------|
| `_videoServices` | `'youtube_premium'` | `'youtube'` | YouTube Premium never detected in video overlap |
| `_videoServices` | `'max'` | `'hbo'` | Max never detected in video overlap |
| `bundles.json` — YouTube Premium Family | `"youtube_premium"` | `"youtube"` | Bundle never triggered |
| `bundles.json` — Max + Discovery+ | `"max"` | `"hbo"` | Bundle never triggered |
| `bundles.json` — Max + Discovery+ | `"discovery_plus"` | `"discovery"` | Bundle never triggered |
| `bundles.json` — Amazon Prime | `"amazon_prime"` | `"amazon"` | Bundle never triggered |
| `bundles.json` — Amazon Prime | `"amazon_kindle"` | `"kindle"` | Bundle never triggered |

**Root cause**: Template `id` values (e.g. `amazon_prime`, `microsoft_365`) differ from `iconName` values (e.g. `amazon`, `microsoft`). Always verify against `iconName` field in `subscription_templates.json`, not the template `id`.

### Bundles Removed (no multi-template scenario)

Removed 4 bundles that could never trigger because their component services are tracked as a single template (not separate subscriptions):
- Xbox Game Pass Ultimate — one template (`iconName: xbox`)
- PlayStation Plus Premium — one template (`iconName: playstation`)
- Microsoft 365 Family — one relevant template, no OneDrive template exists
- Paramount+ with Showtime — no Showtime template exists

### Other Fixes

| Bug | Fix |
|-----|-----|
| Unused `fmtLong` variable in `_showAnnualSavingsSheet` | Removed — eliminates analyzer warning |
| `_BottomSheet` content not scrollable | Wrapped content `Padding` in `SingleChildScrollView` |
| Press highlight bleeds outside card radius | Added `clipBehavior: Clip.antiAlias` to card `Container` |

---

## See Also

- [`docs/architecture/overview.md`](../architecture/overview.md) — Offline-first architecture
- [`lib/features/analytics/analytics_controller.dart`](../../lib/features/analytics/analytics_controller.dart) — Existing analytics controller
- [`assets/data/bundles.json`](../../assets/data/bundles.json) — Bundle definitions
