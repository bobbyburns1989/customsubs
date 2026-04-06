import 'package:custom_subs/data/models/subscription.dart';
import 'package:custom_subs/data/models/subscription_cycle.dart';
import 'package:custom_subs/data/models/subscription_category.dart';
import 'package:custom_subs/data/models/reminder_config.dart';

/// Factory for creating test Subscription objects with sensible defaults.
///
/// Eliminates boilerplate in tests — only override the fields you care about.
/// Uses auto-incrementing IDs so multiple calls produce unique subs.
class TestSub {
  static int _counter = 0;

  /// Reset the counter between test groups if needed.
  static void resetCounter() => _counter = 0;

  /// Create a subscription with sensible defaults. Override only what you need.
  static Subscription create({
    String? id,
    String name = 'Test Sub',
    double amount = 9.99,
    String currencyCode = 'USD',
    SubscriptionCycle cycle = SubscriptionCycle.monthly,
    DateTime? nextBillingDate,
    DateTime? startDate,
    SubscriptionCategory category = SubscriptionCategory.entertainment,
    bool isActive = true,
    bool isTrial = false,
    DateTime? trialEndDate,
    double? postTrialAmount,
    String? iconName,
    int colorValue = 0xFF000000,
    ReminderConfig? reminders,
    bool isPaid = false,
    DateTime? lastMarkedPaidDate,
    DateTime? pausedDate,
    DateTime? resumeDate,
    int pauseCount = 0,
    String? notes,
  }) {
    _counter++;
    return Subscription(
      id: id ?? 'test-id-$_counter',
      name: name,
      amount: amount,
      currencyCode: currencyCode,
      cycle: cycle,
      nextBillingDate: nextBillingDate ?? DateTime.now().add(const Duration(days: 7)),
      startDate: startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      category: category,
      isActive: isActive,
      isTrial: isTrial,
      trialEndDate: trialEndDate,
      postTrialAmount: postTrialAmount,
      iconName: iconName,
      colorValue: colorValue,
      reminders: reminders ?? ReminderConfig(),
      isPaid: isPaid,
      lastMarkedPaidDate: lastMarkedPaidDate,
      pausedDate: pausedDate,
      resumeDate: resumeDate,
      pauseCount: pauseCount,
      notes: notes,
    );
  }

  /// Active sub billing in exactly [days] days from start of today.
  static Subscription billingInDays(
    int days, {
    String? id,
    String name = 'Test Sub',
    double amount = 9.99,
    String currencyCode = 'USD',
    SubscriptionCycle cycle = SubscriptionCycle.monthly,
    SubscriptionCategory category = SubscriptionCategory.entertainment,
    bool isPaid = false,
    ReminderConfig? reminders,
  }) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return create(
      id: id,
      name: name,
      amount: amount,
      currencyCode: currencyCode,
      cycle: cycle,
      nextBillingDate: todayStart.add(Duration(days: days)),
      category: category,
      isPaid: isPaid,
      reminders: reminders,
    );
  }

  /// Paused subscription with optional auto-resume date.
  static Subscription paused({
    String? id,
    String name = 'Paused Sub',
    DateTime? pausedDate,
    DateTime? resumeDate,
    DateTime? nextBillingDate,
    int pauseCount = 1,
  }) {
    return create(
      id: id,
      name: name,
      isActive: false,
      pausedDate: pausedDate ?? DateTime.now().subtract(const Duration(days: 3)),
      resumeDate: resumeDate,
      nextBillingDate: nextBillingDate,
      pauseCount: pauseCount,
    );
  }

  /// Trial subscription ending in [daysUntilEnd] days.
  static Subscription trial({
    String? id,
    String name = 'Trial Sub',
    int daysUntilEnd = 5,
    double postTrialAmount = 9.99,
  }) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return create(
      id: id,
      name: name,
      isTrial: true,
      amount: 0,
      trialEndDate: todayStart.add(Duration(days: daysUntilEnd)),
      postTrialAmount: postTrialAmount,
      nextBillingDate: todayStart.add(Duration(days: daysUntilEnd)),
    );
  }

  /// Already-paid subscription (current cycle marked paid).
  static Subscription paid({
    String? id,
    String name = 'Paid Sub',
    DateTime? nextBillingDate,
  }) {
    return create(
      id: id,
      name: name,
      isPaid: true,
      lastMarkedPaidDate: DateTime.now(),
      nextBillingDate: nextBillingDate,
    );
  }
}
