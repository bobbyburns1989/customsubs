import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:custom_subs/data/models/subscription.dart';
import 'package:custom_subs/data/models/subscription_cycle.dart';
import 'package:custom_subs/data/models/subscription_category.dart';
import 'package:custom_subs/data/models/reminder_config.dart';
import 'package:custom_subs/data/repositories/subscription_repository.dart';
import 'package:custom_subs/data/services/notification_service.dart';

part 'add_subscription_controller.g.dart';

@riverpod
class AddSubscriptionController extends _$AddSubscriptionController {
  @override
  FutureOr<Subscription?> build(String? subscriptionId) async {
    if (subscriptionId == null) return null;

    final repository = await ref.read(subscriptionRepositoryProvider.future);
    return repository.getById(subscriptionId);
  }

  Future<void> saveSubscription({
    required String name,
    required double amount,
    required String currencyCode,
    required SubscriptionCycle cycle,
    required DateTime nextBillingDate,
    required DateTime startDate,
    required SubscriptionCategory category,
    required int colorValue,
    required ReminderConfig reminders,
    bool isActive = true,
    bool isTrial = false,
    DateTime? trialEndDate,
    double? postTrialAmount,
    String? cancelUrl,
    String? cancelPhone,
    String? cancelNotes,
    List<String> cancelChecklist = const [],
    String? notes,
    String? iconName,
  }) async {
    final repository = await ref.read(subscriptionRepositoryProvider.future);
    final notificationService = await ref.read(notificationServiceProvider.future);

    // When editing, preserve state that shouldn't be reset
    final existingSubscription = state.value;
    final isEditing = existingSubscription != null;

    // Preserve checklist completion state when editing
    // If checklist length changed, create new array preserving what we can
    List<bool> checklistCompleted;
    if (isEditing && existingSubscription.checklistCompleted.isNotEmpty) {
      if (cancelChecklist.length == existingSubscription.cancelChecklist.length) {
        // Same length - keep existing completion state
        checklistCompleted = existingSubscription.checklistCompleted;
      } else {
        // Length changed - preserve what we can, fill rest with false
        checklistCompleted = List.generate(
          cancelChecklist.length,
          (index) => index < existingSubscription.checklistCompleted.length
              ? existingSubscription.checklistCompleted[index]
              : false,
        );
      }
    } else {
      // New subscription - all unchecked
      checklistCompleted = List.filled(cancelChecklist.length, false);
    }

    final subscription = Subscription(
      id: existingSubscription?.id ?? const Uuid().v4(),
      name: name,
      amount: amount,
      currencyCode: currencyCode,
      cycle: cycle,
      nextBillingDate: nextBillingDate,
      startDate: startDate,
      category: category,
      colorValue: colorValue,
      reminders: reminders,
      // Preserve isActive when editing (don't reset paused subscriptions)
      isActive: isEditing ? existingSubscription.isActive : isActive,
      isTrial: isTrial,
      trialEndDate: trialEndDate,
      postTrialAmount: postTrialAmount,
      cancelUrl: cancelUrl,
      cancelPhone: cancelPhone,
      cancelNotes: cancelNotes,
      cancelChecklist: cancelChecklist,
      checklistCompleted: checklistCompleted,
      notes: notes,
      iconName: iconName,
      // Preserve paid status when editing (don't reset marked-as-paid subscriptions)
      isPaid: isEditing ? existingSubscription.isPaid : false,
      lastMarkedPaidDate: isEditing ? existingSubscription.lastMarkedPaidDate : null,
    );

    await repository.upsert(subscription);
    await notificationService.scheduleNotificationsForSubscription(subscription);
  }
}

