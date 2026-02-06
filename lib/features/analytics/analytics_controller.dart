import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:custom_subs/data/models/monthly_snapshot.dart';
import 'package:custom_subs/data/models/subscription.dart';
import 'package:custom_subs/data/models/subscription_category.dart';
import 'package:custom_subs/data/repositories/subscription_repository.dart';
import 'package:custom_subs/core/utils/currency_utils.dart';
import 'package:custom_subs/core/providers/settings_provider.dart';

part 'analytics_controller.g.dart';

/// Controller for the Analytics screen.
///
/// Provides spending analytics including:
/// - Yearly forecast (primary hero metric)
/// - Category breakdown with percentages
/// - Top 5 subscriptions by monthly cost
/// - Multi-currency breakdown
///
/// Automatically saves a monthly snapshot when the analytics screen is opened
/// (once per month, not on every visit). Monthly snapshots are preserved for
/// future features but currently not displayed in the UI.
@riverpod
class AnalyticsController extends _$AnalyticsController {
  late Box<MonthlySnapshot> _snapshotBox;

  @override
  Future<AnalyticsData> build() async {
    _snapshotBox = Hive.box<MonthlySnapshot>('monthly_snapshots');

    // Get repository and subscriptions
    final repository = await ref.watch(subscriptionRepositoryProvider.future);
    final subscriptions = repository.getAllActive();

    // Save monthly snapshot if needed
    await _saveMonthlySnapshot(subscriptions);

    // Calculate and return analytics
    return _calculateAnalytics(subscriptions);
  }

  /// Saves a monthly snapshot if one doesn't exist for the current month.
  ///
  /// This enables month-over-month comparison in analytics.
  /// Only creates one snapshot per month to avoid duplicates.
  Future<void> _saveMonthlySnapshot(List<Subscription> subscriptions) async {
    final currentMonth = _getCurrentMonth();

    // Check if snapshot already exists for this month
    final existingSnapshot = _snapshotBox.values
        .where((s) => s.month == currentMonth)
        .firstOrNull;

    if (existingSnapshot != null) {
      // Snapshot already exists for this month, skip
      return;
    }

    // Get primary currency
    final primaryCurrency = ref.read(primaryCurrencyProvider);

    // Calculate category totals
    final categoryTotals = <String, double>{};
    for (final sub in subscriptions) {
      final categoryName = sub.category.toString().split('.').last;
      final converted = CurrencyUtils.convert(
        sub.effectiveMonthlyAmount,
        sub.currencyCode,
        primaryCurrency,
      );
      categoryTotals[categoryName] = (categoryTotals[categoryName] ?? 0) + converted;
    }

    // Create and save snapshot
    final snapshot = MonthlySnapshot(
      month: currentMonth,
      totalMonthlySpend: _calculateTotal(subscriptions, primaryCurrency),
      currencyCode: primaryCurrency,
      snapshotDate: DateTime.now(),
      activeSubscriptionCount: subscriptions.length,
      categoryTotals: categoryTotals,
    );

    await _snapshotBox.add(snapshot);
  }

  /// Calculates all analytics data.
  AnalyticsData _calculateAnalytics(List<Subscription> subscriptions) {
    final primaryCurrency = ref.read(primaryCurrencyProvider);

    // Calculate totals
    final currentMonthTotal = _calculateTotal(subscriptions, primaryCurrency);
    final previousMonthTotal = _getPreviousMonthTotal();
    final monthlyChange = previousMonthTotal != null
        ? currentMonthTotal - previousMonthTotal
        : null;

    // Calculate breakdowns
    final categoryBreakdown = _calculateCategoryBreakdown(subscriptions, primaryCurrency, currentMonthTotal);
    final topSubscriptions = _getTopSubscriptions(subscriptions, primaryCurrency);
    final currencyBreakdown = _getCurrencyBreakdown(subscriptions);

    return AnalyticsData(
      monthlyTotal: currentMonthTotal,
      yearlyForecast: currentMonthTotal * 12,
      activeCount: subscriptions.length,
      monthlyChange: monthlyChange,
      categoryBreakdown: categoryBreakdown,
      topSubscriptions: topSubscriptions,
      currencyBreakdown: currencyBreakdown,
      primaryCurrency: primaryCurrency,
    );
  }

  /// Returns the current month in YYYY-MM format.
  String _getCurrentMonth() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  /// Gets the previous month's total spending from saved snapshots.
  ///
  /// Returns null if no snapshot exists for the previous month.
  double? _getPreviousMonthTotal() {
    final now = DateTime.now();
    final previousMonth = DateTime(now.year, now.month - 1);
    final monthKey = '${previousMonth.year}-${previousMonth.month.toString().padLeft(2, '0')}';

    final snapshot = _snapshotBox.values
        .where((s) => s.month == monthKey)
        .firstOrNull;

    return snapshot?.totalMonthlySpend;
  }

  /// Calculates total monthly spending converted to primary currency.
  double _calculateTotal(List<Subscription> subs, String primaryCurrency) {
    return subs.fold(0.0, (sum, sub) {
      final converted = CurrencyUtils.convert(
        sub.effectiveMonthlyAmount,
        sub.currencyCode,
        primaryCurrency,
      );
      return sum + converted;
    });
  }

  /// Calculates category breakdown with amounts, percentages, and counts.
  Map<SubscriptionCategory, CategoryData> _calculateCategoryBreakdown(
    List<Subscription> subs,
    String primaryCurrency,
    double total,
  ) {
    final breakdown = <SubscriptionCategory, CategoryData>{};

    // Group subscriptions by category and calculate totals
    for (final sub in subs) {
      final converted = CurrencyUtils.convert(
        sub.effectiveMonthlyAmount,
        sub.currencyCode,
        primaryCurrency,
      );

      final existing = breakdown[sub.category];
      if (existing != null) {
        breakdown[sub.category] = CategoryData(
          amount: existing.amount + converted,
          percentage: 0, // Will calculate after summing
          count: existing.count + 1,
        );
      } else {
        breakdown[sub.category] = CategoryData(
          amount: converted,
          percentage: 0, // Will calculate after summing
          count: 1,
        );
      }
    }

    // Calculate percentages (avoid division by zero)
    if (total > 0) {
      breakdown.forEach((category, data) {
        breakdown[category] = CategoryData(
          amount: data.amount,
          percentage: (data.amount / total) * 100,
          count: data.count,
        );
      });
    }

    return breakdown;
  }

  /// Returns top 5 subscriptions by monthly cost.
  List<TopSubscription> _getTopSubscriptions(
    List<Subscription> subs,
    String primaryCurrency,
  ) {
    // Convert all to monthly equivalents in primary currency
    final subscriptionsWithCost = subs.map((sub) {
      final monthlyAmount = CurrencyUtils.convert(
        sub.effectiveMonthlyAmount,
        sub.currencyCode,
        primaryCurrency,
      );
      return TopSubscription(
        id: sub.id,
        name: sub.name,
        monthlyAmount: monthlyAmount,
        currencyCode: primaryCurrency,
        color: Color(sub.colorValue),
      );
    }).toList();

    // Sort by monthly amount descending
    subscriptionsWithCost.sort((a, b) => b.monthlyAmount.compareTo(a.monthlyAmount));

    // Return top 5 (or fewer if less than 5 subscriptions)
    return subscriptionsWithCost.take(5).toList();
  }

  /// Calculates spending breakdown by currency (before conversion).
  ///
  /// Returns a map of currency code -> total amount in that currency.
  /// Only includes currencies that are actually used in subscriptions.
  Map<String, double> _getCurrencyBreakdown(List<Subscription> subs) {
    final breakdown = <String, double>{};

    for (final sub in subs) {
      breakdown[sub.currencyCode] = (breakdown[sub.currencyCode] ?? 0) + sub.effectiveMonthlyAmount;
    }

    return breakdown;
  }
}

/// Analytics data containing all calculated spending information.
class AnalyticsData {
  /// Total monthly spending in primary currency
  final double monthlyTotal;

  /// Projected yearly spending (monthlyTotal * 12)
  final double yearlyForecast;

  /// Number of active subscriptions
  final int activeCount;

  /// Change from previous month (positive = increase, negative = decrease)
  /// Null if no previous month data available
  final double? monthlyChange;

  /// Spending breakdown by category
  final Map<SubscriptionCategory, CategoryData> categoryBreakdown;

  /// Top 5 subscriptions by monthly cost
  final List<TopSubscription> topSubscriptions;

  /// Spending breakdown by currency (before conversion to primary currency)
  final Map<String, double> currencyBreakdown;

  /// Primary currency code for display
  final String primaryCurrency;

  AnalyticsData({
    required this.monthlyTotal,
    required this.yearlyForecast,
    required this.activeCount,
    required this.monthlyChange,
    required this.categoryBreakdown,
    required this.topSubscriptions,
    required this.currencyBreakdown,
    required this.primaryCurrency,
  });

  /// Returns true if the user has subscriptions in multiple currencies
  bool get hasMultipleCurrencies => currencyBreakdown.length > 1;

  /// Returns category breakdown sorted by amount (highest first)
  List<MapEntry<SubscriptionCategory, CategoryData>> get categoriesSortedByAmount {
    final entries = categoryBreakdown.entries.toList();
    entries.sort((a, b) => b.value.amount.compareTo(a.value.amount));
    return entries;
  }
}

/// Category spending data with amount, percentage, and subscription count.
class CategoryData {
  /// Total amount spent in this category (in primary currency)
  final double amount;

  /// Percentage of total spending (0-100)
  final double percentage;

  /// Number of subscriptions in this category
  final int count;

  CategoryData({
    required this.amount,
    required this.percentage,
    required this.count,
  });
}

/// Top subscription data for ranking.
class TopSubscription {
  /// Subscription ID
  final String id;

  /// Subscription name
  final String name;

  /// Monthly amount in primary currency
  final double monthlyAmount;

  /// Primary currency code
  final String currencyCode;

  /// Subscription color
  final Color color;

  TopSubscription({
    required this.id,
    required this.name,
    required this.monthlyAmount,
    required this.currencyCode,
    required this.color,
  });
}
