import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:custom_subs/data/models/subscription.dart';
import 'package:custom_subs/data/models/subscription_cycle.dart';
import 'package:custom_subs/data/repositories/subscription_repository.dart';
import 'package:custom_subs/core/extensions/date_extensions.dart';
import 'package:custom_subs/core/providers/settings_provider.dart';
import 'package:custom_subs/core/utils/currency_utils.dart';

part 'calendar_controller.g.dart';

/// Controller for the Calendar screen.
///
/// Projects billing dates across a 6-month window (3 months back, 3 forward)
/// and groups them by calendar day for display in the calendar grid.
///
/// Only includes active subscriptions — paused subs are excluded,
/// consistent with the home screen's upcoming/later sections.
@riverpod
class CalendarController extends _$CalendarController {
  @override
  Future<CalendarData> build() async {
    final repository = await ref.watch(subscriptionRepositoryProvider.future);
    final primaryCurrency = ref.read(primaryCurrencyProvider);
    final activeSubscriptions = repository.getAllActive();

    final billingDateMap = _projectBillingDates(activeSubscriptions);

    return CalendarData(
      billingDateMap: billingDateMap,
      activeSubscriptions: activeSubscriptions,
      primaryCurrency: primaryCurrency,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  /// Projects all billing dates for active subscriptions across a 6-month window.
  ///
  /// For each subscription, walks forward and backward from its nextBillingDate
  /// using the subscription's billing cycle to populate every date in the window.
  Map<DateTime, List<Subscription>> _projectBillingDates(
    List<Subscription> subscriptions,
  ) {
    final now = DateTime.now();
    // 3 months back (first day of that month) to 3 months forward (last day)
    final windowStart = DateTime(now.year, now.month - 3, 1);
    final windowEnd = DateTime(now.year, now.month + 4, 0); // last day of month+3

    final map = <DateTime, List<Subscription>>{};

    for (final sub in subscriptions) {
      // Walk FORWARD from nextBillingDate
      DateTime fwd = sub.nextBillingDate;
      while (!fwd.isAfter(windowEnd)) {
        final normalized = DateTime(fwd.year, fwd.month, fwd.day);
        if (!normalized.isBefore(windowStart)) {
          (map[normalized] ??= []).add(sub);
        }
        fwd = _nextBillingDate(fwd, sub.cycle);
      }

      // Walk BACKWARD from one cycle before nextBillingDate
      DateTime bwd = _previousBillingDate(sub.nextBillingDate, sub.cycle);
      while (!bwd.isBefore(windowStart)) {
        final normalized = DateTime(bwd.year, bwd.month, bwd.day);
        if (!normalized.isAfter(windowEnd)) {
          (map[normalized] ??= []).add(sub);
        }
        bwd = _previousBillingDate(bwd, sub.cycle);
      }
    }

    return map;
  }

  /// Advances a date by one billing cycle.
  DateTime _nextBillingDate(DateTime date, SubscriptionCycle cycle) {
    switch (cycle) {
      case SubscriptionCycle.weekly:
        return date.add(const Duration(days: 7));
      case SubscriptionCycle.biweekly:
        return date.add(const Duration(days: 14));
      case SubscriptionCycle.monthly:
        return date.addMonths(1);
      case SubscriptionCycle.quarterly:
        return date.addMonths(3);
      case SubscriptionCycle.biannual:
        return date.addMonths(6);
      case SubscriptionCycle.yearly:
        return date.addMonths(12);
    }
  }

  /// Reverses a date by one billing cycle.
  ///
  /// Cannot use `addMonths(-N)` because Dart's truncated modulo operator
  /// produces invalid month values (e.g., January - 1 = month 0).
  DateTime _previousBillingDate(DateTime date, SubscriptionCycle cycle) {
    switch (cycle) {
      case SubscriptionCycle.weekly:
        return date.subtract(const Duration(days: 7));
      case SubscriptionCycle.biweekly:
        return date.subtract(const Duration(days: 14));
      case SubscriptionCycle.monthly:
        return _subtractMonths(date, 1);
      case SubscriptionCycle.quarterly:
        return _subtractMonths(date, 3);
      case SubscriptionCycle.biannual:
        return _subtractMonths(date, 6);
      case SubscriptionCycle.yearly:
        return _subtractMonths(date, 12);
    }
  }

  /// Safely subtracts months from a date, handling year rollover and
  /// month-end overflow (e.g., Mar 31 - 1 month = Feb 28/29).
  DateTime _subtractMonths(DateTime date, int months) {
    var year = date.year;
    var month = date.month - months;
    while (month <= 0) {
      month += 12;
      year -= 1;
    }
    final daysInTarget = DateTime(year, month + 1, 0).day;
    final day = date.day > daysInTarget ? daysInTarget : date.day;
    return DateTime(year, month, day);
  }
}

/// Holds projected billing data for the calendar view.
class CalendarData {
  /// Map from midnight-normalized date to subscriptions billing that day.
  final Map<DateTime, List<Subscription>> billingDateMap;

  /// All active subscriptions (source data for counts/totals).
  final List<Subscription> activeSubscriptions;

  /// User's primary currency code for formatting amounts.
  final String primaryCurrency;

  CalendarData({
    required this.billingDateMap,
    required this.activeSubscriptions,
    required this.primaryCurrency,
  });

  /// Returns subscriptions billing on [day], normalized to midnight.
  List<Subscription> subscriptionsForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return billingDateMap[normalized] ?? [];
  }

  /// Returns total spending for [day] converted to primary currency.
  double totalForDay(DateTime day) {
    final subs = subscriptionsForDay(day);
    return subs.fold(0.0, (sum, sub) {
      return sum + CurrencyUtils.convert(
        sub.amount,
        sub.currencyCode,
        primaryCurrency,
      );
    });
  }
}
