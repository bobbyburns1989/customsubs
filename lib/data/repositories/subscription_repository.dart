import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_subs/data/models/subscription.dart';
import 'package:custom_subs/data/models/subscription_category.dart';
import 'package:custom_subs/data/models/reminder_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subscription_repository.g.dart';

/// Repository for managing subscription data persistence using Hive.
///
/// **Single source of truth** for all subscription data in the app.
/// Widgets should never access Hive boxes directly - always use this repository.
///
/// ## Responsibilities
/// - CRUD operations for subscriptions
/// - Date advancement for overdue billing dates
/// - Filtering and querying subscriptions
/// - Reactive data streams for UI updates
/// - Calculated aggregates (monthly totals, spending by category)
///
/// ## Usage Pattern
/// ```dart
/// // Access via Riverpod provider
/// final repository = await ref.read(subscriptionRepositoryProvider.future);
///
/// // Create or update
/// await repository.upsert(subscription);
///
/// // Read
/// final allActive = repository.getAllActive();
/// final byId = repository.getById(subscriptionId);
///
/// // Delete
/// await repository.delete(subscriptionId);
///
/// // Watch for changes (reactive)
/// ref.listen(activeSubscriptionsProvider, (previous, next) {
///   // React to data changes
/// });
/// ```
///
/// ## Initialization
/// Must call `init()` before using - typically done via the Riverpod provider.
///
/// See also: `docs/architecture/data-layer.md` for detailed patterns
class SubscriptionRepository {
  static const String _boxName = 'subscriptions';
  Box<Subscription>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<Subscription>(_boxName);
  }

  Box<Subscription> get _getBox {
    if (_box == null || !_box!.isOpen) {
      throw Exception('SubscriptionRepository not initialized. Call init() first.');
    }
    return _box!;
  }

  /// Get all subscriptions
  List<Subscription> getAll() {
    return _getBox.values.toList();
  }

  /// Get all active (non-paused) subscriptions
  ///
  /// NOTE: Changed in v1.2.0 to filter by pause state.
  /// Previously returned all subscriptions (pause feature was removed in v1.0.3).
  List<Subscription> getAllActive() {
    return _getBox.values.where((sub) => sub.isActive).toList();
  }

  /// Get all paused subscriptions
  List<Subscription> getAllPaused() {
    return _getBox.values.where((sub) => !sub.isActive).toList();
  }

  /// Get subscriptions that should auto-resume (resume date has passed)
  List<Subscription> getSubscriptionsToAutoResume() {
    final now = DateTime.now();
    return _getBox.values.where((sub) {
      return !sub.isActive &&
             sub.resumeDate != null &&
             sub.resumeDate!.isBefore(now);
    }).toList();
  }

  /// Get subscription by ID
  ///
  /// Returns null if no subscription with the given ID exists.
  /// This is safer than throwing for missing IDs (e.g., when accessing stale references).
  Subscription? getById(String id) {
    try {
      return _getBox.values.firstWhere((sub) => sub.id == id);
    } catch (e) {
      return null;  // Not found - return null as signature promises
    }
  }

  /// Creates a new subscription or updates an existing one.
  ///
  /// **Main method for saving subscriptions.** Automatically determines whether
  /// to create or update based on the subscription's ID.
  ///
  /// ## Behavior
  /// - If a subscription with matching ID exists → updates it
  /// - If no matching ID found → creates new entry
  ///
  /// ## Usage
  /// ```dart
  /// final subscription = Subscription(
  ///   id: uuid.v4(),  // New UUID for create
  ///   name: 'Netflix',
  ///   amount: 15.99,
  ///   // ...
  /// );
  ///
  /// await repository.upsert(subscription);
  /// ```
  ///
  /// **Important:** After upserting, you should reschedule notifications:
  /// ```dart
  /// await repository.upsert(subscription);
  /// await notificationService.scheduleNotificationsForSubscription(subscription);
  /// ```
  ///
  /// ## Thread Safety
  /// Hive operations are async and safe to call from any isolate.
  Future<void> upsert(Subscription subscription) async {
    // Find existing subscription with the same ID
    final existingKey = _getBox.keys.firstWhere(
      (key) {
        final sub = _getBox.get(key);
        return sub?.id == subscription.id;
      },
      orElse: () => null,
    );

    if (existingKey != null) {
      // Update existing
      await _getBox.put(existingKey, subscription);
    } else {
      // Create new
      await _getBox.add(subscription);
    }
  }

  /// Delete a subscription
  Future<void> delete(String id) async {
    final key = _getBox.keys.firstWhere(
      (key) {
        final sub = _getBox.get(key);
        return sub?.id == id;
      },
      orElse: () => null,
    );

    if (key != null) {
      await _getBox.delete(key);
    }
  }

  /// Delete all subscriptions
  Future<void> deleteAll() async {
    await _getBox.clear();
  }

  /// Update checklist completion status
  Future<void> updateChecklistItem(String subscriptionId, int index, bool completed) async {
    final subscription = getById(subscriptionId);
    if (subscription == null) return;

    final updatedChecklist = List<bool>.from(subscription.checklistCompleted);
    if (index >= 0 && index < updatedChecklist.length) {
      updatedChecklist[index] = completed;

      final updated = subscription.copyWith(
        checklistCompleted: updatedChecklist,
      );

      await upsert(updated);
    }
  }

  /// Mark subscription as paid
  Future<void> markAsPaid(String subscriptionId, bool isPaid) async {
    final subscription = getById(subscriptionId);
    if (subscription == null) return;

    final updated = subscription.copyWith(
      isPaid: isPaid,
      lastMarkedPaidDate: isPaid ? DateTime.now() : null,
    );

    await upsert(updated);
  }

  /// Pause a subscription with optional auto-resume date
  ///
  /// - Increments pauseCount for history tracking
  /// - Sets pausedDate to now
  /// - Sets resumeDate if provided
  /// - Caller is responsible for canceling notifications
  Future<void> pauseSubscription(
    String subscriptionId, {
    DateTime? resumeDate,
  }) async {
    final subscription = getById(subscriptionId);
    if (subscription == null) return;

    final updated = subscription.copyWith(
      isActive: false,
      pausedDate: DateTime.now(),
      resumeDate: resumeDate,
      pauseCount: subscription.pauseCount + 1,
    );

    await upsert(updated);
  }

  /// Resume a paused subscription
  ///
  /// - Clears pause state (pausedDate, resumeDate set to null)
  /// - Caller is responsible for rescheduling notifications
  Future<void> resumeSubscription(String subscriptionId) async {
    final subscription = getById(subscriptionId);
    if (subscription == null) return;

    // Create a new subscription with pause state cleared
    // We reconstruct the object to ensure nullable fields are set to null
    final resumed = Subscription(
      id: subscription.id,
      name: subscription.name,
      amount: subscription.amount,
      currencyCode: subscription.currencyCode,
      cycle: subscription.cycle,
      nextBillingDate: subscription.nextBillingDate,
      startDate: subscription.startDate,
      category: subscription.category,
      isActive: true,
      isTrial: subscription.isTrial,
      trialEndDate: subscription.trialEndDate,
      postTrialAmount: subscription.postTrialAmount,
      cancelUrl: subscription.cancelUrl,
      cancelPhone: subscription.cancelPhone,
      cancelNotes: subscription.cancelNotes,
      cancelChecklist: subscription.cancelChecklist,
      checklistCompleted: subscription.checklistCompleted,
      notes: subscription.notes,
      iconName: subscription.iconName,
      colorValue: subscription.colorValue,
      reminders: subscription.reminders,
      isPaid: subscription.isPaid,
      lastMarkedPaidDate: subscription.lastMarkedPaidDate,
      pausedDate: null,      // Clear pause date
      resumeDate: null,      // Clear resume date
      pauseCount: subscription.pauseCount, // Preserve count
    );

    await upsert(resumed);
  }

  /// Auto-resume subscriptions whose resumeDate has passed
  ///
  /// Returns list of resumed subscriptions for notification rescheduling.
  /// Caller should call this on app launch, app resume, and pull-to-refresh.
  Future<List<Subscription>> autoResumeSubscriptions() async {
    final toResume = getSubscriptionsToAutoResume();
    final resumed = <Subscription>[];

    for (final subscription in toResume) {
      await resumeSubscription(subscription.id);
      final updated = getById(subscription.id);
      if (updated != null) {
        resumed.add(updated);
      }
    }

    return resumed;
  }


  /// Advances billing dates for subscriptions that are past due.
  ///
  /// **Should be called on app launch** to ensure billing dates stay current.
  ///
  /// ## What it does
  /// 1. Finds all active subscriptions with `nextBillingDate` in the past
  /// 2. Calculates how many billing cycles have passed
  /// 3. Advances the billing date to the next future date
  /// 4. Resets `isPaid` to `false` for the new billing cycle
  /// 5. Saves the updated subscription
  ///
  /// ## Returns
  /// List of subscriptions that were updated.
  ///
  /// ## Usage
  /// ```dart
  /// // In main.dart or splash screen
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   await Hive.initFlutter();
  ///   // ...
  ///
  ///   final repository = SubscriptionRepository();
  ///   await repository.init();
  ///
  ///   // Advance overdue billing dates
  ///   final updated = await repository.advanceOverdueBillingDates();
  ///
  ///   // Reschedule notifications for updated subscriptions
  ///   final notificationService = NotificationService();
  ///   for (final sub in updated) {
  ///     await notificationService.scheduleNotificationsForSubscription(sub);
  ///   }
  ///
  ///   runApp(MyApp());
  /// }
  /// ```
  ///
  /// ## Example
  /// If a monthly subscription's last billing date was Feb 1 and today is March 5:
  /// - Calculates: 1 month has passed
  /// - New billing date: March 1 → April 1 (next future date)
  /// - Resets isPaid to false
  ///
  /// **Important:** This ensures users don't miss billing reminders even if
  /// they haven't opened the app in a while.
  Future<List<Subscription>> advanceOverdueBillingDates() async {
    final now = DateTime.now();
    final updated = <Subscription>[];

    for (final subscription in getAll()) {
      // SKIP paused subscriptions - billing dates freeze while paused
      if (!subscription.isActive) continue;

      if (subscription.nextBillingDate.isBefore(now)) {
        // Calculate how many cycles have passed
        var newBillingDate = subscription.nextBillingDate;

        while (newBillingDate.isBefore(now)) {
          newBillingDate = _calculateNextDate(newBillingDate, subscription.cycle);
        }

        final updatedSub = subscription.copyWith(
          nextBillingDate: newBillingDate,
          isPaid: false, // Reset paid status for new cycle
        );

        await upsert(updatedSub);
        updated.add(updatedSub);
      }
    }

    return updated;
  }

  DateTime _calculateNextDate(DateTime current, cycle) {
    return Subscription(
      id: '',
      name: '',
      amount: 0,
      currencyCode: '',
      cycle: cycle,
      nextBillingDate: current,
      startDate: current,
      category: SubscriptionCategory.other,
      colorValue: 0,
      reminders: ReminderConfig(),
    ).calculateNextBillingDate();
  }

  /// Get upcoming subscriptions within the next N days
  List<Subscription> getUpcoming(int days) {
    final now = DateTime.now();
    final cutoff = now.add(Duration(days: days));

    return getAllActive()
        .where((sub) =>
            sub.nextBillingDate.isAfter(now) &&
            sub.nextBillingDate.isBefore(cutoff))
        .toList()
      ..sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
  }

  /// Get subscriptions with trials ending soon
  List<Subscription> getTrialsEndingSoon(int days) {
    final now = DateTime.now();
    final cutoff = now.add(Duration(days: days));

    return getAllActive()
        .where((sub) =>
            sub.isTrial &&
            sub.trialEndDate != null &&
            sub.trialEndDate!.isAfter(now) &&
            sub.trialEndDate!.isBefore(cutoff))
        .toList()
      ..sort((a, b) => a.trialEndDate!.compareTo(b.trialEndDate!));
  }

  /// Calculate total monthly spending
  double calculateMonthlyTotal({String? currencyCode}) {
    return getAllActive()
        .where((sub) => currencyCode == null || sub.currencyCode == currencyCode)
        .fold(0.0, (sum, sub) => sum + sub.effectiveMonthlyAmount);
  }

  /// Get spending by category
  Map<SubscriptionCategory, double> getSpendingByCategory() {
    final spending = <SubscriptionCategory, double>{};

    for (final sub in getAllActive()) {
      spending[sub.category] = (spending[sub.category] ?? 0.0) + sub.effectiveMonthlyAmount;
    }

    return spending;
  }

  /// Watches all subscriptions and emits updates when data changes.
  ///
  /// **Use for reactive UI** that needs to update automatically when subscriptions
  /// are added, edited, or deleted.
  ///
  /// ## Returns
  /// Stream that emits a new list of all subscriptions whenever the Hive box changes.
  ///
  /// ## Usage
  /// ```dart
  /// // In a Riverpod StreamProvider
  /// @riverpod
  /// Stream<List<Subscription>> allSubscriptions(Ref ref) async* {
  ///   final repository = await ref.watch(subscriptionRepositoryProvider.future);
  ///   yield* repository.watchAll();
  /// }
  ///
  /// // In a widget
  /// final subsStream = ref.watch(allSubscriptionsProvider);
  /// subsStream.when(
  ///   data: (subs) => ListView(children: subs.map(...).toList()),
  ///   loading: () => CircularProgressIndicator(),
  ///   error: (err, stack) => Text('Error: $err'),
  /// );
  /// ```
  ///
  /// **Performance Note:** The stream emits on ANY change to the box, even if
  /// the change doesn't affect the filtered result. For large datasets, consider
  /// using a controller with manual refresh instead.
  Stream<List<Subscription>> watchAll() {
    return _getBox.watch().map((_) => getAll());
  }

  /// Watches active subscriptions and emits updates when data changes.
  ///
  /// **Use for reactive UI** that displays only active subscriptions (the most common case).
  ///
  /// ## Returns
  /// Stream that emits a new list of active subscriptions whenever the Hive box changes.
  ///
  /// ## Usage
  /// ```dart
  /// // Provided via activeSubscriptionsProvider in this file
  /// final activeState = ref.watch(activeSubscriptionsProvider);
  ///
  /// activeState.when(
  ///   data: (activeSubs) => SubscriptionList(subscriptions: activeSubs),
  ///   loading: () => CircularProgressIndicator(),
  ///   error: (err, stack) => ErrorWidget(err),
  /// );
  /// ```
  ///
  /// **When to use watchActive() vs manual refresh:**
  /// - Use `watchActive()`: When you need live updates (e.g., home screen list)
  /// - Use manual refresh: When updates are triggered by user actions only
  Stream<List<Subscription>> watchActive() {
    return _getBox.watch().map((_) => getAll());
  }
}

@riverpod
Future<SubscriptionRepository> subscriptionRepository(Ref ref) async {
  final repository = SubscriptionRepository();
  await repository.init();
  return repository;
}

// Provider for watching all active subscriptions
@riverpod
Stream<List<Subscription>> activeSubscriptions(Ref ref) async* {
  final repository = await ref.watch(subscriptionRepositoryProvider.future);
  yield* repository.watchActive();
}
