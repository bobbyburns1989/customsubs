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

    final subscription = Subscription(
      id: state.value?.id ?? const Uuid().v4(),
      name: name,
      amount: amount,
      currencyCode: currencyCode,
      cycle: cycle,
      nextBillingDate: nextBillingDate,
      startDate: startDate,
      category: category,
      colorValue: colorValue,
      reminders: reminders,
      isActive: isActive,
      isTrial: isTrial,
      trialEndDate: trialEndDate,
      postTrialAmount: postTrialAmount,
      cancelUrl: cancelUrl,
      cancelPhone: cancelPhone,
      cancelNotes: cancelNotes,
      cancelChecklist: cancelChecklist,
      checklistCompleted: List.filled(cancelChecklist.length, false),
      notes: notes,
      iconName: iconName,
    );

    await repository.upsert(subscription);
    await notificationService.scheduleNotificationsForSubscription(subscription);
  }
}

