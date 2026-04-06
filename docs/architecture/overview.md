# CustomSubs Architecture Overview

**Status**: ✅ Complete
**Last Updated**: March 3, 2026
**Relevant to**: Developers

**High-level system architecture and design principles for CustomSubs.**

This document explains how the system is organized, how components interact, and why key architectural decisions were made.

---

## Table of Contents

1. [System Overview](#system-overview)
2. [Architecture Principles](#architecture-principles)
3. [Folder Structure](#folder-structure)
4. [Data Flow](#data-flow)
5. [Layer Responsibilities](#layer-responsibilities)
6. [Component Interaction](#component-interaction)
7. [Technology Choices](#technology-choices)

---

## System Overview

### What is CustomSubs?

CustomSubs is a **privacy-first, offline-only** subscription tracker for iOS and Android built with Flutter. It helps users track recurring subscriptions, receive reliable billing reminders, and manage cancellations — all without linking a bank account, scanning emails, or creating a login.

### Core Philosophy

**Do one thing perfectly** — track subscriptions and remind users before they get charged. No account. No cloud. No permissions. Just a fast, beautiful, trustworthy utility.

### Architectural Style

- **Feature-first** folder structure
- **Clean architecture** with separation of concerns
- **Offline-first** data persistence (100% local)
- **Reactive state management** (Riverpod)
- **Repository pattern** for data access
- **Service layer** for cross-cutting concerns

---

## Architecture Principles

### 1. Privacy First

**No network calls for user data. No cloud sync.**

- All subscription data stored locally in Hive (encrypted NoSQL database)
- Exchange rates bundled as static JSON assets
- No crash reporting, no telemetry
- No permissions except notifications (required for core feature)
- **Two outbound SDKs** (neither transmits user subscription data):
  - **RevenueCat** (IAP) — communicates with Apple/Google receipt servers for purchase validation only
  - **PostHog** (analytics) — anonymous event tracking with opt-out toggle in Settings. No PII, no subscription names/amounts — only categorical properties (category names, cycle types, booleans)

### 2. Offline First

**App must work without internet connection.**

- All features function completely offline
- No dependency on external APIs
- Bundled assets for templates and exchange rates
- Hive provides fast, synchronous data access

### 3. Separation of Concerns

**Clear boundaries between layers.**

- **UI Layer** (features/) - Widgets and user interactions
- **Business Logic** (controllers, services) - App-specific logic
- **Data Layer** (repositories, models) - Data access and persistence
- **Core Layer** (utils, extensions, constants) - Shared utilities

### 4. Single Responsibility

**Each component has one job.**

- **Repository** - Data access only, no business logic
- **Service** - One cross-cutting concern (notifications, backups)
- **Controller** - UI state for one screen
- **Widget** - One visual component

### 5. Explicit Over Implicit

**Make dependencies and data flow obvious.**

- Use Riverpod providers for dependency injection
- No singletons or global state
- Pass data explicitly through constructors
- Use types to document contracts

### 6. Reliability Over Features

**The #1 feature must work 100% of the time.**

- Notifications are the primary value proposition
- Extensive error handling and fallbacks
- Test notifications feature for user verification
- Deterministic IDs for reliable cancellation

---

## Folder Structure

See `CLAUDE.md` for the current folder structure and file naming conventions.

---

## Data Flow

### Unidirectional Data Flow

```
User Interaction
     ↓
Widget (UI Layer)
     ↓
Controller (State Management)
     ↓
Repository (Data Access)
     ↓
Hive Box (Persistence)
     ↓
Repository → Controller → Widget
     ↓
UI Updates
```

### Example: Adding a Subscription

```
1. User fills form in AddSubscriptionScreen
2. User taps "Save" button
3. Screen calls controller.saveSubscription()
4. Controller validates data
5. Controller calls repository.upsert(subscription)
6. Repository writes to Hive box
7. Controller calls notificationService.schedule(...)
8. Service schedules platform notifications
9. Controller navigates back to HomeScreen
10. HomeScreen re-reads data from repository
11. UI displays new subscription
```

### Data Flow Principles

- **No direct Hive access from widgets** - Always go through repository
- **No business logic in repositories** - Only CRUD operations
- **Services have no state** - Pure side-effect handlers
- **Controllers orchestrate** - Connect UI → repository → services

---

## Layer Responsibilities

### UI Layer (`features/`)

**Responsibilities:**
- Render widgets based on state
- Handle user input (taps, text entry)
- Trigger controller methods
- Display loading/error states

**Does NOT:**
- Access Hive directly
- Contain business logic
- Make network calls
- Schedule notifications

**Tools:**
- ConsumerWidget for stateless UI
- ConsumerStatefulWidget for forms/local state
- Riverpod ref.watch() for reactive updates

### State Management Layer (`*_controller.dart`)

**Responsibilities:**
- Manage screen-level state
- Orchestrate repository and service calls
- Provide computed properties
- Handle async operations with loading/error states

**Does NOT:**
- Render UI directly
- Access Hive directly
- Contain low-level data access logic

**Tools:**
- Riverpod AsyncNotifier for async state
- Riverpod Notifier for sync state
- Code generation with @riverpod

### Data Layer (`data/`)

#### Repositories (`data/repositories/`)

**Responsibilities:**
- CRUD operations on Hive boxes
- Query and filter data
- Provide reactive data streams
- Data validation (basic)

**Does NOT:**
- Contain UI logic
- Schedule notifications
- Handle navigation
- Perform complex business logic

**Example:** SubscriptionRepository

#### Services (`data/services/`)

**Responsibilities:**
- Cross-cutting concerns (notifications, backups, templates)
- Platform integrations
- Side effects (file I/O, notification scheduling)

**Does NOT:**
- Store state
- Access Hive directly (except BackupService)
- Handle UI interactions

**Examples:** NotificationService, BackupService, TemplateService

#### Models (`data/models/`)

**Responsibilities:**
- Define data structures
- Hive type adapters for serialization
- Computed properties (e.g., effectiveMonthlyAmount)
- copyWith() methods for immutability

**Does NOT:**
- Contain business logic
- Access repositories or services
- Manage state

### Core Layer (`core/`)

**Responsibilities:**
- Reusable utilities (currency conversion, date calculations)
- Constants (colors, sizes, app-wide values)
- Extensions (DateTime helpers, currency formatting)
- Reusable widgets (buttons, cards, empty states)

**Does NOT:**
- Depend on features/
- Contain feature-specific logic
- Access data layer directly

---

## Component Interaction

### How Components Work Together

#### Screen → Controller → Repository

```dart
// 1. Screen watches controller
final state = ref.watch(homeControllerProvider);

// 2. Controller loads data from repository
@override
Future<List<Subscription>> build() async {
  final repository = await ref.watch(subscriptionRepositoryProvider.future);
  return repository.getAllActive();
}

// 3. User action triggers controller method
ref.read(homeControllerProvider.notifier).deleteSubscription(id);

// 4. Controller calls repository
await repository.delete(id);

// 5. Controller refreshes state
await refresh();

// 6. UI automatically updates via ref.watch()
```

#### Controller → Multiple Services

```dart
// Controller orchestrates multiple services
Future<void> saveSubscription(Subscription sub) async {
  // 1. Save to repository
  await repository.upsert(sub);

  // 2. Schedule notifications
  await notificationService.scheduleNotificationsForSubscription(sub);

  // 3. Could also: backup service, analytics, etc.

  // 4. Refresh UI
  await refresh();
}
```

#### Repository → Hive Box

```dart
// Repository provides clean interface to Hive
class SubscriptionRepository {
  Box<Subscription>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<Subscription>('subscriptions');
  }

  List<Subscription> getAllActive() {
    return _box!.values.where((sub) => sub.isActive).toList();
  }

  Future<void> upsert(Subscription subscription) async {
    // Find by ID, update if exists, add if new
    await _box!.put(subscription.id, subscription);
  }
}
```

---

## Technology Choices

See `CLAUDE.md` for the authoritative tech stack and key dependencies. For the reasoning behind key decisions:

| Decision | ADR |
|----------|-----|
| Riverpod code generation | `docs/decisions/001-riverpod-code-generation.md` |
| Notification ID strategy | `docs/decisions/002-notification-id-strategy.md` |
| Offline-first (no cloud) | `docs/decisions/003-offline-first-architecture.md` |
| Pause via isActive reuse | `docs/decisions/004-pause-feature-isactive-reuse.md` |

---

## Key Design Decisions

### 1. Feature-First Over Layer-First

**Chosen:** `lib/features/home/home_screen.dart`
**Alternative:** `lib/screens/home_screen.dart`

**Why:** Features are self-contained, easier to navigate, clear boundaries.

### 2. Repository Pattern

**Chosen:** All Hive access through SubscriptionRepository
**Alternative:** Direct Hive access from controllers

**Why:** Single source of truth, testability, easier refactoring.

### 3. No Network Layer

**Chosen:** Bundled assets, offline-only
**Alternative:** Live exchange rates, cloud sync

**Why:** Privacy, simplicity, reliability, trust.

**See:** `docs/decisions/003-offline-first-architecture.md`

### 4. Code Generation for State Management

**Chosen:** `@riverpod` annotations + build_runner
**Alternative:** Manual provider definitions

**Why:** Type safety, less boilerplate, better DX.

**See:** `docs/decisions/001-riverpod-code-generation.md`

### 5. Deterministic Notification IDs

**Chosen:** Generated from UUID + type
**Alternative:** Random IDs or auto-increment

**Why:** Reliable cancellation without storing IDs.

**See:** `docs/decisions/002-notification-id-strategy.md`

---

## System Boundaries

### What CustomSubs IS

- ✅ Subscription tracker
- ✅ Billing reminder system
- ✅ Cancellation helper
- ✅ Spending analytics
- ✅ Offline-first mobile app
- ✅ Free app — no subscription limits (RevenueCat SDK retained for passive tracking; paywall code dormant, `isFreeMode = true`)

### What CustomSubs is NOT

- ❌ Budgeting app
- ❌ Expense tracker
- ❌ Bank account aggregator
- ❌ Receipt scanner
- ❌ Cloud service
- ❌ Social platform
- ❌ Ad-supported

---

## Extension Points

### Where to Add New Features

**New screen/feature:**
```
1. Create directory in lib/features/
2. Add screen file
3. Add controller (if needed)
4. Add route in lib/app/router.dart
5. Add navigation from existing screens
```

**New model:**
```
1. Create in lib/data/models/
2. Add Hive type adapter
3. Register adapter in main.dart
4. Run build_runner
5. May require data migration strategy
```

**New service:**
```
1. Create in lib/data/services/
2. Wrap in Riverpod provider
3. Use in controllers/screens
4. Initialize in main.dart if needed
```

**New repository:**
```
1. Create in lib/data/repositories/
2. Follow SubscriptionRepository pattern
3. Wrap in Riverpod FutureProvider
4. Use in controllers
```

---

## Testing Strategy

**Mocking library:** `mocktail` (no codegen). Full guide: [`docs/guides/testing.md`](../guides/testing.md).

### Unit Tests (~100+ tests)

- **SubscriptionRepository** (~34 tests) — CRUD, date advancement (calendar-day boundary), pause/resume, filtering, aggregation
- **NotificationService** (~22 tests) — skip-paused, skip-paid, trial routing, deterministic IDs, past-notification skipping
- **HomeController** (~22 tests) — 30-day boundary, unpaid-first sort, optimistic markAsPaid, notification side effects
- **Forms** (~26 tests) — validation, state management, serialization

Test helpers: `TestSub` factory (`test/helpers/test_subscription_factory.dart`), mocks (`test/helpers/mocks.dart`).

### Widget Tests

- **Forms** - Validation, submission, section collapsibility
- **Screens** - UI renders correctly, handles all states

### Integration Tests

- **Notification flow** - Schedule → fire → verify
- **Data persistence** - Save → restart app → verify loaded
- **Full workflows** - Add subscription → view → edit → delete

### Manual Testing

- **Real devices** - iOS and Android physical devices
- **Notifications** - Verify reliability on real hardware
- **Edge cases** - Airplane mode, device restart, low battery

---

## Performance Considerations

### Fast Startup

- Hive opens quickly (< 100ms)
- No network calls
- Minimal initialization
- Lazy loading where possible

### Smooth Scrolling

- ListView.builder for long lists
- Const constructors where possible
- Avoid expensive computations in build()
- Use RepaintBoundary for complex widgets

### Memory Efficiency

- Dispose controllers when not needed
- Use watch streams only where necessary
- Avoid storing large blobs in Hive
- Close Hive boxes when app terminates

---

## Security Considerations

### Data at Rest

- Hive stores data in app's private directory
- iOS/Android sandbox prevents access from other apps
- Consider Hive encryption for sensitive data (future)

### No Network Exposure (for user data)

- Subscription tracking data never transmitted
- No authentication to implement for user data
- RevenueCat API key is public-side only (safe to ship in binary) — receipt validation is server-side

### User Privacy

- Anonymous analytics only (PostHog) — opt-out toggle available in Settings
- Crash reporting via PostHog error tracking autocapture (respects opt-out)
- No PII collected — event properties are categorical only (category names, cycle types, booleans)
- Two outbound SDKs: RevenueCat (IAP) and PostHog (analytics) — neither transmits subscription data
- User owns their data

---

## Summary

**CustomSubs uses a clean, layered architecture:**

1. **UI Layer** - Features with screens and controllers
2. **State Management** - Riverpod with code generation
3. **Data Layer** - Repositories and services
4. **Persistence** - Hive local database
5. **Core** - Shared utilities and constants

**Key principles:**
- Privacy first (offline-only)
- Separation of concerns
- Testability and maintainability
- Reliability over features
- Simple over complex

**See also:**
- `docs/architecture/state-management.md` - Riverpod patterns
- `docs/architecture/data-layer.md` - Repository and model patterns
- `docs/architecture/design-system.md` - UI patterns and theme
- `docs/guides/iap-and-premium.md` - IAP, RevenueCat, and paywall
- `docs/guides/working-with-notifications.md` - Notification system (critical)
- `docs/decisions/` - Architectural decision records
