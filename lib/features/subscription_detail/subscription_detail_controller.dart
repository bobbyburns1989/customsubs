import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:custom_subs/data/models/subscription.dart';
import 'package:custom_subs/data/repositories/subscription_repository.dart';
import 'package:custom_subs/data/services/notification_service.dart';

part 'subscription_detail_controller.g.dart';

/// Controller for subscription detail screen.
///
/// Provides actions for:
/// - Toggling paid status
/// - Toggling active/paused status
/// - Updating checklist items
/// - Deleting subscription
@riverpod
class SubscriptionDetailController extends _$SubscriptionDetailController {
  @override
  FutureOr<Subscription?> build(String subscriptionId) async {
    final repository = await ref.read(subscriptionRepositoryProvider.future);
    return repository.getById(subscriptionId);
  }

  /// Toggle paid status for current billing cycle
  Future<void> togglePaid() async {
    final subscription = state.value;
    if (subscription == null) return;

    final repository = await ref.read(subscriptionRepositoryProvider.future);
    final notificationService = await ref.read(notificationServiceProvider.future);

    final updated = subscription.copyWith(
      isPaid: !subscription.isPaid,
      lastMarkedPaidDate: !subscription.isPaid ? DateTime.now() : null,
    );

    await repository.upsert(updated);
    await notificationService.scheduleNotificationsForSubscription(updated);

    // Refresh state
    state = AsyncValue.data(updated);
  }

  /// Toggle active/paused status
  Future<void> toggleActive() async {
    final subscription = state.value;
    if (subscription == null) return;

    final repository = await ref.read(subscriptionRepositoryProvider.future);
    final notificationService = await ref.read(notificationServiceProvider.future);

    final updated = subscription.copyWith(
      isActive: !subscription.isActive,
    );

    await repository.upsert(updated);

    // Cancel notifications if pausing, reschedule if resuming
    if (updated.isActive) {
      await notificationService.scheduleNotificationsForSubscription(updated);
    } else {
      await notificationService.cancelNotificationsForSubscription(updated.id);
    }

    // Refresh state
    state = AsyncValue.data(updated);
  }

  /// Toggle a checklist item completion
  Future<void> toggleChecklistItem(int index) async {
    final subscription = state.value;
    if (subscription == null) return;
    if (index < 0 || index >= subscription.checklistCompleted.length) return;

    final repository = await ref.read(subscriptionRepositoryProvider.future);

    final updatedChecklist = List<bool>.from(subscription.checklistCompleted);
    updatedChecklist[index] = !updatedChecklist[index];

    final updated = subscription.copyWith(
      checklistCompleted: updatedChecklist,
    );

    await repository.upsert(updated);

    // Refresh state
    state = AsyncValue.data(updated);
  }

  /// Delete subscription
  Future<void> deleteSubscription() async {
    final subscription = state.value;
    if (subscription == null) return;

    final repository = await ref.read(subscriptionRepositoryProvider.future);
    final notificationService = await ref.read(notificationServiceProvider.future);

    // Cancel all notifications
    await notificationService.cancelNotificationsForSubscription(subscription.id);

    // Delete from database
    await repository.delete(subscription.id);

    // Set state to null (subscription deleted)
    state = const AsyncValue.data(null);
  }
}
