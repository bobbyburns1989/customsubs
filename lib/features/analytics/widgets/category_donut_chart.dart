import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
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

    return Column(
      children: [
        // Donut Chart
        SizedBox(
          height: 240,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 60, // Donut hole
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
                    _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
            ),
            swapAnimationDuration: const Duration(milliseconds: 250),
            swapAnimationCurve: Curves.easeOut,
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

  List<PieChartSectionData> _buildSections(
    List<MapEntry<SubscriptionCategory, CategoryData>> entries,
  ) {
    return entries.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value.key;
      final data = entry.value.value;
      final isTouched = index == _touchedIndex;

      final radius = isTouched ? 50.0 : 45.0;
      final fontSize = isTouched ? 16.0 : 14.0;

      return PieChartSectionData(
        color: _getCategoryColor(category),
        value: data.amount,
        title: '${data.percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [
            Shadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 2),
          ],
        ),
        badgeWidget: isTouched ? _buildBadge(data.count) : null,
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.xs),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        '$count',
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
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
          color: isSelected ? color : AppColors.border,
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
            color: AppColors.textSecondary,
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
  }
}
