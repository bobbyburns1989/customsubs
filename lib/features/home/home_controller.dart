import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:custom_subs/data/models/subscription.dart';
import 'package:custom_subs/data/repositories/subscription_repository.dart';
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
  /// Returns only subscriptions billing within the next [days] (default: 30).
  /// Sorts by active status first (active first), then paid status (unpaid first), then billing date.
  List<Subscription> getUpcomingSubscriptions({int days = 30}) {
    final subs = state.value ?? [];
    final now = DateTime.now();
    final cutoffDate = now.add(Duration(days: days));

    // Filter to only subscriptions within the date range
    final filteredSubs = subs.where((sub) {
      return sub.nextBillingDate.isAfter(now) &&
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
  double calculateMonthlyTotal() {
    final subs = state.value ?? [];
    final primaryCurrency = getPrimaryCurrency();

    // Sum ALL subscriptions
    return subs.fold(0.0, (sum, sub) {
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
    return state.value?.length ?? 0;
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
      return repository.getAllActive();
    });
  }

  /// Mark subscription as paid
  Future<void> markAsPaid(String subscriptionId, bool isPaid) async {
    final repository = await ref.read(subscriptionRepositoryProvider.future);
    await repository.markAsPaid(subscriptionId, isPaid);
    await refresh();
  }

  /// Delete subscription
  Future<void> deleteSubscription(String subscriptionId) async {
    final repository = await ref.read(subscriptionRepositoryProvider.future);
    await repository.delete(subscriptionId);
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
