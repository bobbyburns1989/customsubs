# CLAUDE.md — CustomSubs

## 📚 Documentation Quick Reference

**This file = essential rules only.** For implementation details, follow the links below.

### 🎯 Start Here
- **New to this project?** Read this file + [`docs/architecture/overview.md`](docs/architecture/overview.md)
- **Implementing a feature?** See [`docs/guides/adding-a-feature.md`](docs/guides/adding-a-feature.md)
- **Working with state?** See [`docs/architecture/state-management.md`](docs/architecture/state-management.md)

### 🔧 Implementation Guides
| Task | Documentation |
|------|--------------|
| **Notifications (CRITICAL)** | [`docs/guides/working-with-notifications.md`](docs/guides/working-with-notifications.md) |
| **Data models & HiveFields** | [`docs/architecture/models.md`](docs/architecture/models.md) |
| Data layer (Hive, repos) | [`docs/architecture/data-layer.md`](docs/architecture/data-layer.md) |
| IAP & Premium (RevenueCat) | [`docs/guides/iap-and-premium.md`](docs/guides/iap-and-premium.md) |
| Adding a new feature | [`docs/guides/adding-a-feature.md`](docs/guides/adding-a-feature.md) |
| State management patterns | [`docs/architecture/state-management.md`](docs/architecture/state-management.md) |
| Forms and validation | [`docs/guides/forms-and-validation.md`](docs/guides/forms-and-validation.md) |
| Multi-currency support | [`docs/guides/multi-currency.md`](docs/guides/multi-currency.md) |
| Animations & Polish | [`docs/design/MICRO_ANIMATIONS.md`](docs/design/MICRO_ANIMATIONS.md) |
| Analytics, crash reporting & events | [`docs/guides/analytics-and-tracking.md`](docs/guides/analytics-and-tracking.md) |

### 📐 Architecture & Design
| Topic | Documentation |
|-------|--------------|
| Architecture overview | [`docs/architecture/overview.md`](docs/architecture/overview.md) |
| Design system (colors, typography) | [`docs/architecture/design-system.md`](docs/architecture/design-system.md) |
| Architectural decisions (ADRs) | [`docs/decisions/`](docs/decisions/) |

### 📋 Templates & Examples
| Template | File |
|----------|------|
| Feature implementation checklist | [`docs/templates/feature-template.md`](docs/templates/feature-template.md) |
| Screen with controller (annotated) | [`docs/templates/screen-with-controller.dart`](docs/templates/screen-with-controller.dart) |
| Form screen (annotated) | [`docs/templates/form-screen.dart`](docs/templates/form-screen.dart) |

### ⚡ Quick Reference
- **Cheat sheet**: [`docs/QUICK-REFERENCE.md`](docs/QUICK-REFERENCE.md)
- **Feature specs (v1, all complete)**: [`docs/archive/feature-specs-v1.md`](docs/archive/feature-specs-v1.md)

---

## Project Overview

**CustomSubs** is a privacy-first, offline-only subscription tracker for iOS and Android (Flutter). It helps users track recurring subscriptions, get reliable billing reminders, manage cancellations, and understand spending — no bank linking, no login, no cloud.

**Core philosophy:** Do one thing perfectly — track subscriptions and remind users before they get charged.

**Current version:** v1.4.6+50. All build phases complete. Active post-launch improvements only.
**Templates:** 329 pre-built templates (as of March 2026), including a `sports` analytics category.

---

## Technical Stack

- **Framework:** Flutter (latest stable) / Dart
- **State:** Riverpod with `@riverpod` code generation. Use `AsyncNotifier` for async, `Notifier` for sync. Never raw `StateProvider` for complex state.
- **Storage:** Hive (hive_flutter). 100% on-device. All writes must be awaited.
- **Notifications:** flutter_local_notifications + timezone. Use `zonedSchedule` with `TZDateTime` — never plain `DateTime`.
- **Navigation:** GoRouter (declarative routing)
- **Currency:** `intl` NumberFormat. Exchange rates are **bundled JSON** — never fetched from network.
- **Brand Icons:** `simple_icons` (font-based) + local SVGs in `assets/logos/`. Widget: `lib/core/widgets/subscription_icon.dart`. Mapping: `lib/core/utils/service_icons.dart`.
- **IAP:** RevenueCat (`purchases_flutter: ^9.0.0`). Outbound calls for IAP validation only — user data stays local.
- **Analytics:** PostHog (`posthog_flutter: ^5.20.0`). Anonymous-only, no PII. Opt-out toggle in Settings. Second outbound SDK after RevenueCat. See [`docs/guides/analytics-and-tracking.md`](docs/guides/analytics-and-tracking.md).
- **Crash Reporting:** PostHog error tracking autocapture (Flutter errors, platform errors, isolate errors). Enabled via `errorTrackingConfig` in `AnalyticsService.init()`. No Sentry/Crashlytics needed.
- **In-App Review:** `in_app_review: ^2.0.9`. Prompts after 5th subscription created. Single-use, Apple rate-limited.
- **IDs:** `uuid` package for subscription UUIDs.

### Key Dependencies
```
flutter_riverpod: ^2.5.1
hive_flutter: ^1.1.0
go_router: ^14.2.0
flutter_local_notifications: ^18.0.1  # CRITICAL
timezone: ^0.9.4
google_fonts: ^6.2.1                  # DM Sans + DM Mono
simple_icons: ^14.6.1
flutter_svg: ^2.0.0                   # local SVG logos
purchases_flutter: ^9.0.0             # RevenueCat IAP
posthog_flutter: ^5.20.0              # Analytics + crash reporting (opt-out in Settings)
in_app_review: ^2.0.9                 # App Store review prompt (after 5th subscription)
fl_chart: ^0.68.0
table_calendar: ^3.1.2                # Calendar view of upcoming bills
app_settings: ^5.1.1                  # notification settings deep-link (iOS + Android)
```

---

## Folder Structure

```
lib/
├── app/
│   ├── app.dart                    # MaterialApp + GoRouter + ProviderScope
│   ├── router.dart                 # All route definitions
│   └── theme.dart                  # Full theme definition
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart         # All color constants
│   │   ├── app_sizes.dart          # Spacing, radius + sectionSpacing (20px)
│   │   ├── revenue_cat_constants.dart # IAP product/entitlement IDs
│   │   └── posthog_constants.dart  # PostHog API key + host
│   ├── extensions/
│   │   └── date_extensions.dart    # DateTime helpers (nextBillingDate calc)
│   ├── utils/
│   │   ├── currency_utils.dart     # Exchange rate loading/conversion
│   │   ├── service_icons.dart      # iconName → SimpleIcons mapping
│   │   ├── haptic_utils.dart       # HapticUtils.light/medium/heavy wrappers
│   │   └── snackbar_utils.dart     # SnackBarUtils.success/error/warning/info
│   └── widgets/
│       ├── standard_card.dart      # Card: 16px radius, 1.5px border, 20px padding, no shadow
│       ├── subtle_pressable.dart   # Scale animation wrapper (0.99 scale)
│       ├── subscription_icon.dart  # Brand icon: local SVG → SimpleIcons → letter avatar
│       └── empty_state.dart
│
├── data/
│   ├── models/
│   │   ├── subscription.dart       # Core model — HiveType 0, fields 0–25
│   │   ├── subscription_cycle.dart # Enum — HiveType 1
│   │   ├── subscription_category.dart # Enum — HiveType 2
│   │   └── reminder_config.dart    # HiveType 3
│   ├── repositories/
│   │   └── subscription_repository.dart
│   └── services/
│       ├── notification_service.dart
│       ├── backup_service.dart
│       ├── entitlement_service.dart  # RevenueCat / IAP
│       ├── analytics_service.dart   # PostHog wrapper + crash reporting + opt-out
│       ├── review_service.dart     # In-app review prompt (after 5th subscription)
│       ├── template_service.dart
│       └── demo_data_service.dart  # Hidden dev tools: 18 sample subs
│
├── features/
│   ├── onboarding/
│   ├── home/                       # home_screen.dart + home_controller.dart
│   ├── add_subscription/           # add_subscription_screen.dart + template_picker_screen.dart
│   ├── subscription_detail/
│   ├── cancellation/
│   ├── analytics/
│   ├── calendar/                    # calendar_screen.dart + calendar_controller.dart
│   ├── settings/                    # settings_screen.dart + widgets/custom_apps_promo_card.dart
│   └── paywall/                    # paywall_screen.dart (RevenueCat)
│
└── main.dart                       # Entry: Hive init, PostHog init, notifications init, runApp
```

---

## Architecture Rules

1. **Every screen has its own Riverpod controller** — no business logic in widgets.
2. **Repository pattern** — widgets never touch Hive directly. All DB ops through `SubscriptionRepository`.
3. **Models are immutable** — use `copyWith`. Generate TypeAdapters with `hive_generator`.
4. **No singletons** — wrap all services in Riverpod providers.
5. **No network calls for user data** — 100% offline. Exchange rates are bundled JSON. Two outbound SDKs: RevenueCat (IAP validation) and PostHog (anonymous analytics + crash reporting, opt-out available). `in_app_review` triggers native OS review dialog (no network call from app).

---

## Data Models

**Full definitions with all HiveFields**: [`docs/architecture/models.md`](docs/architecture/models.md)

### Subscription (typeId: 0) — key fields

| HiveField | Name | Type | Notes |
|-----------|------|------|-------|
| 0 | id | String | UUID |
| 1 | name | String | |
| 2 | amount | double | |
| 3 | currencyCode | String | "USD", "EUR", etc. |
| 4 | cycle | SubscriptionCycle | |
| 5 | nextBillingDate | DateTime | |
| 6 | startDate | DateTime | |
| 7 | category | SubscriptionCategory | |
| 8 | isActive | bool | **⚠️ false = PAUSED** (v1.2.0 repurpose — see ADR 004) |
| 9 | isTrial | bool | |
| 18 | iconName | String? | template icon key |
| 19 | colorValue | int | `Color(colorValue)` |
| 20 | reminders | ReminderConfig | |
| 21 | isPaid | bool | resets on billing date advance |
| 23 | pausedDate | DateTime? | |
| 24 | resumeDate | DateTime? | null = manual resume only |
| 25 | pauseCount | int | |

**Next available index: 26.** Never reuse a HiveField index, even after deletion.

---

## Critical Runtime Rules

### Date Comparison — always use calendar-day precision
```dart
// ✅ CORRECT — strip time component
final today = DateTime(now.year, now.month, now.day);
if (nextBillingDate.isBefore(today)) { /* overdue */ }

// ❌ WRONG — midnight-dated subs become "overdue" at 9am
if (nextBillingDate.isBefore(DateTime.now())) { }
```

### Home Screen Sections
- **Upcoming**: active subs, 0–30 days → `getUpcomingSubscriptions(days: 31)`
- **Later**: active subs, 31–90 days → `getLaterSubscriptions(fromDays: 31)`
- **Paused**: `isActive == false` — always filter by `isActive` in any "upcoming" query

### Mark as Paid
- Use **optimistic state update** in `home_controller.dart` — patch only the affected item, do NOT call `refresh()` (causes skeleton flash + jarring reorder)
- `isPaid` resets automatically when billing date advances
- Paid subs skip notification scheduling (cancel on mark, reschedule on un-mark)
- Home screen: paid tiles fade to 55% opacity, "Paid · N of M" divider, undo snackbar, amber/undo swipe indicator

### Pause / Auto-Resume
Auto-resume + date advancement run in 3 places: app startup (`main.dart`), app foreground (`didChangeAppLifecycleState`), pull-to-refresh. Paused subs skip billing date advancement and notification scheduling entirely.

### Premium Entitlement Refresh
`isPremiumProvider` is `AutoDisposeFutureProvider` — must be manually invalidated with `ref.invalidate(isPremiumProvider)` after purchase, restore, and on app foreground.

---

## Notification Rules — CRITICAL

**Full guide**: [`docs/guides/working-with-notifications.md`](docs/guides/working-with-notifications.md)

1. Always use `zonedSchedule` + `TZDateTime` — never plain `DateTime`.
2. Cancel all existing notifications for a sub **before** rescheduling.
3. Reschedule on every `upsert` call.
4. Notification ID: `('$subscriptionId:$type'.hashCode).abs() % 2147483647`
   - Types: `'reminder1'`, `'reminder2'`, `'dayof'`, `'trial_end'`
5. Skip paused subscriptions entirely — no notifications while paused.
5b. Skip paid subscriptions — no reminders until `isPaid` resets on next billing cycle.
6. iOS action buttons require `DarwinNotificationActionOption.foreground` to bring app to front.
7. Android channel: ID `customsubs_reminders`, importance Max, priority High.

---

## Design Rules

**Full system**: [`docs/architecture/design-system.md`](docs/architecture/design-system.md)

- **All cards**: use `StandardCard` (16px radius, 1.5px border, 20px padding, no shadow)
- **Section spacing**: `AppSizes.sectionSpacing` (20px) between major sections
- **Fonts**: DM Sans for UI text, DM Mono for currency amounts
- **Press animations**: `SubtlePressable` with 0.99 scale
- **Dark mode supported** — toggle in Settings > General. Colors via `context.colors` (`ThemeExtension<CustomColors>`)

---

## Critical Quality Requirements

1. **Notifications must fire reliably.** This is the app's primary value — test every code path.
2. **No crashes on empty state.** Every screen must handle zero data gracefully.
3. **No data loss.** Hive writes must be awaited. Never fire-and-forget.
4. **Fast startup.** App must be interactive within 1 second.
5. **Forms must validate.** Amount > 0, name not empty, date not in the distant past.
6. **Smooth 60fps.** No jank on scrolling, transitions, or animations.
7. **Accessible.** Semantic labels on all interactives. Minimum 48×48 touch targets.

---

## What NOT to Build

- ❌ No login / authentication
- ❌ No cloud sync / Firebase / Supabase
- ❌ No bank linking / email scanning
- ❌ No live exchange rate fetching (use bundled `assets/data/exchange_rates.json`)
- ✅ Dark mode **IS** implemented — toggle in Settings, persisted via Hive, uses `ThemeExtension<CustomColors>`
- ❌ No home screen widgets (future phase)
- ❌ No ads / social features / web version
- ✅ Premium tier via RevenueCat **IS** implemented — see `docs/guides/iap-and-premium.md`

---

## Build Instructions

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Run `build_runner` after any Hive model or Riverpod annotation change.

Verify notifications on a **real device** — simulators have limited notification support.

Full setup guide: [`docs/guides/development-setup.md`](docs/guides/development-setup.md)

### Claude Code Configuration
Pre-configured permissions at `.claude/settings.local.json` for common dev tasks (git, flutter, build tools).
