# CustomSubs Refactoring Plan
## Improving Testability and Maintainability

**Created:** February 7, 2026
**Status:** Planning Phase
**Priority:** High
**Estimated Total Effort:** 15-20 days (phased approach)

---

## Executive Summary

This document outlines a comprehensive refactoring plan to improve testability and maintainability of the CustomSubs codebase. The analysis revealed **9 critical files** with significant testability issues and **zero meaningful test coverage** (only 1 smoke test exists).

### Key Problems Identified

1. **No service abstractions** → Cannot mock dependencies for testing
2. **Massive screen files** (824 lines) with embedded nested widgets
3. **Business logic scattered** across UI widgets instead of controllers
4. **Direct platform dependencies** (Hive, flutter_local_notifications) without abstraction
5. **Zero test infrastructure** → No mocking library, no unit tests, no integration tests
6. **Singleton patterns** preventing test isolation

### Success Criteria

- ✅ All services have interface abstractions for mocking
- ✅ Screen files under 400 lines with single responsibility
- ✅ Business logic extracted from UI into testable controllers/services
- ✅ 60%+ code coverage on critical business logic
- ✅ Full test suite for notification scheduling (most critical feature)
- ✅ Integration tests for core user flows (add subscription, backup/restore)

---

## Phase 1: Test Infrastructure Setup (Day 1)
**Priority:** CRITICAL
**Estimated Effort:** 1 day
**Risk:** Low

### Goals
Set up the foundational testing infrastructure without breaking existing functionality.

### Tasks

#### 1.1 Add Test Dependencies
**File:** `pubspec.yaml`

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.11
  hive_generator: ^2.0.1
  riverpod_generator: ^2.4.0
  flutter_launcher_icons: ^0.13.1

  # NEW TESTING DEPENDENCIES
  mocktail: ^1.4.0          # Modern mocking library (null-safe, easier than mockito)
  fake_async: ^1.3.0        # Time-based testing for notifications
  test: ^1.24.0             # Additional test utilities
  integration_test:         # End-to-end testing
    sdk: flutter
```

**Rationale:**
- **mocktail** over mockito: No code generation needed, simpler API, better null-safety
- **fake_async**: Essential for testing notification scheduling with time manipulation
- **integration_test**: Built-in Flutter e2e testing framework

#### 1.2 Create Test Helpers
**New File:** `test/helpers/test_helpers.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;

/// Initialize test environment for all tests
Future<void> initializeTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for tests (in-memory)
  await Hive.initFlutter();

  // Initialize timezone data for notification tests
  tz.initializeTimeZones();
}

/// Clean up Hive boxes after tests
Future<void> cleanupHive() async {
  await Hive.deleteFromDisk();
}

/// Create a mock ProviderContainer for Riverpod tests
ProviderContainer createTestContainer({
  List<Override> overrides = const [],
}) {
  return ProviderContainer(
    overrides: overrides,
  );
}
```

#### 1.3 Create Mock Factories
**New File:** `test/mocks/mock_factories.dart`

```dart
import 'package:mocktail/mocktail.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';

// Service mocks
class MockNotificationService extends Mock implements NotificationService {}
class MockBackupService extends Mock implements BackupService {}
class MockSubscriptionRepository extends Mock implements SubscriptionRepository {}

// Platform mocks
class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}
class MockBox<T> extends Mock implements Box<T> {}

// Setup common mock behaviors
void setupDefaultMocks() {
  registerFallbackValue(TZDateTime.now(local));
  registerFallbackValue(NotificationDetails());
}
```

**Deliverables:**
- ✅ Updated `pubspec.yaml` with test dependencies
- ✅ `test/helpers/test_helpers.dart` created
- ✅ `test/mocks/mock_factories.dart` created
- ✅ Run `flutter pub get` to install new dependencies
- ✅ Verify basic test runs: `flutter test test/widget_test.dart`

**Validation:**
```bash
flutter pub get
flutter test test/widget_test.dart
```

---

## Phase 2: Extract Service Interfaces (Days 2-4)
**Priority:** CRITICAL
**Estimated Effort:** 3 days
**Risk:** Medium

### Goals
Create interface abstractions for all services to enable mocking without breaking existing functionality.

### 2.1 NotificationService Interface (Day 2)
**Priority:** CRITICAL (most important app feature)

**Current File:** `lib/data/services/notification_service.dart` (575 lines)

**New Structure:**
```
lib/data/services/
├── notification/
│   ├── i_notification_service.dart         # Interface
│   ├── notification_service_impl.dart      # Implementation (rename from notification_service.dart)
│   ├── notification_content_builder.dart   # Extract formatting logic
│   └── notification_id_generator.dart      # Extract ID generation logic
```

**Step-by-step:**

1. **Create Interface** (`i_notification_service.dart`)

```dart
/// Interface for scheduling and managing subscription reminders.
///
/// Enables testing by allowing mock implementations without
/// requiring flutter_local_notifications plugin.
abstract class INotificationService {
  /// Initialize notification service with platform-specific configuration
  Future<void> init();

  /// Request notification permissions from user
  Future<bool> requestPermissions();

  /// Schedule all notifications for a subscription
  Future<void> scheduleNotifications(Subscription subscription);

  /// Cancel all notifications for a subscription
  Future<void> cancelNotifications(String subscriptionId);

  /// Cancel all pending notifications
  Future<void> cancelAll();

  /// Fire a test notification immediately
  Future<void> fireTestNotification();
}
```

2. **Extract Content Builder** (`notification_content_builder.dart`)

```dart
/// Builds notification titles and bodies from subscription data.
///
/// Pure functions with no side effects → easily testable.
class NotificationContentBuilder {
  /// Build first reminder notification (e.g., 7 days before)
  static NotificationContent buildFirstReminder(
    Subscription subscription,
    int daysUntil,
  ) {
    final currencySymbol = _getCurrencySymbol(subscription.currencyCode);
    final amount = _formatAmount(subscription.amount);

    return NotificationContent(
      title: '📅 ${subscription.name} — Billing in $daysUntil days',
      body: '$currencySymbol$amount/${subscription.cycle.shortName} '
            'charges on ${DateFormat.yMMMd().format(subscription.nextBillingDate)}',
    );
  }

  // ... Similar methods for second reminder, day-of, trial ending

  // Pure helper functions (no dependencies)
  static String _getCurrencySymbol(String code) { /* ... */ }
  static String _formatAmount(double amount) { /* ... */ }
}

class NotificationContent {
  final String title;
  final String body;

  const NotificationContent({required this.title, required this.body});
}
```

3. **Extract ID Generator** (`notification_id_generator.dart`)

```dart
/// Generates stable, unique notification IDs from subscription data.
///
/// Deterministic IDs allow canceling specific notifications without
/// maintaining a notification ID registry.
class NotificationIdGenerator {
  /// Generate notification ID for first reminder
  static int firstReminder(String subscriptionId) {
    return _hash('$subscriptionId:reminder1');
  }

  /// Generate notification ID for second reminder
  static int secondReminder(String subscriptionId) {
    return _hash('$subscriptionId:reminder2');
  }

  /// Generate notification ID for day-of reminder
  static int dayOf(String subscriptionId) {
    return _hash('$subscriptionId:dayof');
  }

  /// Generate notification ID for trial ending reminder
  static int trialEnd(String subscriptionId) {
    return _hash('$subscriptionId:trial_end');
  }

  /// Stable hash function that fits in int32 range
  static int _hash(String input) {
    return input.hashCode.abs() % 2147483647;
  }
}
```

4. **Update Implementation** (`notification_service_impl.dart`)

```dart
/// Production implementation of INotificationService.
///
/// Depends on flutter_local_notifications plugin and should
/// only be used in production. Tests should use mock implementations.
class NotificationServiceImpl implements INotificationService {
  final FlutterLocalNotificationsPlugin _plugin;

  // Constructor injection for testability
  NotificationServiceImpl({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  @override
  Future<void> scheduleNotifications(Subscription subscription) async {
    // Use NotificationContentBuilder for content
    final firstReminderDays = subscription.reminders.firstReminderDays;
    final content = NotificationContentBuilder.buildFirstReminder(
      subscription,
      firstReminderDays,
    );

    // Use NotificationIdGenerator for IDs
    final id = NotificationIdGenerator.firstReminder(subscription.id);

    // Calculate TZDateTime
    final scheduledDate = TZDateTime.from(
      subscription.nextBillingDate.subtract(Duration(days: firstReminderDays)),
      local,
    );

    // Schedule via plugin
    await _plugin.zonedSchedule(
      id,
      content.title,
      content.body,
      scheduledDate,
      _notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    // ... repeat for other reminder types
  }

  // ... rest of implementation
}
```

5. **Update Riverpod Provider**

```dart
// In notification_service_impl.dart or providers file
@riverpod
Future<INotificationService> notificationService(NotificationServiceRef ref) async {
  final service = NotificationServiceImpl();
  await service.init();
  return service;
}
```

6. **Write Tests** (`test/services/notification_service_test.dart`)

```dart
void main() {
  group('NotificationContentBuilder', () {
    test('buildFirstReminder creates correct content', () {
      final subscription = Subscription(
        id: 'test-id',
        name: 'Netflix',
        amount: 15.99,
        currencyCode: 'USD',
        cycle: SubscriptionCycle.monthly,
        nextBillingDate: DateTime(2026, 3, 1),
        // ... other fields
      );

      final content = NotificationContentBuilder.buildFirstReminder(
        subscription,
        7, // days until
      );

      expect(content.title, contains('Netflix'));
      expect(content.title, contains('7 days'));
      expect(content.body, contains('\$15.99'));
    });
  });

  group('NotificationIdGenerator', () {
    test('generates stable IDs for same subscription', () {
      const id = 'test-sub-123';

      final id1 = NotificationIdGenerator.firstReminder(id);
      final id2 = NotificationIdGenerator.firstReminder(id);

      expect(id1, equals(id2));
    });

    test('generates different IDs for different reminder types', () {
      const id = 'test-sub-123';

      final firstId = NotificationIdGenerator.firstReminder(id);
      final secondId = NotificationIdGenerator.secondReminder(id);

      expect(firstId, isNot(equals(secondId)));
    });
  });

  group('NotificationServiceImpl', () {
    late MockFlutterLocalNotificationsPlugin mockPlugin;
    late NotificationServiceImpl service;

    setUp(() {
      mockPlugin = MockFlutterLocalNotificationsPlugin();
      service = NotificationServiceImpl(plugin: mockPlugin);
    });

    test('scheduleNotifications calls plugin.zonedSchedule', () async {
      // Arrange
      when(() => mockPlugin.zonedSchedule(
        any(),
        any(),
        any(),
        any(),
        any(),
        uiLocalNotificationDateInterpretation: any(named: 'uiLocalNotificationDateInterpretation'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
      )).thenAnswer((_) async {});

      final subscription = _createTestSubscription();

      // Act
      await service.scheduleNotifications(subscription);

      // Assert
      verify(() => mockPlugin.zonedSchedule(
        any(),
        any(),
        any(),
        any(),
        any(),
        uiLocalNotificationDateInterpretation: any(named: 'uiLocalNotificationDateInterpretation'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
      )).called(greaterThan(0)); // Called for each reminder type
    });
  });
}
```

**Deliverables:**
- ✅ `INotificationService` interface created
- ✅ `NotificationContentBuilder` extracted with pure functions
- ✅ `NotificationIdGenerator` extracted
- ✅ `NotificationServiceImpl` updated to use new structure
- ✅ Riverpod provider updated to use interface type
- ✅ Comprehensive unit tests written
- ✅ All existing functionality still works (manual verification)

**Validation:**
```bash
flutter test test/services/notification_service_test.dart
flutter run  # Verify notifications still work in app
```

### 2.2 SubscriptionRepository Interface (Day 3)
**Priority:** HIGH

**Current File:** `lib/data/repositories/subscription_repository.dart` (392 lines)

**New Structure:**
```
lib/data/repositories/
├── subscription/
│   ├── i_subscription_repository.dart          # Interface
│   ├── subscription_repository_impl.dart       # Hive implementation
│   ├── subscription_date_calculator.dart       # Extract date logic
│   └── models/
│       └── subscription_query_params.dart      # Query parameters
```

**Step-by-step:**

1. **Create Interface**

```dart
abstract class ISubscriptionRepository {
  Future<void> init();
  Future<List<Subscription>> getAll();
  Future<Subscription?> getById(String id);
  Future<void> upsert(Subscription subscription);
  Future<void> delete(String id);
  Future<void> deleteAll();
  Future<List<Subscription>> advanceOverdueBillingDates();
  Stream<BoxEvent> watch();
}
```

2. **Extract Date Calculator**

```dart
/// Pure business logic for calculating subscription billing dates.
/// No dependencies on Hive or any external services.
class SubscriptionDateCalculator {
  /// Calculate next billing date from a given date and cycle
  static DateTime calculateNextDate(DateTime from, SubscriptionCycle cycle) {
    switch (cycle) {
      case SubscriptionCycle.weekly:
        return from.add(const Duration(days: 7));
      case SubscriptionCycle.biweekly:
        return from.add(const Duration(days: 14));
      case SubscriptionCycle.monthly:
        return DateTime(from.year, from.month + 1, from.day);
      case SubscriptionCycle.quarterly:
        return DateTime(from.year, from.month + 3, from.day);
      case SubscriptionCycle.biannual:
        return DateTime(from.year, from.month + 6, from.day);
      case SubscriptionCycle.yearly:
        return DateTime(from.year + 1, from.month, from.day);
    }
  }

  /// Check if a billing date is overdue
  static bool isOverdue(DateTime billingDate) {
    return billingDate.isBefore(DateTime.now());
  }

  /// Advance billing date to next future date
  static DateTime advanceToFuture(DateTime current, SubscriptionCycle cycle) {
    var next = current;
    while (isOverdue(next)) {
      next = calculateNextDate(next, cycle);
    }
    return next;
  }
}
```

3. **Update Implementation**

```dart
class SubscriptionRepositoryImpl implements ISubscriptionRepository {
  late Box<Subscription> _box;

  @override
  Future<List<Subscription>> advanceOverdueBillingDates() async {
    final all = await getAll();
    final updated = <Subscription>[];

    for (final sub in all) {
      if (SubscriptionDateCalculator.isOverdue(sub.nextBillingDate)) {
        final newDate = SubscriptionDateCalculator.advanceToFuture(
          sub.nextBillingDate,
          sub.cycle,
        );

        final updatedSub = sub.copyWith(
          nextBillingDate: newDate,
          isPaid: false,
        );

        await upsert(updatedSub);
        updated.add(updatedSub);
      }
    }

    return updated;
  }
}
```

4. **Write Tests**

```dart
void main() {
  group('SubscriptionDateCalculator', () {
    test('calculateNextDate handles monthly cycle correctly', () {
      final start = DateTime(2026, 1, 15);
      final next = SubscriptionDateCalculator.calculateNextDate(
        start,
        SubscriptionCycle.monthly,
      );

      expect(next, DateTime(2026, 2, 15));
    });

    test('isOverdue returns true for past dates', () {
      final pastDate = DateTime(2025, 1, 1);
      expect(SubscriptionDateCalculator.isOverdue(pastDate), isTrue);
    });

    test('advanceToFuture skips multiple cycles if needed', () {
      final veryOld = DateTime(2024, 1, 1);
      final future = SubscriptionDateCalculator.advanceToFuture(
        veryOld,
        SubscriptionCycle.monthly,
      );

      expect(future.isAfter(DateTime.now()), isTrue);
    });
  });

  group('SubscriptionRepositoryImpl', () {
    // Integration tests with in-memory Hive box
    late SubscriptionRepositoryImpl repository;

    setUp(() async {
      await Hive.initFlutter();
      repository = SubscriptionRepositoryImpl();
      await repository.init();
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
    });

    test('upsert adds new subscription', () async {
      final sub = _createTestSubscription();
      await repository.upsert(sub);

      final retrieved = await repository.getById(sub.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.name, sub.name);
    });

    test('advanceOverdueBillingDates updates overdue subscriptions', () async {
      final overdueSub = _createTestSubscription(
        nextBillingDate: DateTime(2025, 1, 1), // Past date
      );
      await repository.upsert(overdueSub);

      final updated = await repository.advanceOverdueBillingDates();

      expect(updated, hasLength(1));
      expect(updated.first.nextBillingDate.isAfter(DateTime.now()), isTrue);
      expect(updated.first.isPaid, isFalse);
    });
  });
}
```

**Deliverables:**
- ✅ `ISubscriptionRepository` interface
- ✅ `SubscriptionDateCalculator` with pure functions
- ✅ Implementation updated
- ✅ Unit and integration tests
- ✅ No regressions in app functionality

### 2.3 BackupService Interface (Day 4)
**Priority:** MEDIUM

**Current File:** `lib/data/services/backup_service.dart` (284 lines)

**New Structure:**
```
lib/data/services/backup/
├── i_backup_service.dart              # Interface
├── backup_service_impl.dart           # Implementation
├── backup_json_serializer.dart        # JSON parsing/serialization
├── duplicate_detector.dart            # Duplicate detection logic
├── adapters/
│   ├── file_picker_adapter.dart       # Abstract file picker
│   ├── share_adapter.dart             # Abstract share functionality
│   └── file_system_adapter.dart       # Abstract file I/O
```

**Interface:**

```dart
abstract class IBackupService {
  Future<BackupResult> exportBackup();
  Future<ImportResult> importBackup();
}

class BackupResult {
  final bool success;
  final String? filePath;
  final String? errorMessage;
  final int subscriptionCount;
}

class ImportResult {
  final bool success;
  final int importedCount;
  final int duplicateCount;
  final String? errorMessage;
}
```

**Key Extractions:**

1. **BackupJsonSerializer** - Pure functions for JSON conversion
2. **DuplicateDetector** - Pure logic for finding duplicates
3. **Platform Adapters** - Mockable wrappers for file_picker, share_plus, path_provider

**Benefits:**
- Test backup/import logic without file system
- Test JSON serialization independently
- Test duplicate detection with known datasets
- Mock file picker and share dialogs in widget tests

---

## Phase 3: Split Large Screen Files (Days 5-9)
**Priority:** HIGH
**Estimated Effort:** 5 days
**Risk:** Medium-High (UI changes)

### Goals
Break down massive screen files into smaller, testable, single-responsibility components.

### 3.1 Split SubscriptionDetailScreen (Days 5-6)
**Priority:** CRITICAL
**Current:** 824 lines in one file
**Target:** 5-6 files, each under 200 lines

**Current Issues:**
- 7+ nested widget classes defined inline
- URL launching and phone dialing mixed into widgets
- Complex cancellation checklist logic
- Deletion confirmation flow embedded
- No component reusability

**New Structure:**
```
lib/features/subscription_detail/
├── subscription_detail_screen.dart              # Main screen (150 lines)
├── subscription_detail_controller.dart          # Existing controller
├── widgets/
│   ├── detail_header_card.dart                  # Header with icon/name
│   ├── billing_info_card.dart                   # Billing details
│   ├── cancellation_card.dart                   # Cancellation info
│   ├── notes_card.dart                          # User notes
│   ├── reminder_card.dart                       # Reminder settings
│   └── checklist/
│       ├── cancellation_checklist.dart          # Interactive checklist
│       ├── checklist_controller.dart            # Checklist state management
│       └── checklist_item.dart                  # Individual checklist item
├── dialogs/
│   ├── delete_confirmation_dialog.dart          # Deletion flow
│   └── cancellation_detail_dialog.dart          # Full cancellation modal
└── services/
    ├── url_launcher_service.dart                # Abstract URL launching
    └── phone_dialer_service.dart                # Abstract phone dialing
```

**Step-by-step:**

1. **Day 5: Extract Platform Services**

Create testable wrappers for external services:

```dart
// url_launcher_service.dart
abstract class IUrlLauncherService {
  Future<bool> canLaunch(String url);
  Future<void> launch(String url);
}

class UrlLauncherServiceImpl implements IUrlLauncherService {
  @override
  Future<bool> canLaunch(String url) async {
    final uri = Uri.parse(url);
    return await canLaunchUrl(uri);
  }

  @override
  Future<void> launch(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }
}
```

2. **Day 5: Extract Dialogs**

```dart
// delete_confirmation_dialog.dart
class DeleteConfirmationDialog extends StatelessWidget {
  final String subscriptionName;
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({
    required this.subscriptionName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Subscription'),
      content: Text(
        'This will remove $subscriptionName and cancel all reminders. '
        'This cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
```

3. **Day 6: Extract Checklist System**

```dart
// checklist_controller.dart
@riverpod
class ChecklistController extends _$ChecklistController {
  @override
  List<bool> build(String subscriptionId) {
    final subscription = ref.watch(
      subscriptionDetailControllerProvider(subscriptionId),
    ).value;

    return subscription?.checklistCompleted ?? [];
  }

  Future<void> toggleItem(int index, bool value) async {
    final subscription = ref.read(
      subscriptionDetailControllerProvider(subscriptionId),
    ).value!;

    final newCompleted = [...state];
    newCompleted[index] = value;

    final updated = subscription.copyWith(checklistCompleted: newCompleted);
    await ref.read(subscriptionRepositoryProvider).upsert(updated);

    state = newCompleted;
  }
}
```

4. **Day 6: Refactor Main Screen**

```dart
// subscription_detail_screen.dart (now ~150 lines)
class SubscriptionDetailScreen extends ConsumerWidget {
  final String subscriptionId;

  const SubscriptionDetailScreen({required this.subscriptionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(
      subscriptionDetailControllerProvider(subscriptionId),
    );

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteDialog(context, ref),
          ),
        ],
      ),
      body: subscriptionAsync.when(
        data: (subscription) => _buildContent(context, ref, subscription),
        loading: () => const SkeletonDetailScreen(),
        error: (err, stack) => ErrorView(error: err),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Subscription subscription,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          DetailHeaderCard(subscription: subscription),
          const SizedBox(height: AppSizes.base),
          BillingInfoCard(subscription: subscription),
          if (_hasCancellationInfo(subscription)) ...[
            const SizedBox(height: AppSizes.base),
            CancellationCard(subscription: subscription),
          ],
          if (subscription.notes != null) ...[
            const SizedBox(height: AppSizes.base),
            NotesCard(notes: subscription.notes!),
          ],
          const SizedBox(height: AppSizes.base),
          ReminderCard(subscription: subscription),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        subscriptionName: subscription.name,
        onConfirm: () => _deleteSubscription(ref),
      ),
    );
  }

  Future<void> _deleteSubscription(WidgetRef ref) async {
    await ref.read(
      subscriptionDetailControllerProvider(subscriptionId).notifier,
    ).delete();

    if (context.mounted) {
      context.pop();
    }
  }
}
```

**Deliverables:**
- ✅ 7 widget files extracted from main screen
- ✅ 2 dialog files created
- ✅ 3 service adapters created
- ✅ Checklist controller extracted
- ✅ Main screen under 200 lines
- ✅ Widget tests for each extracted component
- ✅ No visual regressions

### 3.2 Split AddSubscriptionScreen (Days 7-8)
**Priority:** HIGH
**Current:** 752 lines
**Target:** 4-5 files, each under 250 lines

**New Structure:**
```
lib/features/add_subscription/
├── add_subscription_screen.dart              # Main form screen (200 lines)
├── add_subscription_controller.dart          # Existing controller
├── template_picker_dialog.dart               # Separate dialog (150 lines)
├── forms/
│   ├── subscription_form_state.dart          # Form state model
│   ├── subscription_form_validator.dart      # Pure validation logic
│   └── subscription_form_fields.dart         # Reusable form fields
└── widgets/
    ├── trial_configuration_section.dart
    ├── reminder_configuration_section.dart
    ├── cancellation_info_section.dart
    └── template_grid_item.dart               # Existing
```

**Key Improvements:**

1. **Form State Encapsulation**

```dart
// subscription_form_state.dart
class SubscriptionFormState {
  final String name;
  final String amount;
  final String currencyCode;
  final SubscriptionCycle cycle;
  final DateTime nextBillingDate;
  final bool isTrial;
  final DateTime? trialEndDate;
  final String? postTrialAmount;

  // ... other fields

  SubscriptionFormState copyWith({...}) { /* ... */ }

  // Validation
  FormValidationResult validate() {
    return SubscriptionFormValidator.validate(this);
  }

  // Convert to Subscription model
  Subscription toSubscription() { /* ... */ }
}
```

2. **Pure Validation Logic**

```dart
// subscription_form_validator.dart
class SubscriptionFormValidator {
  static FormValidationResult validate(SubscriptionFormState state) {
    final errors = <String, String>{};

    if (state.name.trim().isEmpty) {
      errors['name'] = 'Name is required';
    }

    final amount = double.tryParse(state.amount);
    if (amount == null || amount <= 0) {
      errors['amount'] = 'Amount must be a positive number';
    }

    if (state.nextBillingDate.isBefore(DateTime.now())) {
      errors['nextBillingDate'] = 'Billing date cannot be in the past';
    }

    if (state.isTrial) {
      if (state.trialEndDate == null) {
        errors['trialEndDate'] = 'Trial end date is required';
      }
      if (state.postTrialAmount == null ||
          double.tryParse(state.postTrialAmount!) == null) {
        errors['postTrialAmount'] = 'Post-trial amount is required';
      }
    }

    return FormValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}
```

3. **Separate Template Picker**

```dart
// template_picker_dialog.dart
class TemplatePickerDialog extends ConsumerWidget {
  final Function(SubscriptionTemplate) onTemplateSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(subscriptionTemplatesProvider);

    return Dialog(
      child: Column(
        children: [
          // Search bar
          TextField(
            onChanged: (query) => ref.read(templateSearchQueryProvider.notifier).state = query,
          ),

          // Grid of templates
          Expanded(
            child: templatesAsync.when(
              data: (templates) => GridView.builder(
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  return TemplateGridItem(
                    template: templates[index],
                    onTap: () {
                      Navigator.pop(context);
                      onTemplateSelected(templates[index]);
                    },
                  );
                },
              ),
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => ErrorView(error: err),
            ),
          ),
        ],
      ),
    );
  }
}
```

**Deliverables:**
- ✅ Form state model extracted
- ✅ Validation logic extracted (pure functions)
- ✅ Template picker moved to dialog
- ✅ Form sections extracted to separate widgets
- ✅ Main screen under 250 lines
- ✅ Unit tests for validation logic
- ✅ Widget tests for form sections

### 3.3 Refactor HomeScreen (Day 9)
**Priority:** MEDIUM
**Current:** 732 lines
**Target:** 3-4 files, each under 300 lines

**New Structure:**
```
lib/features/home/
├── home_screen.dart                     # Main screen (300 lines)
├── home_controller.dart                 # Existing controller
├── home_lifecycle_manager.dart          # Extract lifecycle logic
├── home_animation_controller.dart       # Extract animation setup
└── widgets/
    ├── spending_summary_card.dart
    ├── quick_actions_row.dart
    ├── upcoming_subscriptions_list.dart
    ├── subscription_tile.dart
    └── empty_state.dart
```

**Key Extractions:**

1. **Lifecycle Manager Mixin**

```dart
// home_lifecycle_manager.dart
mixin HomeLifecycleManager on State {
  Future<void> onAppResumed();
  Future<void> onRefresh();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkBackupReminder();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onAppResumed();
    }
  }

  Future<void> _checkBackupReminder() async {
    // Backup reminder logic
  }
}
```

2. **Animation Controller**

```dart
// home_animation_controller.dart
class HomeAnimationController {
  final TickerProvider vsync;
  late AnimationController _controller;
  late List<Animation<double>> _tileAnimations;

  HomeAnimationController({required this.vsync});

  void initialize(int itemCount) {
    _controller = AnimationController(
      vsync: vsync,
      duration: Duration(milliseconds: 300 + (itemCount * 50).clamp(0, 300)),
    );

    _tileAnimations = List.generate(itemCount, (index) {
      final start = (index * 0.1).clamp(0.0, 0.6);
      final end = (start + 0.4).clamp(0.0, 1.0);

      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _controller.forward();
  }

  Animation<double> animationAt(int index) => _tileAnimations[index];

  void dispose() {
    _controller.dispose();
  }
}
```

**Deliverables:**
- ✅ Lifecycle logic extracted to mixin
- ✅ Animation controller extracted
- ✅ 5 widget files extracted
- ✅ Main screen under 300 lines
- ✅ Widget tests for extracted components

---

## Phase 4: Move Business Logic to Controllers (Days 10-11)
**Priority:** MEDIUM
**Estimated Effort:** 2 days

### Goals
Ensure all business logic lives in controllers/services, not in UI widgets.

### 4.1 AnalyticsController Refactor
**Current Issues:**
- Direct Hive box access in `build()`
- Side effects during state construction
- Complex calculations inline

**New Structure:**
```
lib/features/analytics/
├── analytics_controller.dart             # Simplified controller
├── services/
│   ├── analytics_calculator.dart         # Pure calculation logic
│   ├── monthly_snapshot_service.dart     # Snapshot persistence
│   └── currency_converter.dart           # Currency conversion wrapper
```

**Extracted Services:**

```dart
// analytics_calculator.dart
class AnalyticsCalculator {
  /// Calculate total monthly spend from subscriptions
  static double calculateMonthlyTotal(
    List<Subscription> subscriptions,
    String primaryCurrency,
    CurrencyConverter converter,
  ) {
    return subscriptions.fold(0.0, (total, sub) {
      final monthlyCost = _toMonthlyEquivalent(sub.amount, sub.cycle);
      final converted = converter.convert(
        amount: monthlyCost,
        from: sub.currencyCode,
        to: primaryCurrency,
      );
      return total + converted;
    });
  }

  /// Calculate category breakdown
  static Map<SubscriptionCategory, double> calculateCategoryBreakdown(
    List<Subscription> subscriptions,
    String primaryCurrency,
    CurrencyConverter converter,
  ) {
    final breakdown = <SubscriptionCategory, double>{};

    for (final sub in subscriptions) {
      final monthlyCost = _toMonthlyEquivalent(sub.amount, sub.cycle);
      final converted = converter.convert(
        amount: monthlyCost,
        from: sub.currencyCode,
        to: primaryCurrency,
      );

      breakdown.update(
        sub.category,
        (value) => value + converted,
        ifAbsent: () => converted,
      );
    }

    return breakdown;
  }

  static double _toMonthlyEquivalent(double amount, SubscriptionCycle cycle) {
    switch (cycle) {
      case SubscriptionCycle.weekly: return amount * 4.33;
      case SubscriptionCycle.biweekly: return amount * 2.17;
      case SubscriptionCycle.monthly: return amount;
      case SubscriptionCycle.quarterly: return amount / 3;
      case SubscriptionCycle.biannual: return amount / 6;
      case SubscriptionCycle.yearly: return amount / 12;
    }
  }
}
```

```dart
// monthly_snapshot_service.dart
class MonthlySnapshotService {
  final Box<MonthlySnapshot> _box;

  MonthlySnapshotService(this._box);

  Future<void> saveCurrentSnapshot({
    required double totalMonthly,
    required int activeCount,
    required Map<SubscriptionCategory, double> categoryBreakdown,
  }) async {
    final key = _getCurrentMonthKey();

    final snapshot = MonthlySnapshot(
      month: key,
      totalMonthly: totalMonthly,
      activeSubscriptionCount: activeCount,
      categoryBreakdown: categoryBreakdown,
      timestamp: DateTime.now(),
    );

    await _box.put(key, snapshot);
  }

  List<MonthlySnapshot> getRecentSnapshots({int months = 12}) {
    return _box.values
        .where((s) => _isRecent(s.timestamp, months))
        .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  String _getCurrentMonthKey() => DateFormat('yyyy-MM').format(DateTime.now());

  bool _isRecent(DateTime timestamp, int months) {
    final cutoff = DateTime.now().subtract(Duration(days: months * 30));
    return timestamp.isAfter(cutoff);
  }
}
```

**Updated Controller:**

```dart
// analytics_controller.dart
@riverpod
class AnalyticsController extends _$AnalyticsController {
  late MonthlySnapshotService _snapshotService;

  @override
  Future<AnalyticsData> build() async {
    _snapshotService = MonthlySnapshotService(
      Hive.box<MonthlySnapshot>('monthly_snapshots'),
    );

    return _calculateAnalytics();
  }

  Future<AnalyticsData> _calculateAnalytics() async {
    final subscriptions = await ref.watch(subscriptionRepositoryProvider).getAll();
    final primaryCurrency = ref.watch(primaryCurrencyProvider);
    final converter = CurrencyConverter();

    // Pure calculations
    final totalMonthly = AnalyticsCalculator.calculateMonthlyTotal(
      subscriptions,
      primaryCurrency,
      converter,
    );

    final categoryBreakdown = AnalyticsCalculator.calculateCategoryBreakdown(
      subscriptions,
      primaryCurrency,
      converter,
    );

    final topSubscriptions = AnalyticsCalculator.getTopSubscriptions(
      subscriptions,
      primaryCurrency,
      converter,
      limit: 5,
    );

    // Save snapshot (separate from state calculation)
    await _snapshotService.saveCurrentSnapshot(
      totalMonthly: totalMonthly,
      activeCount: subscriptions.length,
      categoryBreakdown: categoryBreakdown,
    );

    final recentSnapshots = _snapshotService.getRecentSnapshots(months: 12);

    return AnalyticsData(
      totalMonthly: totalMonthly,
      yearlyProjection: totalMonthly * 12,
      activeCount: subscriptions.length,
      categoryBreakdown: categoryBreakdown,
      topSubscriptions: topSubscriptions,
      monthlyHistory: recentSnapshots,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _calculateAnalytics());
  }
}
```

**Tests:**

```dart
void main() {
  group('AnalyticsCalculator', () {
    test('calculateMonthlyTotal converts all subscriptions to monthly', () {
      final subs = [
        _createSubscription(amount: 100, cycle: SubscriptionCycle.monthly, currency: 'USD'),
        _createSubscription(amount: 1200, cycle: SubscriptionCycle.yearly, currency: 'USD'),
        _createSubscription(amount: 50, cycle: SubscriptionCycle.weekly, currency: 'USD'),
      ];

      final total = AnalyticsCalculator.calculateMonthlyTotal(
        subs,
        'USD',
        MockCurrencyConverter(),
      );

      // 100 + (1200/12) + (50*4.33) = 100 + 100 + 216.50 = 416.50
      expect(total, closeTo(416.50, 0.01));
    });

    test('calculateCategoryBreakdown groups by category', () {
      final subs = [
        _createSubscription(amount: 10, category: SubscriptionCategory.entertainment),
        _createSubscription(amount: 20, category: SubscriptionCategory.entertainment),
        _createSubscription(amount: 30, category: SubscriptionCategory.productivity),
      ];

      final breakdown = AnalyticsCalculator.calculateCategoryBreakdown(
        subs,
        'USD',
        MockCurrencyConverter(),
      );

      expect(breakdown[SubscriptionCategory.entertainment], 30.0);
      expect(breakdown[SubscriptionCategory.productivity], 30.0);
    });
  });
}
```

**Deliverables:**
- ✅ `AnalyticsCalculator` with pure functions
- ✅ `MonthlySnapshotService` extracted
- ✅ `CurrencyConverter` wrapper created
- ✅ Controller simplified (no side effects in build)
- ✅ Comprehensive unit tests
- ✅ No behavioral changes in app

### 4.2 HomeController Business Logic
**Tasks:**
- Extract backup reminder logic to `BackupReminderService`
- Extract currency total calculation to pure functions
- Extract subscription filtering/sorting to `UpcomingSubscriptionFilter`

---

## Phase 5: Fix Singleton Patterns (Day 12)
**Priority:** MEDIUM
**Estimated Effort:** 1 day

### 5.1 Convert UndoService to Riverpod

**Current Issue:**
- Singleton pattern prevents test isolation
- Global mutable state shared across app
- Cannot reset between tests
- Time-based expiry not mockable

**Solution:**

```dart
// undo_service.dart
@riverpod
class UndoService extends _$UndoService {
  // Inject clock for testable time-based logic
  final Clock _clock;

  UndoService({Clock? clock}) : _clock = clock ?? const Clock();

  @override
  UndoState build() {
    return const UndoState();
  }

  void storeDeletedSubscription(Subscription subscription) {
    state = state.copyWith(
      deletedSubscription: subscription,
      deleteTimestamp: _clock.now(),
    );
  }

  Future<void> undoDelete() async {
    if (!canUndo()) return;

    final sub = state.deletedSubscription!;
    await ref.read(subscriptionRepositoryProvider).upsert(sub);

    state = const UndoState(); // Clear
  }

  bool canUndo() {
    if (state.deletedSubscription == null) return false;

    final elapsed = _clock.now().difference(state.deleteTimestamp!);
    return elapsed.inSeconds < 10;
  }

  void reset() {
    state = const UndoState();
  }
}

@freezed
class UndoState with _$UndoState {
  const factory UndoState({
    Subscription? deletedSubscription,
    DateTime? deleteTimestamp,
    String? previousCurrency,
    int? previousReminderTime,
  }) = _UndoState;
}

// Clock abstraction for testing
abstract class Clock {
  const Clock();
  DateTime now();
}

class SystemClock extends Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

class FixedClock extends Clock {
  final DateTime _fixedTime;

  const FixedClock(this._fixedTime);

  @override
  DateTime now() => _fixedTime;
}
```

**Tests:**

```dart
void main() {
  test('undoDelete restores subscription within 10 seconds', () async {
    final fixedTime = DateTime(2026, 1, 1, 12, 0, 0);
    final clock = FixedClock(fixedTime);
    final container = ProviderContainer(
      overrides: [
        undoServiceProvider.overrideWith((ref) => UndoService(clock: clock)),
      ],
    );

    final service = container.read(undoServiceProvider.notifier);
    final sub = _createTestSubscription();

    service.storeDeletedSubscription(sub);
    expect(service.canUndo(), isTrue);

    // Advance time by 5 seconds
    final laterClock = FixedClock(fixedTime.add(Duration(seconds: 5)));
    // ... update provider with new clock

    expect(service.canUndo(), isTrue);
  });

  test('canUndo returns false after 10 seconds', () {
    final fixedTime = DateTime(2026, 1, 1, 12, 0, 0);
    final clock = FixedClock(fixedTime);
    final service = UndoService(clock: clock);

    service.storeDeletedSubscription(_createTestSubscription());

    // Advance time by 11 seconds
    final laterClock = FixedClock(fixedTime.add(Duration(seconds: 11)));
    final laterService = UndoService(clock: laterClock);
    laterService.state = service.state; // Copy state

    expect(laterService.canUndo(), isFalse);
  });
}
```

---

## Phase 6: Write Comprehensive Test Suite (Days 13-15)
**Priority:** CRITICAL
**Estimated Effort:** 3 days

### 6.1 Unit Tests (Day 13)

**Coverage Goals:**
- ✅ 90%+ coverage on all pure business logic
- ✅ 80%+ coverage on services with interfaces
- ✅ 70%+ coverage on controllers

**Test Files to Create:**

```
test/
├── unit/
│   ├── services/
│   │   ├── notification_service_test.dart
│   │   ├── backup_service_test.dart
│   │   └── undo_service_test.dart
│   ├── repositories/
│   │   └── subscription_repository_test.dart
│   ├── controllers/
│   │   ├── home_controller_test.dart
│   │   ├── analytics_controller_test.dart
│   │   └── subscription_detail_controller_test.dart
│   ├── utils/
│   │   ├── notification_content_builder_test.dart
│   │   ├── subscription_date_calculator_test.dart
│   │   ├── analytics_calculator_test.dart
│   │   └── currency_utils_test.dart
│   └── models/
│       └── subscription_test.dart
```

**Example Test: NotificationService (Critical)**

```dart
// test/unit/services/notification_service_test.dart
void main() {
  group('NotificationServiceImpl', () {
    late MockFlutterLocalNotificationsPlugin mockPlugin;
    late NotificationServiceImpl service;

    setUp(() {
      mockPlugin = MockFlutterLocalNotificationsPlugin();
      service = NotificationServiceImpl(plugin: mockPlugin);
      setupDefaultMocks();
    });

    group('scheduleNotifications', () {
      test('schedules 3 notifications for monthly subscription', () async {
        // Arrange
        when(() => mockPlugin.zonedSchedule(
          any(),
          any(),
          any(),
          any(),
          any(),
          uiLocalNotificationDateInterpretation: any(named: 'uiLocalNotificationDateInterpretation'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
        )).thenAnswer((_) async {});

        final subscription = _createMonthlySubscription(
          nextBillingDate: DateTime(2026, 3, 1),
          reminders: ReminderConfig(
            firstReminderDays: 7,
            secondReminderDays: 1,
            remindOnBillingDay: true,
            reminderHour: 9,
            reminderMinute: 0,
          ),
        );

        // Act
        await service.scheduleNotifications(subscription);

        // Assert
        verify(() => mockPlugin.zonedSchedule(
          any(),
          any(),
          any(),
          any(),
          any(),
          uiLocalNotificationDateInterpretation: any(named: 'uiLocalNotificationDateInterpretation'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
        )).called(3); // First reminder, second reminder, day-of
      });

      test('schedules correct date for first reminder', () async {
        // Arrange
        TZDateTime? scheduledDate;
        when(() => mockPlugin.zonedSchedule(
          any(),
          any(),
          any(),
          captureAny(),
          any(),
          uiLocalNotificationDateInterpretation: any(named: 'uiLocalNotificationDateInterpretation'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
        )).thenAnswer((invocation) async {
          scheduledDate = invocation.positionalArguments[3] as TZDateTime;
        });

        final billingDate = DateTime(2026, 3, 1, 10, 0);
        final subscription = _createMonthlySubscription(
          nextBillingDate: billingDate,
          reminders: ReminderConfig(firstReminderDays: 7),
        );

        // Act
        await service.scheduleNotifications(subscription);

        // Assert
        expect(scheduledDate, isNotNull);
        final expectedDate = billingDate.subtract(Duration(days: 7));
        expect(scheduledDate!.day, expectedDate.day);
        expect(scheduledDate!.month, expectedDate.month);
        expect(scheduledDate!.year, expectedDate.year);
      });

      test('includes trial notifications when isTrial is true', () async {
        // Arrange
        when(() => mockPlugin.zonedSchedule(
          any(),
          any(),
          any(),
          any(),
          any(),
          uiLocalNotificationDateInterpretation: any(named: 'uiLocalNotificationDateInterpretation'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
        )).thenAnswer((_) async {});

        final subscription = _createTrialSubscription(
          trialEndDate: DateTime(2026, 2, 15),
        );

        // Act
        await service.scheduleNotifications(subscription);

        // Assert
        // Should schedule trial reminders (3 days before, 1 day before, day of)
        // PLUS regular billing reminders
        verify(() => mockPlugin.zonedSchedule(
          any(),
          any(),
          any(),
          any(),
          any(),
          uiLocalNotificationDateInterpretation: any(named: 'uiLocalNotificationDateInterpretation'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
        )).called(greaterThan(3));
      });
    });

    group('cancelNotifications', () {
      test('cancels all notification types for subscription', () async {
        // Arrange
        when(() => mockPlugin.cancel(any())).thenAnswer((_) async {});

        const subscriptionId = 'test-sub-123';

        // Act
        await service.cancelNotifications(subscriptionId);

        // Assert
        // Should cancel: first reminder, second reminder, day-of, trial end
        verify(() => mockPlugin.cancel(any())).called(4);
      });

      test('uses deterministic notification IDs', () async {
        // Arrange
        final cancelledIds = <int>[];
        when(() => mockPlugin.cancel(captureAny())).thenAnswer((invocation) async {
          cancelledIds.add(invocation.positionalArguments[0] as int);
        });

        const subscriptionId = 'test-sub-123';

        // Act
        await service.cancelNotifications(subscriptionId);

        // Assert
        expect(cancelledIds, hasLength(4));
        expect(cancelledIds.toSet(), hasLength(4)); // All unique

        // Verify deterministic (calling again produces same IDs)
        cancelledIds.clear();
        await service.cancelNotifications(subscriptionId);
        expect(cancelledIds, hasLength(4));
      });
    });

    group('fireTestNotification', () {
      test('shows immediate notification', () async {
        // Arrange
        when(() => mockPlugin.show(
          any(),
          any(),
          any(),
          any(),
        )).thenAnswer((_) async {});

        // Act
        await service.fireTestNotification();

        // Assert
        verify(() => mockPlugin.show(
          any(),
          contains('working'), // Body contains "working"
          any(),
          any(),
        )).called(1);
      });
    });
  });
}
```

### 6.2 Widget Tests (Day 14)

**Coverage Goals:**
- ✅ Test all extracted widgets in isolation
- ✅ Test user interactions (taps, swipes, form input)
- ✅ Test conditional rendering
- ✅ Test error states

**Test Files:**

```
test/
├── widget/
│   ├── features/
│   │   ├── home/
│   │   │   ├── home_screen_test.dart
│   │   │   ├── spending_summary_card_test.dart
│   │   │   └── subscription_tile_test.dart
│   │   ├── add_subscription/
│   │   │   ├── add_subscription_screen_test.dart
│   │   │   └── template_picker_dialog_test.dart
│   │   └── subscription_detail/
│   │       ├── detail_header_card_test.dart
│   │       ├── cancellation_card_test.dart
│   │       └── checklist_test.dart
│   └── core/
│       ├── standard_card_test.dart
│       └── subtle_pressable_test.dart
```

**Example Widget Test:**

```dart
// test/widget/features/home/subscription_tile_test.dart
void main() {
  testWidgets('SubscriptionTile displays subscription info', (tester) async {
    // Arrange
    final subscription = _createTestSubscription(
      name: 'Netflix',
      amount: 15.99,
      currencyCode: 'USD',
      cycle: SubscriptionCycle.monthly,
      nextBillingDate: DateTime.now().add(Duration(days: 3)),
    );

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SubscriptionTile(
            subscription: subscription,
            onTap: () {},
            onMarkPaid: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    // Assert
    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('\$15.99'), findsOneWidget);
    expect(find.text('in 3 days'), findsOneWidget);
  });

  testWidgets('SubscriptionTile shows trial badge when isTrial', (tester) async {
    // Arrange
    final subscription = _createTrialSubscription();

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SubscriptionTile(subscription: subscription, /* ... */),
        ),
      ),
    );

    // Assert
    expect(find.text('Trial'), findsOneWidget);
  });

  testWidgets('SubscriptionTile triggers onTap when tapped', (tester) async {
    // Arrange
    var tapped = false;
    final subscription = _createTestSubscription();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SubscriptionTile(
            subscription: subscription,
            onTap: () => tapped = true,
            onMarkPaid: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    // Act
    await tester.tap(find.byType(SubscriptionTile));
    await tester.pumpAndSettle();

    // Assert
    expect(tapped, isTrue);
  });

  testWidgets('swipe left reveals delete action', (tester) async {
    // Arrange
    final subscription = _createTestSubscription();
    var deleted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SubscriptionTile(
            subscription: subscription,
            onTap: () {},
            onMarkPaid: () {},
            onDelete: () => deleted = true,
          ),
        ),
      ),
    );

    // Act
    await tester.drag(
      find.byType(Dismissible),
      Offset(-500, 0), // Swipe left
    );
    await tester.pumpAndSettle();

    // Assert
    expect(deleted, isTrue);
  });
}
```

### 6.3 Integration Tests (Day 15)

**Coverage Goals:**
- ✅ Test complete user flows
- ✅ Test data persistence
- ✅ Test navigation
- ✅ Test notification scheduling (mocked)

**Test Files:**

```
integration_test/
├── app_test.dart                          # Basic smoke test
├── flows/
│   ├── add_subscription_flow_test.dart
│   ├── edit_subscription_flow_test.dart
│   ├── delete_subscription_flow_test.dart
│   ├── backup_restore_flow_test.dart
│   └── mark_as_paid_flow_test.dart
```

**Example Integration Test:**

```dart
// integration_test/flows/add_subscription_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Add Subscription Flow', () {
    setUp(() async {
      await initializeTestEnvironment();
    });

    tearDown(() async {
      await cleanupHive();
    });

    testWidgets('add custom subscription from scratch', (tester) async {
      // Launch app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Tap "Add New" button
      await tester.tap(find.text('Add New'));
      await tester.pumpAndSettle();

      // Fill out form
      await tester.enterText(find.byKey(Key('name-field')), 'Test Service');
      await tester.enterText(find.byKey(Key('amount-field')), '9.99');

      // Select cycle
      await tester.tap(find.text('Monthly'));
      await tester.pumpAndSettle();

      // Select category
      await tester.tap(find.text('Entertainment'));
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify navigation back to home
      expect(find.byType(HomeScreen), findsOneWidget);

      // Verify subscription appears in list
      expect(find.text('Test Service'), findsOneWidget);
      expect(find.text('\$9.99'), findsOneWidget);
    });

    testWidgets('add subscription from template', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add New'));
      await tester.pumpAndSettle();

      // Tap "Use Template" button
      await tester.tap(find.text('Use Template'));
      await tester.pumpAndSettle();

      // Search for Netflix
      await tester.enterText(find.byKey(Key('template-search')), 'Netflix');
      await tester.pumpAndSettle();

      // Select Netflix template
      await tester.tap(find.text('Netflix'));
      await tester.pumpAndSettle();

      // Verify form pre-filled
      expect(find.text('Netflix'), findsWidgets); // Name field + template display

      // Adjust amount
      await tester.enterText(find.byKey(Key('amount-field')), '17.99');

      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify
      expect(find.text('Netflix'), findsOneWidget);
      expect(find.text('\$17.99'), findsOneWidget);
    });

    testWidgets('trial subscription workflow', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add New'));
      await tester.pumpAndSettle();

      // Fill basic info
      await tester.enterText(find.byKey(Key('name-field')), 'Trial Service');
      await tester.enterText(find.byKey(Key('amount-field')), '0');

      // Enable trial toggle
      await tester.tap(find.byKey(Key('trial-toggle')));
      await tester.pumpAndSettle();

      // Fill trial fields
      await tester.tap(find.byKey(Key('trial-end-date-picker')));
      await tester.pumpAndSettle();
      // ... select date

      await tester.enterText(find.byKey(Key('post-trial-amount')), '29.99');

      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify trial badge appears
      expect(find.text('Trial'), findsOneWidget);
    });
  });
}
```

---

## Phase 7: Documentation & Cleanup (Day 16)
**Priority:** MEDIUM
**Estimated Effort:** 1 day

### Tasks

1. **Update Architecture Documentation**
   - Document new service interfaces
   - Document extracted component structure
   - Update file structure diagrams

2. **Create Testing Guide**
   - `docs/guides/testing.md`
   - How to run tests
   - How to write new tests
   - Mock setup guidelines
   - Coverage requirements

3. **Code Cleanup**
   - Remove any unused imports
   - Remove commented-out code
   - Ensure consistent formatting
   - Run `flutter analyze` and fix all warnings

4. **Update README**
   - Add testing section
   - Add coverage badges (if using codecov)
   - Update contribution guidelines

---

## Implementation Schedule

### Week 1: Foundation & Interfaces
- **Day 1:** Test infrastructure setup
- **Day 2:** NotificationService refactor + tests
- **Day 3:** SubscriptionRepository refactor + tests
- **Day 4:** BackupService refactor + tests

### Week 2: Screen Refactoring
- **Day 5-6:** Split SubscriptionDetailScreen
- **Day 7-8:** Split AddSubscriptionScreen
- **Day 9:** Refactor HomeScreen

### Week 3: Controllers & Testing
- **Day 10-11:** Move business logic to controllers
- **Day 12:** Fix singleton patterns
- **Day 13:** Write unit tests
- **Day 14:** Write widget tests
- **Day 15:** Write integration tests

### Week 4: Polish
- **Day 16:** Documentation & cleanup
- **Day 17-18:** Buffer for unexpected issues
- **Day 19:** Final QA testing
- **Day 20:** Deploy updated version

---

## Success Metrics

After completing this refactoring plan, we should achieve:

### Quantitative Metrics
- ✅ **Code coverage:** 60%+ overall, 80%+ on business logic
- ✅ **File size:** No screen file over 400 lines
- ✅ **Test count:** 100+ unit tests, 30+ widget tests, 10+ integration tests
- ✅ **Cyclomatic complexity:** Max 10 per method
- ✅ **Test execution time:** Full suite under 2 minutes

### Qualitative Metrics
- ✅ **Testability:** All services mockable, all business logic testable in isolation
- ✅ **Maintainability:** Single responsibility per file, clear separation of concerns
- ✅ **Reliability:** Comprehensive test coverage catches regressions
- ✅ **Developer Experience:** Easy to add new features with confidence
- ✅ **Code Quality:** No analyzer warnings, consistent formatting

---

## Risk Mitigation

### High-Risk Changes
1. **Notification scheduling refactor** — Most critical feature
   - **Mitigation:** Extensive manual testing on real devices, keep old implementation in git history

2. **Screen file splitting** — High chance of visual regressions
   - **Mitigation:** Take screenshots before/after, pixel-perfect comparison

3. **Repository interface** — Data persistence changes
   - **Mitigation:** Backup all test data, test migration path

### Rollback Plan
- Each phase is self-contained and can be reverted independently
- Keep feature flags for new implementations during transition
- Maintain git tags at each phase completion

---

## Next Steps

1. **Get stakeholder approval** on this plan
2. **Create GitHub issues** for each phase
3. **Set up CI/CD** to run tests automatically
4. **Schedule the work** with appropriate time buffers
5. **Begin with Phase 1** (low-risk infrastructure setup)

---

## Appendix: Quick Wins

If full refactor is too large, here are **high-impact quick wins**:

### Quick Win 1: Add Test Dependencies (30 minutes)
Just add mocktail and test helpers. Immediate benefit: Can start writing tests.

### Quick Win 2: Extract NotificationContentBuilder (2 hours)
Pure functions for notification text. Immediate benefit: Testable notification logic without plugin.

### Quick Win 3: Split SubscriptionDetailScreen (1 day)
Break into 5 files. Immediate benefit: Much easier to understand and modify.

### Quick Win 4: Add SubscriptionRepository Interface (2 hours)
Just the interface, keep implementation unchanged. Immediate benefit: Can mock repository in tests.

### Quick Win 5: Write NotificationService Unit Tests (3 hours)
Even without full refactor, we can test critical notification logic. Immediate benefit: Confidence in most important feature.

---

**End of Refactoring Plan**
