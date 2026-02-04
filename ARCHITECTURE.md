# CustomSubs Architecture Documentation

## Table of Contents
1. [Overview](#overview)
2. [Architecture Principles](#architecture-principles)
3. [Project Structure](#project-structure)
4. [Layer Architecture](#layer-architecture)
5. [State Management](#state-management)
6. [Data Flow](#data-flow)
7. [Key Design Patterns](#key-design-patterns)
8. [Feature Modules](#feature-modules)
9. [Core Services](#core-services)
10. [Performance Considerations](#performance-considerations)

## Overview

CustomSubs follows **Clean Architecture** principles with a **feature-first** folder structure. The app is built with Flutter using Riverpod for state management and Hive for local storage.

### Core Principles
- **Privacy-First**: No network calls, all data local
- **Offline-Only**: Fully functional without internet
- **Clean Separation**: UI, business logic, and data layers are decoupled
- **Testability**: Each layer can be tested independently
- **Scalability**: Easy to add new features without affecting existing code

## Architecture Principles

### 1. Feature-First Organization
Each feature is self-contained with its own screens, controllers, and widgets:

```
features/
├── home/
│   ├── home_screen.dart
│   ├── home_controller.dart
│   └── widgets/
├── add_subscription/
│   ├── add_subscription_screen.dart
│   ├── add_subscription_controller.dart
│   └── widgets/
└── ...
```

**Benefits**:
- Easy to locate feature-specific code
- Natural boundaries for testing
- Teams can work on features independently
- Easy to remove or replace entire features

### 2. Dependency Inversion
High-level modules (UI) depend on abstractions (providers), not concrete implementations:

```dart
// UI depends on provider
final repository = await ref.read(subscriptionRepositoryProvider.future);

// Provider provides implementation
@riverpod
Future<SubscriptionRepository> subscriptionRepository(Ref ref) async {
  final repo = SubscriptionRepository();
  await repo.init();
  return repo;
}
```

### 3. Single Responsibility
Each class/file has one clear purpose:
- **Models**: Data structures only
- **Repositories**: Data access logic
- **Services**: Business logic
- **Controllers**: UI state management
- **Screens**: UI composition

## Project Structure

```
lib/
├── app/                    # Application-level configuration
│   ├── router.dart         # Navigation configuration (GoRouter)
│   └── theme.dart          # Material 3 theme definition
│
├── core/                   # Shared utilities and constants
│   ├── constants/
│   │   ├── app_colors.dart      # Color palette
│   │   └── app_sizes.dart       # Spacing and sizing
│   ├── extensions/
│   │   └── date_extensions.dart # DateTime helpers
│   └── utils/
│       ├── currency_utils.dart  # Currency formatting/conversion
│       └── service_icons.dart   # Service-to-icon mapping (50+ services)
│
├── data/                   # Data layer
│   ├── models/             # Data models with Hive annotations
│   │   ├── subscription.dart
│   │   ├── subscription_cycle.dart
│   │   ├── subscription_category.dart
│   │   └── reminder_config.dart
│   ├── repositories/       # Data access layer
│   │   └── subscription_repository.dart
│   └── services/           # Business logic services
│       ├── notification_service.dart
│       └── template_service.dart
│
└── features/               # Feature modules
    ├── onboarding/
    ├── home/
    ├── add_subscription/
    ├── subscription_detail/
    ├── settings/
    └── analytics/
```

## Layer Architecture

### 1. Presentation Layer (`features/*/`)
**Responsibility**: UI and user interaction

**Components**:
- **Screens**: Full-page widgets (e.g., `HomeScreen`, `AddSubscriptionScreen`)
- **Controllers**: Riverpod notifiers that manage UI state
- **Widgets**: Reusable UI components specific to the feature

**Example**:
```dart
// home_screen.dart - Displays subscriptions
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsAsync = ref.watch(homeControllerProvider);
    // Build UI based on state
  }
}

// home_controller.dart - Manages home screen state
@riverpod
class HomeController extends _$HomeController {
  @override
  Future<List<Subscription>> build() async {
    final repository = await ref.read(subscriptionRepositoryProvider.future);
    return repository.watchAll(); // Reactive stream
  }
}
```

### 2. Domain Layer (`data/models/`)
**Responsibility**: Business entities and rules

**Components**:
- **Models**: Pure data classes with business logic methods
- No dependencies on UI or data sources

**Example**:
```dart
@HiveType(typeId: 0)
class Subscription extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  // Business logic method
  double get monthlyEquivalent => cycle.convertToMonthly(amount);

  bool get isOverdue => nextBillingDate.isBefore(DateTime.now());
}
```

### 3. Data Layer (`data/repositories/`, `data/services/`)
**Responsibility**: Data access and business operations

**Components**:
- **Repositories**: CRUD operations and data queries
- **Services**: Complex business logic (notifications, templates, etc.)

**Example**:
```dart
// repository.dart - Data access
class SubscriptionRepository {
  late Box<Subscription> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Subscription>('subscriptions');
  }

  Future<void> upsert(Subscription subscription) async {
    await _box.put(subscription.id, subscription);
  }
}

// notification_service.dart - Business logic
class NotificationService {
  Future<void> scheduleNotificationsForSubscription(Subscription sub) async {
    // Complex notification scheduling logic
  }
}
```

## State Management

### Riverpod Architecture

CustomSubs uses **Riverpod with code generation** for type-safe, reactive state management.

#### Provider Types

**1. Simple Providers** (read-only data):
```dart
@riverpod
NotificationService notificationService(Ref ref) {
  return NotificationService();
}
```

**2. Async Providers** (async initialization):
```dart
@riverpod
Future<SubscriptionRepository> subscriptionRepository(Ref ref) async {
  final repo = SubscriptionRepository();
  await repo.init();
  return repo;
}
```

**3. Notifier Providers** (mutable state):
```dart
@riverpod
class HomeController extends _$HomeController {
  @override
  Future<List<Subscription>> build() async {
    // Initialize state
  }

  Future<void> deleteSubscription(String id) async {
    // Mutate state
  }
}
```

#### State Lifecycle

```
User Action → UI Event → Controller Method → Repository Call → Service Logic
                            ↓
                    State Update (Riverpod)
                            ↓
                    UI Rebuild (Consumer widgets listen)
```

**Example Flow**:
1. User taps "Delete" on a subscription
2. `onDelete` callback in `HomeScreen` fires
3. Calls `ref.read(homeControllerProvider.notifier).deleteSubscription(id)`
4. Controller calls `repository.delete(id)`
5. Repository updates Hive database
6. Riverpod invalidates state
7. `HomeScreen` rebuilds with updated list

## Data Flow

### Read Flow
```
UI (Consumer)
  ↓ ref.watch()
Provider (cached)
  ↓ async read
Repository
  ↓ query
Hive Box
  ↓ return
Data → UI
```

### Write Flow
```
UI Event (button tap)
  ↓ ref.read().notifier.method()
Controller
  ↓ await repository.upsert()
Repository
  ↓ box.put()
Hive Box
  ↓ notify watchers
Provider invalidates
  ↓ rebuild
UI updates
```

### Notification Flow
```
Subscription Saved
  ↓
SubscriptionRepository.upsert()
  ↓ trigger
NotificationService.scheduleNotificationsForSubscription()
  ↓ calculate dates
ReminderConfig (7d, 1d, 0d)
  ↓ schedule
FlutterLocalNotificationsPlugin
  ↓ OS handles
iOS/Android Notification System
```

## Key Design Patterns

### 1. Repository Pattern
Abstracts data source (Hive) from business logic:

```dart
// UI doesn't know about Hive, only Repository interface
final repository = await ref.read(subscriptionRepositoryProvider.future);
await repository.upsert(subscription);
```

**Benefits**:
- Easy to swap data sources (could add SQLite, shared_preferences, etc.)
- Centralized data access logic
- Easier to mock for testing

### 2. Service Pattern
Encapsulates complex business logic:

```dart
// NotificationService handles all notification complexity
await notificationService.scheduleNotificationsForSubscription(subscription);

// UI doesn't need to know about:
// - ID generation logic
// - Timezone calculations
// - Platform-specific APIs
// - Notification channels
```

### 3. Dependency Injection (Riverpod)
Services and repositories are injected via providers:

```dart
// Instead of:
final service = NotificationService(); // Tight coupling

// We use:
final service = ref.read(notificationServiceProvider); // Loose coupling
```

**Benefits**:
- Easy to test (can provide mocks)
- Single instance management (singleton-like behavior)
- Automatic cleanup and lifecycle management

### 4. Extension Methods
Add functionality to existing types without inheritance:

```dart
extension DateTimeX on DateTime {
  String toRelativeString() {
    final diff = difference(DateTime.now());
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Tomorrow';
    return 'in ${diff.inDays} days';
  }
}

// Usage:
final nextBilling = subscription.nextBillingDate.toRelativeString();
```

### 5. Value Objects (Enums with Behavior)
Enums encapsulate related behavior:

```dart
enum SubscriptionCycle {
  weekly, monthly, yearly;

  double convertToMonthly(double amount) {
    switch (this) {
      case SubscriptionCycle.weekly: return amount * 4.33;
      case SubscriptionCycle.monthly: return amount;
      case SubscriptionCycle.yearly: return amount / 12;
    }
  }
}
```

## Feature Modules

### Home Feature
**Purpose**: Main dashboard showing all subscriptions and spending summary

**Files**:
- `home_screen.dart`: UI with list and summary cards
- `home_controller.dart`: Manages subscription list state
- `widgets/`: Reusable widgets (subscription tile, summary card, etc.)

**Key Responsibilities**:
- Display all active subscriptions
- Calculate and show monthly spending
- Provide quick actions (mark paid, delete)
- Navigate to detail/edit screens

### Add Subscription Feature
**Purpose**: Create or edit a subscription

**Files**:
- `add_subscription_screen.dart`: Form UI with template picker
- `add_subscription_controller.dart`: Form state and save logic
- `widgets/`: Color picker, reminder config, template grid

**Key Responsibilities**:
- Template selection and search
- Form validation
- Subscription creation/update
- Notification scheduling

### Subscription Detail Feature (TODO)
**Purpose**: View full subscription details and manage cancellation

**Planned Files**:
- `subscription_detail_screen.dart`: Detail view UI
- `subscription_detail_controller.dart`: Detail state management
- `widgets/`: Cancellation card, billing info card

### Settings Feature
**Purpose**: App configuration

**Current**:
- Basic settings screen
- Test notification button

**Planned**:
- Currency picker
- Backup/restore functionality
- Notification preferences

## Core Services

### NotificationService
**Location**: `lib/data/services/notification_service.dart`

**Purpose**: Manage all notification scheduling and cancellation

**Key Features**:
- Deterministic notification ID generation (for reliable cancellation)
- Timezone-aware scheduling
- Trial-specific notification logic
- Platform permission handling

**Architecture**:
```dart
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;

  // Initialize with platform-specific settings
  Future<void> init() async { ... }

  // Schedule all notifications for a subscription
  Future<void> scheduleNotificationsForSubscription(Subscription sub) async {
    // Calculate reminder dates based on ReminderConfig
    // Generate unique IDs
    // Schedule with timezone
  }

  // Cancel all notifications for a subscription
  Future<void> cancelNotificationsForSubscription(String subId) async {
    // Use deterministic IDs to find and cancel
  }
}
```

**ID Generation Strategy**:
```dart
// Deterministic ID = hash(subscriptionId + reminderType)
int _generateNotificationId(String subscriptionId, String reminderType) {
  return ('$subscriptionId-$reminderType').hashCode.abs();
}
```

This ensures we can always cancel notifications even after app restart.

### TemplateService
**Location**: `lib/data/services/template_service.dart`

**Purpose**: Load and provide subscription templates

**Architecture**:
```dart
@riverpod
Future<List<SubscriptionTemplate>> subscriptionTemplates(Ref ref) async {
  final jsonString = await rootBundle.loadString('assets/data/subscription_templates.json');
  final List<dynamic> jsonList = json.decode(jsonString);
  return jsonList.map((e) => SubscriptionTemplate.fromJson(e)).toList();
}
```

**Data Source**: `assets/data/subscription_templates.json` (40+ templates)

### ServiceIcons Utility
**Location**: `lib/core/utils/service_icons.dart`

**Purpose**: Map subscription service names to recognizable Material Icons

**Key Features**:
- 50+ popular services mapped to appropriate icons
- Categories: Streaming, Cloud Storage, Gaming, Productivity, Fitness, etc.
- Fallback to first letter for unmapped services
- Improves visual identification in UI

**Architecture**:
```dart
class ServiceIcons {
  /// Get icon for a service by name
  static IconData getIconForService(String serviceName) {
    final name = serviceName.toLowerCase();

    if (name.contains('netflix')) return Icons.movie;
    if (name.contains('spotify')) return Icons.music_note;
    if (name.contains('disney')) return Icons.castle;
    // ... 50+ more mappings

    return Icons.subscriptions; // Default fallback
  }

  /// Check if service has custom icon
  static bool hasCustomIcon(String serviceName) {
    return getIconForService(serviceName) != Icons.subscriptions;
  }

  /// Get first letter for display
  static String getDisplayLetter(String serviceName) {
    return serviceName.isEmpty ? '?' : serviceName[0].toUpperCase();
  }
}
```

**Usage**:
```dart
// In template grid or subscription tile
CircleAvatar(
  backgroundColor: color.withOpacity(0.2),
  child: ServiceIcons.hasCustomIcon(subscription.name)
      ? Icon(ServiceIcons.getIconForService(subscription.name), color: color)
      : Text(ServiceIcons.getDisplayLetter(subscription.name)),
)
```

**Supported Services**:
- **Streaming**: Netflix, Spotify, Disney+, Hulu, HBO Max, YouTube Premium, Apple Music, etc.
- **Cloud Storage**: iCloud, Google One, Dropbox, OneDrive
- **Gaming**: Xbox Game Pass, PlayStation Plus, Nintendo Switch Online, Twitch
- **Productivity**: Microsoft 365, Adobe Creative Cloud, Canva, Notion, Evernote
- **Fitness**: Peloton, Strava, MyFitnessPal, Headspace, Calm
- **And 30+ more...**

### SubscriptionRepository
**Location**: `lib/data/repositories/subscription_repository.dart`

**Purpose**: All data operations for subscriptions

**Key Methods**:
```dart
class SubscriptionRepository {
  // CRUD
  Future<void> upsert(Subscription subscription);
  Future<void> delete(String id);
  Future<Subscription?> getById(String id);
  Future<List<Subscription>> getAll();

  // Queries
  Stream<List<Subscription>> watchAll();
  Future<List<Subscription>> getActive();
  Future<List<Subscription>> getTrials();

  // Analytics
  Future<double> calculateMonthlyTotal({String? currencyCode});
  Future<Map<SubscriptionCategory, double>> getSpendingByCategory();
}
```

## Performance Considerations

### 1. Lazy Initialization
Hive boxes are opened only when needed:

```dart
@riverpod
Future<SubscriptionRepository> subscriptionRepository(Ref ref) async {
  final repo = SubscriptionRepository();
  await repo.init(); // Opens Hive box
  return repo;
}
```

### 2. Reactive Updates
Use Hive's `watch()` for efficient UI updates:

```dart
Stream<List<Subscription>> watchAll() {
  return _box.watch().map((_) => _box.values.toList());
}
```

Only rebuilds UI when data actually changes.

### 3. Provider Caching
Riverpod automatically caches provider results:

```dart
// First call: loads templates from JSON
final templates = await ref.read(subscriptionTemplatesProvider.future);

// Subsequent calls: returns cached list (no file I/O)
final templates2 = await ref.read(subscriptionTemplatesProvider.future);
```

### 4. Image Optimization
Logo is included as asset, loaded once and cached by Flutter.

### 5. Async Operations
All I/O operations are async to prevent blocking UI:

```dart
// Good: Async initialization
Future<void> init() async {
  _box = await Hive.openBox<Subscription>('subscriptions');
}

// Bad: Sync operation would freeze UI
void init() {
  _box = Hive.openBoxSync<Subscription>('subscriptions'); // AVOID
}
```

## Code Generation

CustomSubs uses code generation for:

1. **Hive TypeAdapters** (model serialization)
2. **Riverpod Providers** (type-safe state management)

**Generated Files** (committed to git):
- `*.g.dart` - Hive adapters and Riverpod providers
- Located next to their source files

**Build Command**:
```bash
dart run build_runner build --delete-conflicting-outputs
```

**Watch Mode** (during development):
```bash
dart run build_runner watch
```

## Testing Strategy

### Unit Tests
Test business logic in isolation:

```dart
test('SubscriptionCycle converts weekly to monthly correctly', () {
  final cycle = SubscriptionCycle.weekly;
  expect(cycle.convertToMonthly(10.0), closeTo(43.3, 0.1));
});
```

### Widget Tests
Test UI components:

```dart
testWidgets('ColorPickerWidget shows selected color', (tester) async {
  await tester.pumpWidget(ColorPickerWidget(...));
  expect(find.byIcon(Icons.check), findsOneWidget);
});
```

### Integration Tests
Test full features end-to-end:

```dart
testWidgets('Add subscription flow', (tester) async {
  // Navigate to add screen
  // Select template
  // Fill form
  // Save
  // Verify subscription appears in list
});
```

## Security Considerations

### 1. No Network Access
- No HTTP client dependencies
- All data local-only
- Templates and exchange rates bundled

### 2. Data Encryption
Hive supports encryption (can be added):

```dart
final encryptionKey = Hive.generateSecureKey();
await Hive.openBox('subscriptions', encryptionCipher: HiveAesCipher(encryptionKey));
```

Currently not implemented to keep it simple, but easy to add.

### 3. Notification Privacy
Notifications show minimal info:
- Subscription name
- Amount
- No sensitive cancellation details

### 4. Export Safety
JSON exports are plain text - users should handle securely:
- Don't share publicly
- Store encrypted backups
- Use secure sharing methods

## Future Architecture Improvements

### Potential Enhancements:
1. **Multi-platform support**: Add web/desktop via conditional imports
2. **Encryption by default**: Add Hive encryption for sensitive data
3. **Plugin architecture**: Allow custom templates/categories via user-defined plugins
4. **Offline-first sync**: Optional encrypted peer-to-peer backup across devices
5. **Modular features**: Extract features into packages for reusability

---

**Last Updated**: 2026-02-04
**Version**: 1.0.0 (Phase 1 - In Progress)
