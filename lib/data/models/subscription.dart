import 'package:hive/hive.dart';
import 'package:custom_subs/data/models/subscription_cycle.dart';
import 'package:custom_subs/data/models/subscription_category.dart';
import 'package:custom_subs/data/models/reminder_config.dart';

part 'subscription.g.dart';

@HiveType(typeId: 0)
class Subscription extends HiveObject {
  @HiveField(0)
  final String id; // UUID

  @HiveField(1)
  final String name; // "Netflix"

  @HiveField(2)
  final double amount; // 15.99

  @HiveField(3)
  final String currencyCode; // "USD", "EUR", "GBP", etc.

  @HiveField(4)
  final SubscriptionCycle cycle; // monthly, yearly, etc.

  @HiveField(5)
  final DateTime nextBillingDate;

  @HiveField(6)
  final DateTime startDate; // When user first subscribed

  @HiveField(7)
  final SubscriptionCategory category;

  @HiveField(8)
  final bool isActive;

  @HiveField(9)
  final bool isTrial; // FREE TRIAL MODE

  @HiveField(10)
  final DateTime? trialEndDate; // When trial converts to paid

  @HiveField(11)
  final double? postTrialAmount; // Amount after trial ends

  @HiveField(12)
  final String? cancelUrl; // Direct link to cancellation page

  @HiveField(13)
  final String? cancelPhone; // Support phone number

  @HiveField(14)
  final String? cancelNotes; // Free-text cancellation instructions

  @HiveField(15)
  final List<String> cancelChecklist; // ["Log into account", "Go to billing", "Click cancel"]

  @HiveField(16)
  final List<bool> checklistCompleted; // Parallel array tracking completion

  @HiveField(17)
  final String? notes; // General user notes

  @HiveField(18)
  final String? iconName; // Template icon identifier or null for custom

  @HiveField(19)
  final int colorValue; // Stored as int, converted to Color

  @HiveField(20)
  final ReminderConfig reminders;

  @HiveField(21)
  final bool isPaid; // "Mark as paid" for current cycle

  @HiveField(22)
  final DateTime? lastMarkedPaidDate; // When user last marked paid

  Subscription({
    required this.id,
    required this.name,
    required this.amount,
    required this.currencyCode,
    required this.cycle,
    required this.nextBillingDate,
    required this.startDate,
    required this.category,
    this.isActive = true,
    this.isTrial = false,
    this.trialEndDate,
    this.postTrialAmount,
    this.cancelUrl,
    this.cancelPhone,
    this.cancelNotes,
    this.cancelChecklist = const [],
    this.checklistCompleted = const [],
    this.notes,
    this.iconName,
    required this.colorValue,
    required this.reminders,
    this.isPaid = false,
    this.lastMarkedPaidDate,
  });

  Subscription copyWith({
    String? id,
    String? name,
    double? amount,
    String? currencyCode,
    SubscriptionCycle? cycle,
    DateTime? nextBillingDate,
    DateTime? startDate,
    SubscriptionCategory? category,
    bool? isActive,
    bool? isTrial,
    DateTime? trialEndDate,
    double? postTrialAmount,
    String? cancelUrl,
    String? cancelPhone,
    String? cancelNotes,
    List<String>? cancelChecklist,
    List<bool>? checklistCompleted,
    String? notes,
    String? iconName,
    int? colorValue,
    ReminderConfig? reminders,
    bool? isPaid,
    DateTime? lastMarkedPaidDate,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      cycle: cycle ?? this.cycle,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      startDate: startDate ?? this.startDate,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      isTrial: isTrial ?? this.isTrial,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      postTrialAmount: postTrialAmount ?? this.postTrialAmount,
      cancelUrl: cancelUrl ?? this.cancelUrl,
      cancelPhone: cancelPhone ?? this.cancelPhone,
      cancelNotes: cancelNotes ?? this.cancelNotes,
      cancelChecklist: cancelChecklist ?? this.cancelChecklist,
      checklistCompleted: checklistCompleted ?? this.checklistCompleted,
      notes: notes ?? this.notes,
      iconName: iconName ?? this.iconName,
      colorValue: colorValue ?? this.colorValue,
      reminders: reminders ?? this.reminders,
      isPaid: isPaid ?? this.isPaid,
      lastMarkedPaidDate: lastMarkedPaidDate ?? this.lastMarkedPaidDate,
    );
  }

  /// Calculates monthly equivalent amount for this subscription
  double get monthlyAmount {
    return cycle.toMonthlyAmount(amount);
  }

  /// Returns the effective amount (considers trial status)
  double get effectiveAmount {
    if (isTrial && trialEndDate != null && DateTime.now().isBefore(trialEndDate!)) {
      return 0.0;
    }
    if (isTrial && postTrialAmount != null) {
      return postTrialAmount!;
    }
    return amount;
  }

  /// Returns the effective monthly amount
  double get effectiveMonthlyAmount {
    return cycle.toMonthlyAmount(effectiveAmount);
  }

  /// Checks if trial is ending soon (within 7 days)
  bool get isTrialEndingSoon {
    if (!isTrial || trialEndDate == null) return false;
    final now = DateTime.now();
    final daysUntilEnd = trialEndDate!.difference(now).inDays;
    return daysUntilEnd >= 0 && daysUntilEnd <= 7;
  }

  /// Days until next billing
  int get daysUntilBilling {
    final now = DateTime.now();
    return nextBillingDate.difference(now).inDays;
  }

  /// Check if billing is overdue
  bool get isOverdue {
    return daysUntilBilling < 0;
  }

  /// Get next billing date after the current one
  DateTime calculateNextBillingDate() {
    switch (cycle) {
      case SubscriptionCycle.weekly:
        return nextBillingDate.add(const Duration(days: 7));
      case SubscriptionCycle.biweekly:
        return nextBillingDate.add(const Duration(days: 14));
      case SubscriptionCycle.monthly:
        return DateTime(
          nextBillingDate.year,
          nextBillingDate.month + 1,
          nextBillingDate.day,
        );
      case SubscriptionCycle.quarterly:
        return DateTime(
          nextBillingDate.year,
          nextBillingDate.month + 3,
          nextBillingDate.day,
        );
      case SubscriptionCycle.biannual:
        return DateTime(
          nextBillingDate.year,
          nextBillingDate.month + 6,
          nextBillingDate.day,
        );
      case SubscriptionCycle.yearly:
        return DateTime(
          nextBillingDate.year + 1,
          nextBillingDate.month,
          nextBillingDate.day,
        );
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Subscription && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
