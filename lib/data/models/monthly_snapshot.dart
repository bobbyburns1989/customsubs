import 'package:hive/hive.dart';

part 'monthly_snapshot.g.dart';

/// Represents a snapshot of spending data for a specific month.
/// Used for month-over-month comparison in analytics.
///
/// Snapshots are automatically created once per month when the analytics
/// screen is opened. If a snapshot already exists for the current month,
/// it is not recreated.
@HiveType(typeId: 4)
class MonthlySnapshot extends HiveObject {
  /// Month identifier in YYYY-MM format (e.g., "2026-02")
  @HiveField(0)
  final String month;

  /// Total monthly spending converted to primary currency
  @HiveField(1)
  final double totalMonthlySpend;

  /// Primary currency code at the time of snapshot (e.g., "USD", "EUR")
  @HiveField(2)
  final String currencyCode;

  /// Timestamp when this snapshot was created
  @HiveField(3)
  final DateTime snapshotDate;

  /// Number of active subscriptions at snapshot time
  @HiveField(4)
  final int activeSubscriptionCount;

  /// Spending breakdown by category name
  /// Maps category name (e.g., "entertainment") to total amount in primary currency
  @HiveField(5)
  final Map<String, double> categoryTotals;

  MonthlySnapshot({
    required this.month,
    required this.totalMonthlySpend,
    required this.currencyCode,
    required this.snapshotDate,
    required this.activeSubscriptionCount,
    required this.categoryTotals,
  });

  /// Returns the previous month's identifier
  /// Example: "2026-02" -> "2026-01"
  String get previousMonth {
    final parts = month.split('-');
    final year = int.parse(parts[0]);
    final monthNum = int.parse(parts[1]);

    if (monthNum == 1) {
      // January -> December of previous year
      return '${year - 1}-12';
    } else {
      // Other months -> previous month
      return '$year-${(monthNum - 1).toString().padLeft(2, '0')}';
    }
  }

  @override
  String toString() {
    return 'MonthlySnapshot('
        'month: $month, '
        'total: $totalMonthlySpend $currencyCode, '
        'activeCount: $activeSubscriptionCount, '
        'categories: ${categoryTotals.length}'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MonthlySnapshot &&
        other.month == month &&
        other.totalMonthlySpend == totalMonthlySpend &&
        other.currencyCode == currencyCode;
  }

  @override
  int get hashCode {
    return month.hashCode ^ totalMonthlySpend.hashCode ^ currencyCode.hashCode;
  }
}
