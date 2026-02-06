import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:custom_subs/features/analytics/analytics_controller.dart';
import 'package:custom_subs/data/models/subscription_category.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';

/// Analytics screen showing spending insights and breakdowns.
///
/// Displays:
/// - Yearly forecast (hero metric, centered at top)
/// - Category breakdown with horizontal bar charts
/// - Top 5 subscriptions by cost
/// - Multi-currency breakdown (if applicable)
///
/// The yearly forecast is the primary focal point, showing annual spending
/// projection in a prominent green gradient card. This provides stronger
/// visual impact and clearer hierarchy than showing monthly totals.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: analyticsAsync.when(
        data: (analytics) {
          // Empty state: no subscriptions
          if (analytics.activeCount == 0) {
            return _EmptyState();
          }

          return _AnalyticsContent(analytics: analytics, ref: ref);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: AppSizes.base),
              Text(
                'Error loading analytics',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Main analytics content with all cards.
class _AnalyticsContent extends StatelessWidget {
  final AnalyticsData analytics;
  final WidgetRef ref;

  const _AnalyticsContent({required this.analytics, required this.ref});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh analytics by invalidating the provider
        ref.invalidate(analyticsControllerProvider);
        await Future.delayed(const Duration(milliseconds: 300));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Yearly Forecast - Centered Hero Metric
            _YearlyForecastCard(analytics: analytics),
            const SizedBox(height: AppSizes.sectionSpacing),

            // Category Breakdown
            if (analytics.categoryBreakdown.isNotEmpty) ...[
              _CategoryBreakdownCard(analytics: analytics),
              const SizedBox(height: AppSizes.sectionSpacing),
            ],

            // Top Subscriptions
            if (analytics.topSubscriptions.isNotEmpty) ...[
              _TopSubscriptionsCard(analytics: analytics),
              const SizedBox(height: AppSizes.sectionSpacing),
            ],

            // Currency Breakdown (only if multi-currency)
            if (analytics.hasMultipleCurrencies) ...[
              _CurrencyBreakdownCard(analytics: analytics),
              const SizedBox(height: AppSizes.base),
            ],
          ],
        ),
      ),
    );
  }
}

/// Yearly forecast card - Primary hero metric centered at top.
class _YearlyForecastCard extends StatelessWidget {
  final AnalyticsData analytics;

  const _YearlyForecastCard({required this.analytics});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: _getCurrencySymbol(analytics.primaryCurrency),
      decimalDigits: 2,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.xl,
          vertical: AppSizes.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Yearly Forecast',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
            ),
            const SizedBox(height: AppSizes.md),

            // Large yearly amount with tabular figures
            Text(
              currencyFormat.format(analytics.yearlyForecast),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                    fontSize: 40,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
            const SizedBox(height: AppSizes.md),

            // Subtext
            Text(
              'At current rate',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
            ),
            const SizedBox(height: AppSizes.sm),

            // Active subscriptions count
            Text(
              '${analytics.activeCount} active ${analytics.activeCount == 1 ? 'subscription' : 'subscriptions'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Category breakdown with horizontal bar charts.
class _CategoryBreakdownCard extends StatelessWidget {
  final AnalyticsData analytics;

  const _CategoryBreakdownCard({required this.analytics});

  @override
  Widget build(BuildContext context) {
    final sortedCategories = analytics.categoriesSortedByAmount;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending by Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSizes.base),

            // Category bars
            ...sortedCategories.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.lg),
                child: _CategoryBar(
                  category: entry.key,
                  data: entry.value,
                  currencySymbol: _getCurrencySymbol(analytics.primaryCurrency),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Single category bar with label, bar, amount, and percentage.
class _CategoryBar extends StatelessWidget {
  final SubscriptionCategory category;
  final CategoryData data;
  final String currencySymbol;

  const _CategoryBar({
    required this.category,
    required this.data,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final categoryName = _getCategoryDisplayName(category);
    final categoryColor = _getCategoryColor(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category name and count
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: categoryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: categoryColor.withValues(alpha: 0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Text(
              categoryName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: AppSizes.sm),
            Text(
              '(${data.count})',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
            ),
            const Spacer(),
            Text(
              '$currencySymbol${data.amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md),

        // Horizontal bar
        Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Background bar (full width, light gray)
                  Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                  ),

                  // Foreground bar (percentage width, colored)
                  FractionallySizedBox(
                    widthFactor: data.percentage / 100,
                    child: Container(
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            categoryColor,
                            categoryColor.withValues(alpha: 0.85),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        boxShadow: [
                          BoxShadow(
                            color: categoryColor.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: AppSizes.md),
                      child: data.percentage > 20 // Only show percentage if bar is wide enough
                          ? Text(
                              '${data.percentage.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            if (data.percentage <= 20) ...[
              const SizedBox(width: AppSizes.md),
              Text(
                '${data.percentage.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Top subscriptions ranked by cost.
class _TopSubscriptionsCard extends StatelessWidget {
  final AnalyticsData analytics;

  const _TopSubscriptionsCard({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Subscriptions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSizes.base),

            // Ranked list
            ...analytics.topSubscriptions.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final subscription = entry.value;
              final isLast = rank == analytics.topSubscriptions.length;

              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : AppSizes.md),
                child: _TopSubscriptionTile(
                  rank: rank,
                  subscription: subscription,
                  currencySymbol: _getCurrencySymbol(analytics.primaryCurrency),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Single top subscription tile with rank badge.
class _TopSubscriptionTile extends ConsumerStatefulWidget {
  final int rank;
  final TopSubscription subscription;
  final String currencySymbol;

  const _TopSubscriptionTile({
    required this.rank,
    required this.subscription,
    required this.currencySymbol,
  });

  @override
  ConsumerState<_TopSubscriptionTile> createState() => _TopSubscriptionTileState();
}

class _TopSubscriptionTileState extends ConsumerState<_TopSubscriptionTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Medal colors for top 3
    final rankColor = widget.rank == 1
        ? const Color(0xFFFFD700) // Gold
        : widget.rank == 2
            ? const Color(0xFFC0C0C0) // Silver
            : widget.rank == 3
                ? const Color(0xFFCD7F32) // Bronze
                : AppColors.textTertiary;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        // Navigate to subscription detail
        context.push('/subscription/${widget.subscription.id}');
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: AppColors.divider,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Rank badge with subscription color border
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: rankColor.withValues(alpha: 0.15),
                  border: Border.all(
                    color: widget.subscription.color,
                    width: 3,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: widget.rank <= 3
                      ? [
                          BoxShadow(
                            color: rankColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${widget.rank}',
                  style: TextStyle(
                    color: widget.rank <= 3 ? rankColor : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.base),

              // Subscription name
              Expanded(
                child: Text(
                  widget.subscription.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Monthly amount
              Text(
                '${widget.currencySymbol}${widget.subscription.monthlyAmount.toStringAsFixed(2)}/mo',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Currency breakdown card (for multi-currency users).
class _CurrencyBreakdownCard extends StatelessWidget {
  final AnalyticsData analytics;

  const _CurrencyBreakdownCard({required this.analytics});

  @override
  Widget build(BuildContext context) {
    final currencyEntries = analytics.currencyBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // Sort by amount descending

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'By Currency',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSizes.base),

            // Currency rows
            ...currencyEntries.map((entry) {
              final currencySymbol = _getCurrencySymbol(entry.key);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${entry.key} ($currencySymbol)',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '$currencySymbol${entry.value.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                    ),
                  ],
                ),
              );
            }),

            const Divider(height: AppSizes.lg),

            // Total in primary currency
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total (${analytics.primaryCurrency})',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '≈ ${_getCurrencySymbol(analytics.primaryCurrency)}${analytics.monthlyTotal.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              'At bundled exchange rates',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state when no subscriptions exist.
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.xl),
              decoration: const BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.analytics_outlined,
                size: 64,
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppSizes.xl),
            Text(
              'No Analytics Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              'Add your first subscription to see spending insights',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.xxl),
            FilledButton.icon(
              onPressed: () {
                context.pop();
                context.push('/add');
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Subscription'),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper functions

String _getCurrencySymbol(String currencyCode) {
  final symbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'AUD': 'A\$',
    'CAD': 'C\$',
    'CHF': 'Fr',
    'CNY': '¥',
    'INR': '₹',
    'KRW': '₩',
    'MXN': '\$',
    'BRL': 'R\$',
    'ZAR': 'R',
    'SEK': 'kr',
    'NOK': 'kr',
    'DKK': 'kr',
    'PLN': 'zł',
    'TRY': '₺',
    'RUB': '₽',
  };
  return symbols[currencyCode] ?? currencyCode;
}

String _getCategoryDisplayName(SubscriptionCategory category) {
  switch (category) {
    case SubscriptionCategory.entertainment:
      return 'Entertainment';
    case SubscriptionCategory.productivity:
      return 'Productivity';
    case SubscriptionCategory.fitness:
      return 'Fitness';
    case SubscriptionCategory.news:
      return 'News';
    case SubscriptionCategory.cloud:
      return 'Cloud Storage';
    case SubscriptionCategory.gaming:
      return 'Gaming';
    case SubscriptionCategory.education:
      return 'Education';
    case SubscriptionCategory.finance:
      return 'Finance';
    case SubscriptionCategory.shopping:
      return 'Shopping';
    case SubscriptionCategory.utilities:
      return 'Utilities';
    case SubscriptionCategory.health:
      return 'Health';
    case SubscriptionCategory.other:
      return 'Other';
  }
}

Color _getCategoryColor(SubscriptionCategory category) {
  switch (category) {
    case SubscriptionCategory.entertainment:
      return const Color(0xFFEF4444); // Red
    case SubscriptionCategory.productivity:
      return const Color(0xFF3B82F6); // Blue
    case SubscriptionCategory.fitness:
      return const Color(0xFF22C55E); // Green
    case SubscriptionCategory.news:
      return const Color(0xFFF59E0B); // Amber
    case SubscriptionCategory.cloud:
      return const Color(0xFF06B6D4); // Cyan
    case SubscriptionCategory.gaming:
      return const Color(0xFF8B5CF6); // Violet
    case SubscriptionCategory.education:
      return const Color(0xFF14B8A6); // Teal
    case SubscriptionCategory.finance:
      return const Color(0xFF84CC16); // Lime
    case SubscriptionCategory.shopping:
      return const Color(0xFFEC4899); // Pink
    case SubscriptionCategory.utilities:
      return const Color(0xFF78716C); // Stone
    case SubscriptionCategory.health:
      return const Color(0xFFF97316); // Orange
    case SubscriptionCategory.other:
      return const Color(0xFF6366F1); // Indigo
  }
}
