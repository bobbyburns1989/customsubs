import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:custom_subs/features/analytics/smart_insights_controller.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/core/utils/haptic_utils.dart';
import 'package:custom_subs/data/services/analytics_service.dart';

/// Smart Insights card shown at the bottom of the Analytics screen.
///
/// Displays up to four offline insight types:
/// 1. Service overlap (duplicate music/video/cloud subscriptions)
/// 2. Annual billing savings estimate
/// 3. Known bundle opportunities
/// 4. High-spend category flag
///
/// Returns [SizedBox.shrink] when no insights are available (no empty card visible).
class SmartInsightsCard extends ConsumerWidget {
  const SmartInsightsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(smartInsightsProvider);

    return insightsAsync.when(
      // Show nothing while loading — avoids skeleton flash on a supplementary card
      loading: () => const SizedBox.shrink(),

      // Show nothing on error — analytics still work, insights are optional
      error: (_, __) => const SizedBox.shrink(),

      data: (data) {
        if (!data.hasAnyInsight) return const SizedBox.shrink();

        return _SmartInsightsCardContent(data: data);
      },
    );
  }
}

/// Renders the card once insights data is available.
class _SmartInsightsCardContent extends StatelessWidget {
  final SmartInsightsData data;

  const _SmartInsightsCardContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    // Build insight rows in priority order, inserting dividers between them
    void addRow(Widget row) {
      if (rows.isNotEmpty) {
        rows.add(const Divider(
          height: 1,
          thickness: 1,
          color: AppColors.divider,
        ));
      }
      rows.add(row);
    }

    // Overlap insights (can be multiple — music, video, cloud)
    for (final overlap in data.overlaps) {
      addRow(_OverlapRow(insight: overlap));
    }

    // Annual savings (at most one)
    if (data.annualSavings != null) {
      addRow(_AnnualSavingsRow(insight: data.annualSavings!));
    }

    // Bundle opportunities (sorted by savings, can be multiple)
    for (final bundle in data.bundleOpportunities) {
      addRow(_BundleRow(insight: bundle));
    }

    // High-spend category (at most one)
    if (data.highSpendCategory != null) {
      addRow(_HighSpendRow(insight: data.highSpendCategory!));
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.lg,
              AppSizes.lg,
              AppSizes.lg,
              AppSizes.md,
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 16)),
                const SizedBox(width: AppSizes.sm),
                Text(
                  'Smart Insights',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: AppColors.divider),

          // Insight rows
          ...rows,

          const SizedBox(height: AppSizes.xs),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Insight Row: Overlap
// ---------------------------------------------------------------------------

class _OverlapRow extends StatelessWidget {
  final OverlapInsight insight;

  const _OverlapRow({required this.insight});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final names = insight.names.join(' · ');

    return _InsightRow(
      accentColor: AppColors.warning,
      icon: Icons.warning_amber_rounded,
      title: '${insight.names.length} ${insight.groupLabel} services',
      subtitle: '$names = ${fmt.format(insight.combinedMonthly)}/mo combined',
      onTap: () {
        AnalyticsService().capture('smart_insight_tapped', {
          'insight_type': 'service_overlap',
        });
        _showOverlapSheet(context, insight);
      },
    );
  }

  void _showOverlapSheet(BuildContext context, OverlapInsight insight) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheet(
        title: 'Overlapping ${insight.groupLabel}',
        accentColor: AppColors.warning,
        icon: Icons.warning_amber_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have ${insight.names.length} ${insight.groupLabel} subscriptions. '
              'These services offer similar content — you may only need one.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSizes.lg),
            ...insight.names.map((name) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.sm),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.circle,
                        size: 8,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: Text(
                          name,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: AppSizes.lg),
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.savings_outlined,
                      size: 20, color: AppColors.warning),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Text(
                      'Combined: ${fmt.format(insight.combinedMonthly)}/mo · '
                      '${fmt.format(insight.combinedMonthly * 12)}/year',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.warning,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Insight Row: Annual Savings
// ---------------------------------------------------------------------------

class _AnnualSavingsRow extends StatelessWidget {
  final AnnualSavingsInsight insight;

  const _AnnualSavingsRow({required this.insight});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return _InsightRow(
      accentColor: AppColors.primary,
      icon: Icons.calendar_today_rounded,
      title: 'Switch to annual billing',
      subtitle: 'Est. save ${fmt.format(insight.minSavings)}–'
          '${fmt.format(insight.maxSavings)}/year',
      onTap: () {
        AnalyticsService().capture('smart_insight_tapped', {
          'insight_type': 'annual_savings',
        });
        _showAnnualSavingsSheet(context, insight);
      },
    );
  }

  void _showAnnualSavingsSheet(
      BuildContext context, AnnualSavingsInsight insight) {
    final fmtShort = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheet(
        title: 'Annual Billing Savings',
        accentColor: AppColors.primary,
        icon: Icons.calendar_today_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Most services offer a 15–20% discount when you pay annually '
              'instead of monthly.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Savings range highlight
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '${fmtShort.format(insight.minSavings)}–'
                    '${fmtShort.format(insight.maxSavings)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'estimated annual savings',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.md),

            Text(
              'Applies to ${insight.subscriptionCount} monthly-billed '
              '${insight.subscriptionCount == 1 ? 'subscription' : 'subscriptions'}.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),

            const SizedBox(height: AppSizes.sm),

            // Disclaimer
            Text(
              '* Estimated based on a 15–20% typical discount. Check each '
              'provider\'s current annual pricing for exact savings.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Insight Row: Bundle Opportunity
// ---------------------------------------------------------------------------

class _BundleRow extends StatelessWidget {
  final BundleInsight insight;

  const _BundleRow({required this.insight});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return _InsightRow(
      accentColor: AppColors.primary,
      icon: Icons.workspace_premium_rounded,
      title: '${insight.bundleName} available',
      subtitle: 'Save ~${fmt.format(insight.potentialSavings)}/mo vs separate plans',
      onTap: () {
        AnalyticsService().capture('smart_insight_tapped', {
          'insight_type': 'bundle_opportunity',
        });
        _showBundleSheet(context, insight);
      },
    );
  }

  void _showBundleSheet(BuildContext context, BundleInsight insight) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheet(
        title: insight.bundleName,
        accentColor: AppColors.primary,
        icon: Icons.workspace_premium_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              insight.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Price comparison table
            _PriceComparisonRow(
              label: 'You pay now',
              amount: fmt.format(insight.currentCost),
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSizes.sm),
            _PriceComparisonRow(
              label: insight.bundleName,
              amount: fmt.format(insight.bundleAmount),
              color: AppColors.primary,
            ),
            const Divider(height: AppSizes.lg),
            _PriceComparisonRow(
              label: 'Monthly savings',
              amount: '~${fmt.format(insight.potentialSavings)}',
              color: AppColors.primary,
              bold: true,
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              '≈ ${fmt.format(insight.potentialSavings * 12)}/year',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
            ),

            const SizedBox(height: AppSizes.lg),

            // Disclaimer
            Text(
              '* Bundle price shown in USD. Check current pricing — '
              'promotions and regional pricing vary.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontStyle: FontStyle.italic,
                  ),
            ),

            // URL button (if available)
            if (insight.url != null) ...[
              const SizedBox(height: AppSizes.lg),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await HapticUtils.light();
                    final uri = Uri.parse(insight.url!);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Check current pricing'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Simple label + amount row for the bundle price comparison.
class _PriceComparisonRow extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final bool bold;

  const _PriceComparisonRow({
    required this.label,
    required this.amount,
    required this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: bold ? color : AppColors.textPrimary,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
        ),
        Text(
          '$amount/mo',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Insight Row: High-Spend Category
// ---------------------------------------------------------------------------

class _HighSpendRow extends StatelessWidget {
  final HighSpendInsight insight;

  const _HighSpendRow({required this.insight});

  @override
  Widget build(BuildContext context) {
    final pct = insight.percentage.toStringAsFixed(0);

    return _InsightRow(
      accentColor: AppColors.warning,
      icon: Icons.pie_chart_rounded,
      title: '${insight.categoryName} = $pct% of spend',
      subtitle: 'One category dominates your subscription budget',
      onTap: () {
        AnalyticsService().capture('smart_insight_tapped', {
          'insight_type': 'high_spend_category',
        });
        _showHighSpendSheet(context, insight);
      },
    );
  }

  void _showHighSpendSheet(BuildContext context, HighSpendInsight insight) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final pct = insight.percentage.toStringAsFixed(1);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheet(
        title: '${insight.categoryName} Spending',
        accentColor: AppColors.warning,
        icon: Icons.pie_chart_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${insight.categoryName} accounts for $pct% of your active '
              'subscription spend — ${fmt.format(insight.monthlyAmount)}/mo '
              '(${fmt.format(insight.monthlyAmount * 12)}/year).',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Percentage bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: insight.percentage / 100,
                minHeight: 8,
                backgroundColor: AppColors.divider,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.warning),
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // List subscriptions in this category
            Text(
              'Subscriptions in this category:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSizes.sm),

            ...insight.subscriptionNames.map((name) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.xs),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.circle,
                        size: 8,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: Text(
                          name,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared: Insight Row (tappable row with icon, title, subtitle, chevron)
// ---------------------------------------------------------------------------

class _InsightRow extends StatefulWidget {
  final Color accentColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _InsightRow({
    required this.accentColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_InsightRow> createState() => _InsightRowState();
}

class _InsightRowState extends State<_InsightRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () async {
        await HapticUtils.light();
        widget.onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        color: _pressed
            ? AppColors.divider
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.md,
        ),
        child: Row(
          children: [
            // Colored accent icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: widget.accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Icon(
                widget.icon,
                size: 18,
                color: widget.accentColor,
              ),
            ),
            const SizedBox(width: AppSizes.md),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Chevron
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared: Bottom Sheet Shell
// ---------------------------------------------------------------------------

class _BottomSheet extends StatelessWidget {
  final String title;
  final Color accentColor;
  final IconData icon;
  final Widget child;

  const _BottomSheet({
    required this.title,
    required this.accentColor,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: AppSizes.md),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Sheet header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.lg,
              AppSizes.lg,
              AppSizes.lg,
              AppSizes.md,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Icon(icon, size: 20, color: accentColor),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                  color: AppColors.textTertiary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),

          // Sheet content — scrollable so it doesn't overflow on small phones
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.lg,
                AppSizes.lg,
                AppSizes.lg,
                AppSizes.lg + MediaQuery.of(context).padding.bottom,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
