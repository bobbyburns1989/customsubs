import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/core/extensions/theme_extensions.dart';
import 'package:custom_subs/data/models/subscription_category.dart';
import 'package:custom_subs/features/analytics/analytics_controller.dart';

class CategoryDonutChart extends StatefulWidget {
  final Map<SubscriptionCategory, CategoryData> categoryBreakdown;
  final String currencySymbol;

  const CategoryDonutChart({
    super.key,
    required this.categoryBreakdown,
    required this.currencySymbol,
  });

  @override
  State<CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends State<CategoryDonutChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final sortedEntries = widget.categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.amount.compareTo(a.value.amount));

    // Calculate total for center display
    final total = widget.categoryBreakdown.values
        .fold(0.0, (sum, d) => sum + d.amount);

    // Center overlay text: shows touched category detail, or monthly total by default
    final String centerLabel;
    final String centerAmount;
    String? centerPercent;

    if (_touchedIndex != null && _touchedIndex! < sortedEntries.length) {
      final entry = sortedEntries[_touchedIndex!];
      centerLabel = _getCategoryDisplayName(entry.key);
      centerAmount =
          '${widget.currencySymbol}${entry.value.amount.toStringAsFixed(2)}';
      centerPercent = '${entry.value.percentage.toStringAsFixed(1)}%';
    } else {
      centerLabel = 'Monthly';
      centerAmount = '${widget.currencySymbol}${total.toStringAsFixed(2)}';
    }

    return Column(
      children: [
        // Donut chart with center text overlay (Stack avoids on-slice label clipping)
        SizedBox(
          height: 210,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 65,
                  sections: _buildSections(sortedEntries),
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          _touchedIndex = null;
                          return;
                        }
                        _touchedIndex =
                            pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                ),
                swapAnimationDuration: const Duration(milliseconds: 250),
                swapAnimationCurve: Curves.easeOut,
              ),

              // Center info panel — shows total by default, category on touch
              IgnorePointer(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Column(
                    key: ValueKey('$centerLabel$centerAmount'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        centerLabel,
                        style: TextStyle(
                          fontSize: 11,
                          color: context.colors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        centerAmount,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.colors.textPrimary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      if (centerPercent != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          centerPercent,
                          style: TextStyle(
                            fontSize: 11,
                            color: context.colors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSizes.lg),

        // Legend
        Wrap(
          spacing: AppSizes.md,
          runSpacing: AppSizes.sm,
          alignment: WrapAlignment.center,
          children: sortedEntries.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value.key;
            final data = entry.value.value;
            final color = _getCategoryColor(category);
            final isSelected = _touchedIndex == index;

            return _LegendItem(
              color: color,
              label: _getCategoryDisplayName(category),
              amount: '${widget.currencySymbol}${data.amount.toStringAsFixed(2)}',
              isSelected: isSelected,
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Builds pie sections with no on-slice labels — percentages are shown
  /// in the center overlay instead to avoid clipping against the chart bounds.
  List<PieChartSectionData> _buildSections(
    List<MapEntry<SubscriptionCategory, CategoryData>> entries,
  ) {
    return entries.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value.key;
      final data = entry.value.value;
      final isTouched = index == _touchedIndex;

      return PieChartSectionData(
        color: _getCategoryColor(category),
        value: data.amount,
        title: '', // Percentages shown in center overlay — no on-slice clipping
        radius: isTouched ? 52.0 : 46.0,
      );
    }).toList();
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String amount;
  final bool isSelected;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.amount,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.xs),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(
          color: isSelected ? color : context.colors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: AppSizes.sm),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          )),
          const SizedBox(width: AppSizes.xs),
          Text(amount, style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.colors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          )),
        ],
      ),
    );
  }
}

// Helper functions
String _getCategoryDisplayName(SubscriptionCategory category) {
  switch (category) {
    case SubscriptionCategory.entertainment: return 'Entertainment';
    case SubscriptionCategory.productivity: return 'Productivity';
    case SubscriptionCategory.fitness: return 'Fitness';
    case SubscriptionCategory.news: return 'News';
    case SubscriptionCategory.cloud: return 'Cloud Storage';
    case SubscriptionCategory.gaming: return 'Gaming';
    case SubscriptionCategory.education: return 'Education';
    case SubscriptionCategory.finance: return 'Finance';
    case SubscriptionCategory.shopping: return 'Shopping';
    case SubscriptionCategory.utilities: return 'Utilities';
    case SubscriptionCategory.health: return 'Health';
    case SubscriptionCategory.other: return 'Other';
    case SubscriptionCategory.sports: return 'Sports';
  }
}

Color _getCategoryColor(SubscriptionCategory category) {
  switch (category) {
    case SubscriptionCategory.entertainment: return const Color(0xFFEF4444);
    case SubscriptionCategory.productivity: return const Color(0xFF3B82F6);
    case SubscriptionCategory.fitness: return const Color(0xFF22C55E);
    case SubscriptionCategory.news: return const Color(0xFFF59E0B);
    case SubscriptionCategory.cloud: return const Color(0xFF06B6D4);
    case SubscriptionCategory.gaming: return const Color(0xFF8B5CF6);
    case SubscriptionCategory.education: return const Color(0xFF14B8A6);
    case SubscriptionCategory.finance: return const Color(0xFF84CC16);
    case SubscriptionCategory.shopping: return const Color(0xFFEC4899);
    case SubscriptionCategory.utilities: return const Color(0xFF78716C);
    case SubscriptionCategory.health: return const Color(0xFFF97316);
    case SubscriptionCategory.other: return const Color(0xFF6366F1);
    case SubscriptionCategory.sports: return const Color(0xFF0EA5E9); // sky blue — distinct from gaming purple and fitness green
  }
}
