# Testing Guide

**Status**: Active
**Last Updated**: April 2026 (v1.5.1)

---

## Overview

Tests cover 7 areas: **Subscription model** (serialization, billing date calculation), **ReminderConfig model**, **date extensions**, **SubscriptionRepository** (CRUD, date advancement, pause/resume), **NotificationService** (scheduling, cancellation), **BackupService** (export/import roundtrip, duplicate detection), and **HomeController** (filtering, optimistic updates, mutations).

**Mocking library:** `mocktail` (no code generation needed).
**Integration tests:** `integration_test/` for on-device smoke testing.

---

## Running Tests

```bash
# All unit tests
flutter test

# Specific test file
flutter test test/data/repositories/subscription_repository_test.dart

# By directory
flutter test test/data/              # Repository + service + model tests
flutter test test/features/home/     # HomeController tests
flutter test test/core/              # Date extensions tests

# Integration smoke test (requires device/simulator)
flutter test integration_test/smoke_test.dart

# With coverage
flutter test --coverage
```

---

## Test File Structure

```
test/
├── helpers/
│   ├── mocks.dart                              # Mock class declarations (mocktail)
│   ├── test_subscription_factory.dart          # TestSub factory with sensible defaults
│   ├── test_provider_overrides.dart            # Riverpod container helpers for controller tests
│   └── hive_test_utils.dart                    # Real Hive with temp dir for repository tests
│
├── core/
│   └── extensions/
│       └── date_extensions_test.dart           # addMonths edge cases, isToday, startOfDay
│
├── data/
│   ├── models/
│   │   ├── subscription_test.dart              # toJson/fromJson, calculateNextBillingDate, equality
│   │   └── reminder_config_test.dart           # Serialization, defaults, copyWith
│   ├── repositories/
│   │   └── subscription_repository_test.dart   # CRUD, date advancement, pause/resume
│   └── services/
│       ├── notification_service_test.dart       # Scheduling, cancellation, deterministic IDs
│       └── backup_service_test.dart            # Export/import roundtrip, duplicates, validation
│
├── features/
│   ├── add_subscription/
│   │   ├── models/
│   │   │   └── subscription_form_state_test.dart  # Form validation (pre-existing)
│   │   └── widgets/                               # Widget tests (pre-existing)
│   └── home/
│       └── home_controller_test.dart           # Filtering, optimistic updates, mutations
│
└── widget_test.dart                            # App smoke test (pre-existing)

integration_test/
└── smoke_test.dart                             # On-device app launch verification
```

---

## Test Helpers

### TestSub Factory (`test/helpers/test_subscription_factory.dart`)

Creates `Subscription` objects with sensible defaults. Only override what your test cares about:

```dart
// Basic subscription billing in 7 days (all defaults)
final sub = TestSub.create();

// Active sub billing in exactly N days from today
final sub = TestSub.billingInDays(5, id: 'my-sub', amount: 15.99);

// Paused subscription with optional auto-resume
final sub = TestSub.paused(id: 'paused', resumeDate: someFutureDate);

// Trial subscription ending in 5 days
final sub = TestSub.trial(daysUntilEnd: 5, postTrialAmount: 9.99);

// Already-paid subscription
final sub = TestSub.paid(id: 'paid-sub');
```

Call `TestSub.resetCounter()` in `setUp()` to get predictable auto-generated IDs.

### Mocks (`test/helpers/mocks.dart`)

All mock declarations in one place:

```dart
class MockFlutterLocalNotificationsPlugin extends Mock implements FlutterLocalNotificationsPlugin {}
class MockBox extends Mock implements Box<Subscription> {}
class MockSubscriptionRepository extends Mock implements SubscriptionRepository {}
class MockNotificationService extends Mock implements NotificationService {}
class MockAnalyticsService extends Mock implements AnalyticsService {}
class MockBackupService extends Mock implements BackupService {}
```

### Provider Overrides (`test/helpers/test_provider_overrides.dart`)

Quick Riverpod container setup with pre-configured mocks:

```dart
final container = createTestContainer(
  repository: mockRepo,
  notificationService: mockNotifService,
);
// container.dispose() in tearDown
```

### Hive Test Utils (`test/helpers/hive_test_utils.dart`)

Real Hive in a temp directory for repository tests that need actual persistence:

```dart
setUpAll(() async => await HiveTestUtils.initTestHive());
tearDownAll(() async => await HiveTestUtils.cleanupTestHive());
```

---

## Key Patterns

### Testing SubscriptionRepository

Uses `FakeBox` — an in-memory `Box<Subscription>` implementation that avoids real Hive init:

```dart
late FakeBox fakeBox;
late SubscriptionRepository repo;

setUp(() {
  fakeBox = FakeBox();
  repo = SubscriptionRepository(box: fakeBox);   // Inject fake box
});

test('getAllActive excludes paused', () {
  fakeBox.seed([
    TestSub.create(isActive: true),
    TestSub.paused(),
  ]);
  expect(repo.getAllActive(), hasLength(1));
});
```

The `FakeBox` class is defined at the top of `subscription_repository_test.dart`.

### Testing NotificationService

Inject a `MockFlutterLocalNotificationsPlugin` via the constructor:

```dart
late MockFlutterLocalNotificationsPlugin mockPlugin;
late NotificationService service;

setUp(() {
  mockPlugin = MockFlutterLocalNotificationsPlugin();
  // ... stub plugin methods ...
  service = NotificationService(notifications: mockPlugin);
});
```

Important: call `await service.init()` before any scheduling tests — it sets `_initialized = true`.

### Testing HomeController (Riverpod)

Use `ProviderContainer` with overrides:

```dart
container = ProviderContainer(
  overrides: [
    subscriptionRepositoryProvider.overrideWith((_) async => mockRepo),
    notificationServiceProvider.overrideWith((_) async => mockNotificationService),
    analyticsServiceProvider.overrideWith((_) => mockAnalyticsService),
    primaryCurrencyProvider.overrideWith((_) => 'USD'),
  ],
);

await container.read(homeControllerProvider.future);
final controller = container.read(homeControllerProvider.notifier);
```

For `calculateMonthlyTotal` tests, call `CurrencyUtils.loadExchangeRates()` in `setUpAll()` (requires `TestWidgetsFlutterBinding.ensureInitialized()`).

---

## What's Tested

### Subscription Model (~29 tests)
- **toJson/fromJson roundtrip**: all 26 fields, null optionals, enum fallbacks, missing boolean defaults
- **calculateNextBillingDate**: weekly, biweekly, monthly, quarterly, biannual, yearly, month-end overflow (Jan 31 → Feb 28/29), leap year
- **Computed properties**: effectiveAmount (trial vs normal), isPaused, shouldAutoResume, isOverdue, monthlyAmount per cycle
- **copyWith**: immutability, field preservation
- **Equality**: by ID only

### ReminderConfig (~12 tests)
- **Serialization**: toJson/fromJson roundtrip, default values, missing-key fallbacks
- **copyWith** and **equality**

### Date Extensions (~17 tests)
- **addMonths**: month-end rollback, leap year, Dec→Jan wraparound, time preservation
- **isToday / isTomorrow**: boundary checks
- **startOfDay / endOfDay**: time stripping

### SubscriptionRepository (~34 tests)
- **CRUD**: getAll, getAllActive, getAllPaused, getById, upsert, delete
- **advanceOverdueBillingDates**: calendar-day boundary (today = not advanced), multi-cycle catch-up, paused skip, isPaid reset, weekly/yearly cycles
- **markAsPaid**: toggle paid status, not-found handling
- **Pause/Resume**: state transitions, auto-resume filtering, pauseCount tracking
- **Filtering**: getUpcoming, getTrialsEndingSoon, empty results
- **Aggregation**: calculateMonthlyTotal, getSpendingByCategory

### NotificationService (~22 tests)
- **Deterministic IDs**: same input = same ID, different types = different IDs, int32 range
- **scheduleNotificationsForSubscription**: skip-paused, skip-paid, trial routing, reminder config permutations (0 = skip), cancel-before-schedule
- **Past notification skipping**: reminders in the past are silently dropped
- **Cancel**: all 6 types cancelled with correct IDs
- **Utilities**: showTestNotification (ID 999999), areNotificationsEnabled
- **Init**: idempotency

### BackupService (~18 tests)
- **Export**: empty list, multiple subs, metadata fields
- **Parse**: valid JSON, invalid JSON, wrong app name, missing subscriptions key, extra fields
- **Full roundtrip**: 5 diverse subs (different cycles, currencies, paused, trial, paid, cancel checklist) → export → parse → verify all fields
- **Duplicate detection**: UUID match, name+amount+cycle match (case-insensitive), non-duplicates, empty lists
- **Backward compatibility**: JSON missing newer fields → defaults applied
- **Validation**: empty name, negative amount

### HomeController (~22 tests)
- **getUpcomingSubscriptions**: 30-day window, todayStart boundary, exclusive cutoff, paused exclusion, unpaid-first sort
- **getLaterSubscriptions**: 31–90 day window, no overlap with upcoming, paused exclusion
- **getPausedSubscriptions**: pausedDate descending sort, null handling
- **markAsPaid**: optimistic update (no AsyncLoading flash), isPaid reflected in state, notification cancel/reschedule
- **Mutations**: delete, pause, resume all delegate correctly and trigger refresh

### Integration Smoke Test
- App launches without crash (real Hive, real timezone, mocked analytics/notifications)

---

## Testability Design

Two production classes accept optional constructor parameters for dependency injection:

- `NotificationService({FlutterLocalNotificationsPlugin? notifications})` — defaults to real plugin
- `SubscriptionRepository({Box<Subscription>? box})` — defaults to Hive.openBox in init()

`NotificationService.notificationId()` is a `@visibleForTesting` static method exposing the deterministic ID algorithm for direct verification.

`BackupService.detectDuplicates()` is `@visibleForTesting` for direct duplicate detection testing.

---

## Critical Flows Covered

The test suite covers 3 end-to-end user flows across multiple test files:

1. **Create → Notify → Advance → Mark Paid**: subscription_test (toJson/fromJson), subscription_repository_test (CRUD, advanceOverdueBillingDates, markAsPaid), notification_service_test (scheduling), home_controller_test (optimistic markAsPaid)
2. **Pause → Auto-Resume → Notifications Resume**: subscription_repository_test (pause/resume/autoResume), notification_service_test (skip paused), home_controller_test (pause/resume delegation)
3. **Backup Export → Import → Data Integrity**: backup_service_test (roundtrip, duplicates, backward compat), subscription_test (toJson/fromJson serialization)

---

## Adding Tests for New Features

1. Create test file mirroring `lib/` structure under `test/`
2. Use `TestSub` factory for test data — don't construct `Subscription` manually (unless testing cancel fields not in factory)
3. Add new mocks to `test/helpers/mocks.dart`
4. For Riverpod controllers: use `ProviderContainer` with overrides (see `test_provider_overrides.dart`)
5. For repository methods: use `FakeBox` pattern or `HiveTestUtils` for real Hive
6. Run `flutter test` to verify all tests pass before committing
