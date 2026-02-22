import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:custom_subs/features/analytics/analytics_controller.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/core/utils/haptic_utils.dart';
import 'package:custom_subs/core/widgets/skeleton_widgets.dart';
import 'package:custom_subs/core/widgets/empty_state_widget.dart';
import 'package:custom_subs/features/analytics/widgets/category_donut_chart.dart';

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
          onPressed: () async {
            await HapticUtils.light();
            if (context.mounted) {
              context.pop();
            }
          },
        ),
      ),
      body: analyticsAsync.when(
        data: (analytics) {
          // Empty state: no subscriptions
          if (analytics.activeCount == 0) {
            return EmptyStateWidget(
              icon: Icons.analytics_outlined,
              title: 'No Analytics Yet',
              subtitle: 'Add your first subscription to see spending insights',
              buttonText: 'Add Subscription',
              onButtonPressed: () {
                context.pop();
                context.push('/add-subscription');
              },
            );
          }

          return _AnalyticsContent(analytics: analytics, ref: ref);
        },
        loading: () => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Skeleton yearly forecast
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                child: const SkeletonBox(width: double.infinity, height: 180, borderRadius: AppSizes.radiusLg),
              ),
              const SizedBox(height: AppSizes.sectionSpacing),

              // Skeleton category breakdown card
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 150, height: 18),
                      SizedBox(height: AppSizes.base),
                      SkeletonCategoryBar(),
                      SkeletonCategoryBar(),
                      SkeletonCategoryBar(),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
class _AnalyticsContent extends StatefulWidget {
  final AnalyticsData analytics;
  final WidgetRef ref;

  const _AnalyticsContent({required this.analytics, required this.ref});

  @override
  State<_AnalyticsContent> createState() => _AnalyticsContentState();
}

class _AnalyticsContentState extends State<_AnalyticsContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;
  bool _hasAnimated = false; // Prevent re-animation on pull-to-refresh

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // 4 cards: Forecast, Category, Top Subs, Currency
    _fadeAnimations = List.generate(4, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.15,        // Start time
            (index * 0.15) + 0.4, // End time
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    _slideAnimations = List.generate(4, (index) {
      return Tween<Offset>(
        begin: const Offset(0, 0.15), // Start 15% below
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.15,
            (index * 0.15) + 0.4,
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    // Only animate on first mount
    if (!_hasAnimated) {
      _controller.forward();
      _hasAnimated = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int cardIndex = 0;

    return RefreshIndicator(
      onRefresh: () async {
        await HapticUtils.heavy(); // Pull-to-refresh haptic
        // Refresh analytics by invalidating the provider
        widget.ref.invalidate(analyticsControllerProvider);
        await Future.delayed(const Duration(milliseconds: 300));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card 0: Yearly Forecast - Centered Hero Metric (always present)
            SlideTransition(
              position: _slideAnimations[cardIndex],
              child: FadeTransition(
                opacity: _fadeAnimations[cardIndex++],
                child: _YearlyForecastCard(analytics: widget.analytics),
              ),
            ),
            const SizedBox(height: AppSizes.sectionSpacing),

            // Card 1: Category Breakdown (conditional)
            if (widget.analytics.categoryBreakdown.isNotEmpty) ...[
              SlideTransition(
                position: _slideAnimations[cardIndex],
                child: FadeTransition(
                  opacity: _fadeAnimations[cardIndex++],
                  child: _CategoryBreakdownCard(analytics: widget.analytics),
                ),
              ),
              const SizedBox(height: AppSizes.sectionSpacing),
            ],

            // Card 2: Top Subscriptions (conditional)
            if (widget.analytics.topSubscriptions.isNotEmpty) ...[
              SlideTransition(
                position: _slideAnimations[cardIndex],
                child: FadeTransition(
                  opacity: _fadeAnimations[cardIndex++],
                  child: _TopSubscriptionsCard(analytics: widget.analytics),
                ),
              ),
              const SizedBox(height: AppSizes.sectionSpacing),
            ],

            // Card 3: Currency Breakdown (conditional)
            if (widget.analytics.hasMultipleCurrencies) ...[
              SlideTransition(
                position: _slideAnimations[cardIndex],
                child: FadeTransition(
                  opacity: _fadeAnimations[cardIndex++],
                  child: _CurrencyBreakdownCard(analytics: widget.analytics),
                ),
              ),
              const SizedBox(height: AppSizes.base),
            ],
          ],
        ),
      ),
    );
  }
}

/// Yearly forecast card - Primary hero metric centered at top.
class _YearlyForecastCard extends StatefulWidget {
  final AnalyticsData analytics;

  const _YearlyForecastCard({required this.analytics});

  @override
  State<_YearlyForecastCard> createState() => _YearlyForecastCardState();
}

class _YearlyForecastCardState extends State<_YearlyForecastCard> {
  double _displayValue = 0.0;

  @override
  void initState() {
    super.initState();
    _displayValue = 0.0; // Start from 0 for initial animation
  }

  @override
  void didUpdateWidget(_YearlyForecastCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if value actually changed (prevents re-animation on rebuild)
    if (oldWidget.analytics.yearlyForecast != widget.analytics.yearlyForecast) {
      _displayValue = oldWidget.analytics.yearlyForecast;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: _getCurrencySymbol(widget.analytics.primaryCurrency),
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

            // Large yearly amount with tabular figures - Animated
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: _displayValue, end: widget.analytics.yearlyForecast),
              curve: Curves.easeOutCubic,
              builder: (context, animatedValue, child) {
                return Text(
                  currencyFormat.format(animatedValue),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                        fontSize: 40,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                );
              },
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
              '${widget.analytics.activeCount} active ${widget.analytics.activeCount == 1 ? 'subscription' : 'subscriptions'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
            ),
            const SizedBox(height: AppSizes.sm),

            // Daily cost breakdown
            Text(
              'That\'s ${currencyFormat.format(widget.analytics.yearlyForecast / 365)} per day',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontFeatures: const [FontFeature.tabularFigures()],
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
            CategoryDonutChart(
              categoryBreakdown: analytics.categoryBreakdown,
              currencySymbol: _getCurrencySymbol(analytics.primaryCurrency),
            ),
          ],
        ),
      ),
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
      onTap: () async {
        await HapticUtils.light(); // Navigation feedback
        // Navigate to subscription detail
        if (context.mounted) {
          context.push('/subscription/${widget.subscription.id}');
        }
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
              // Rank badge with subscription color border and Hero animation
              Hero(
                tag: 'subscription-icon-${widget.subscription.id}',
                child: Container(
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
