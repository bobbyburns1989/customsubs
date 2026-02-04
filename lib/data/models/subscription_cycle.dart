import 'package:hive/hive.dart';

part 'subscription_cycle.g.dart';

@HiveType(typeId: 1)
enum SubscriptionCycle {
  @HiveField(0)
  weekly,

  @HiveField(1)
  biweekly,

  @HiveField(2)
  monthly,

  @HiveField(3)
  quarterly,

  @HiveField(4)
  biannual,

  @HiveField(5)
  yearly;

  String get displayName {
    switch (this) {
      case SubscriptionCycle.weekly:
        return 'Weekly';
      case SubscriptionCycle.biweekly:
        return 'Biweekly';
      case SubscriptionCycle.monthly:
        return 'Monthly';
      case SubscriptionCycle.quarterly:
        return 'Quarterly';
      case SubscriptionCycle.biannual:
        return 'Biannual';
      case SubscriptionCycle.yearly:
        return 'Yearly';
    }
  }

  String get shortName {
    switch (this) {
      case SubscriptionCycle.weekly:
        return 'wk';
      case SubscriptionCycle.biweekly:
        return '2wk';
      case SubscriptionCycle.monthly:
        return 'mo';
      case SubscriptionCycle.quarterly:
        return 'qtr';
      case SubscriptionCycle.biannual:
        return '6mo';
      case SubscriptionCycle.yearly:
        return 'yr';
    }
  }

  /// Returns the number of days in this cycle (approximate for calculations)
  int get daysInCycle {
    switch (this) {
      case SubscriptionCycle.weekly:
        return 7;
      case SubscriptionCycle.biweekly:
        return 14;
      case SubscriptionCycle.monthly:
        return 30;
      case SubscriptionCycle.quarterly:
        return 90;
      case SubscriptionCycle.biannual:
        return 182;
      case SubscriptionCycle.yearly:
        return 365;
    }
  }

  /// Calculates the monthly equivalent amount
  double toMonthlyAmount(double amount) {
    switch (this) {
      case SubscriptionCycle.weekly:
        return amount * 52 / 12;
      case SubscriptionCycle.biweekly:
        return amount * 26 / 12;
      case SubscriptionCycle.monthly:
        return amount;
      case SubscriptionCycle.quarterly:
        return amount / 3;
      case SubscriptionCycle.biannual:
        return amount / 6;
      case SubscriptionCycle.yearly:
        return amount / 12;
    }
  }
}
