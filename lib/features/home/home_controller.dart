import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:custom_subs/data/models/subscription.dart';
import 'package:custom_subs/data/repositories/subscription_repository.dart';

part 'home_controller.g.dart';

@riverpod
class HomeController extends _$HomeController {
  @override
  FutureOr<List<Subscription>> build() async {
    final repository = await ref.watch(subscriptionRepositoryProvider.future);
    return repository.getAllActive();
  }

  /// Get upcoming subscriptions sorted by billing date
  List<Subscription> getUpcomingSubscriptions() {
    final subs = state.value ?? [];
    final sortedSubs = List<Subscription>.from(subs);

    // Sort by paid status first (unpaid first), then by billing date
    sortedSubs.sort((a, b) {
      if (a.isPaid != b.isPaid) {
        return a.isPaid ? 1 : -1;
      }
      return a.nextBillingDate.compareTo(b.nextBillingDate);
    });

    return sortedSubs;
  }

  /// Calculate total monthly spending
  double calculateMonthlyTotal() {
    final subs = state.value ?? [];
    return subs.fold(0.0, (sum, sub) => sum + sub.effectiveMonthlyAmount);
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

  /// Toggle subscription active status
  Future<void> toggleActive(String subscriptionId) async {
    final repository = await ref.read(subscriptionRepositoryProvider.future);
    await repository.toggleActive(subscriptionId);
    await refresh();
  }
}
