import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:custom_subs/data/models/subscription.dart';
import 'package:custom_subs/data/repositories/subscription_repository.dart';
import 'package:custom_subs/data/services/notification_service.dart';
import 'package:custom_subs/data/services/analytics_service.dart';
import 'package:custom_subs/core/utils/currency_utils.dart';
import 'package:custom_subs/core/providers/settings_provider.dart';

part 'home_controller.g.dart';

@riverpod
class HomeController extends _$HomeController {
  @override
  FutureOr<List<Subscription>> build() async {
    final repository = await ref.watch(subscriptionRepositoryProvider.future);
    return repository.getAll();
  }

  /// Get upcoming subscriptions sorted by billing date
  ///
  /// Returns only ACTIVE subscriptions billing within the next [days] (default: 30).
  /// Paused subscriptions are excluded.
  /// Sorts by paid status (unpaid first), then billing date.
  List<Subscription> getUpcomingSubscriptions({int days = 30}) {
    final subs = state.value ?? [];
    final now = DateTime.now();
    // Use start of today so subscriptions billing "today" (midnight date) are
    // included in the list rather than being silently excluded. The advance
    // logic in the repository now also uses this same calendar-day boundary.
    final todayStart = DateTime(now.year, now.month, now.day);
    final cutoffDate = todayStart.add(Duration(days: days));

    // Filter to only ACTIVE subscriptions within the date range
    final filteredSubs = subs.where((sub) {
      return sub.isActive &&
             !sub.nextBillingDate.isBefore(todayStart) &&
             sub.nextBillingDate.isBefore(cutoffDate);
    }).toList();

    // Sort by: paid status → billing date
    filteredSubs.sort((a, b) {
      // 1. Unpaid before paid
      if (a.isPaid != b.isPaid) {
        return a.isPaid ? 1 : -1;
      }

      // 2. Sort by billing date
      return a.nextBillingDate.compareTo(b.nextBillingDate);
    });

    return filteredSubs;
  }

  /// Calculate total monthly spending in primary currency
  ///
  /// Converts all subscriptions to primary currency before summing.
  /// Excludes paused subscriptions from the total.
  double calculateMonthlyTotal() {
    final subs = state.value ?? [];
    final primaryCurrency = getPrimaryCurrency();

    // Sum ACTIVE (non-paused) subscriptions only
    return subs.where((sub) => sub.isActive).fold(0.0, (sum, sub) {
      // Convert subscription's monthly amount to primary currency
      final convertedAmount = CurrencyUtils.convert(
        sub.effectiveMonthlyAmount,
        sub.currencyCode,
        primaryCurrency,
      );
      return sum + convertedAmount;
    });
  }

  /// Get primary currency for display from settings
  String getPrimaryCurrency() {
    return ref.read(primaryCurrencyProvider);
  }

  /// Get count of active subscriptions
  int getActiveCount() {
    final subs = state.value ?? [];
    return subs.where((sub) => sub.isActive).length;
  }

  /// Get count of paused subscriptions
  int getPausedCount() {
    final subs = state.value ?? [];
    return subs.where((sub) => sub.isPaused).length;
  }

  /// Get all paused subscriptions sorted by pause date
  List<Subscription> getPausedSubscriptions() {
    final subs = state.value ?? [];
    final paused = subs.where((sub) => sub.isPaused).toList();

    // Sort by pause date (most recently paused first)
    paused.sort((a, b) {
      if (a.pausedDate == null && b.pausedDate == null) return 0;
      if (a.pausedDate == null) return 1;
      if (b.pausedDate == null) return -1;
      return b.pausedDate!.compareTo(a.pausedDate!);
    });

    return paused;
  }

  /// Get subscriptions billing 30–90 days from now.
  ///
  /// These are shown in the "Later" section on Home to ensure no active
  /// subscription is ever invisible to the user. Excludes paused subs.
  /// Sorted by billing date (soonest first).
  List<Subscription> getLaterSubscriptions({int fromDays = 31, int toDays = 90}) {
    final subs = state.value ?? [];
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final fromDate = todayStart.add(Duration(days: fromDays));
    final toDate = todayStart.add(Duration(days: toDays));

    return subs
        .where((sub) =>
            sub.isActive &&
            !sub.nextBillingDate.isBefore(fromDate) &&
            sub.nextBillingDate.isBefore(toDate))
        .toList()
      ..sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
  }

  /// Get trials ending soon (within 7 days)
  List<Subscription> getTrialsEndingSoon() {
    final subs = state.value ?? [];
    return subs.where((sub) => sub.isTrialEndingSoon).toList();
  }

  /// Refresh subscriptions
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(subscriptionRepositoryProvider.future);
      return repository.getAll();
    });
  }

  /// Mark subscription as paid
  ///
  /// Uses an optimistic in-place state update instead of calling refresh() to
  /// avoid flashing the loading skeleton. The sort order (unpaid first) is
  /// re-applied automatically when getUpcomingSubscriptions() reads state.value.
  Future<void> markAsPaid(String subscriptionId, bool isPaid) async {
    ref.read(analyticsServiceProvider).capture('subscription_marked_paid', {
      'is_paid': isPaid,
    });

    final repository = await ref.read(subscriptionRepositoryProvider.future);
    await repository.markAsPaid(subscriptionId, isPaid);

    // Patch only the affected item in the current list.
    // Avoids setting AsyncValue.loading() (which flashes the skeleton screen).
    final currentSubs = state.value ?? [];
    final updatedSubs = currentSubs.map((sub) {
      if (sub.id == subscriptionId) {
        return sub.copyWith(
          isPaid: isPaid,
          lastMarkedPaidDate: isPaid ? DateTime.now() : null,
        );
      }
      return sub;
    }).toList();
    state = AsyncValue.data(updatedSubs);

    // Cancel notifications when paid (no more nagging); reschedule when un-marking.
    final notificationService = await ref.read(notificationServiceProvider.future);
    if (isPaid) {
      await notificationService.cancelNotificationsForSubscription(subscriptionId);
    } else {
      final sub = updatedSubs.firstWhere((s) => s.id == subscriptionId);
      await notificationService.scheduleNotificationsForSubscription(sub);
    }
  }

  /// Delete subscription
  Future<void> deleteSubscription(String subscriptionId) async {
    ref.read(analyticsServiceProvider).capture('subscription_deleted');

    final repository = await ref.read(subscriptionRepositoryProvider.future);
    await repository.delete(subscriptionId);
    await refresh();
  }

  /// Pause a subscription
  Future<void> pauseSubscription(
    String subscriptionId, {
    DateTime? resumeDate,
  }) async {
    ref.read(analyticsServiceProvider).capture('subscription_paused', {
      'has_resume_date': resumeDate != null,
    });

    final repository = await ref.read(subscriptionRepositoryProvider.future);
    final notificationService = await ref.read(notificationServiceProvider.future);

    await repository.pauseSubscription(subscriptionId, resumeDate: resumeDate);

    // Notifications are automatically skipped by scheduleNotificationsForSubscription
    // but we explicitly cancel to be safe
    await notificationService.cancelNotificationsForSubscription(subscriptionId);

    await refresh();
  }

  /// Resume a paused subscription
  Future<void> resumeSubscription(String subscriptionId) async {
    ref.read(analyticsServiceProvider).capture('subscription_resumed');

    final repository = await ref.read(subscriptionRepositoryProvider.future);
    final notificationService = await ref.read(notificationServiceProvider.future);

    await repository.resumeSubscription(subscriptionId);

    // Re-schedule notifications for resumed subscription
    final subscription = repository.getById(subscriptionId);
    if (subscription != null) {
      await notificationService.scheduleNotificationsForSubscription(subscription);
    }

    await refresh();
  }


  /// Check if backup reminder should be shown
  ///
  /// Returns true if:
  /// - User has exactly 3 active subscriptions
  /// - Backup reminder hasn't been shown before
  bool shouldShowBackupReminder() {
    final count = getActiveCount();
    final settingsRepo = ref.read(settingsRepositoryProvider.notifier);
    final hasShown = settingsRepo.hasShownBackupReminder();

    return count == 3 && !hasShown;
  }
}
