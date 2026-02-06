import 'package:flutter/material.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/core/utils/currency_utils.dart';
import 'package:custom_subs/core/utils/service_icons.dart';
import 'package:custom_subs/data/models/subscription_cycle.dart';

/// A mini preview card showing how a subscription will appear on the home screen.
///
/// This widget provides live visual feedback as the user configures their
/// subscription, showing exactly how it will look in the upcoming charges list.
///
/// ## Usage
///
/// ```dart
/// SubscriptionPreviewCard(
///   name: _nameController.text,
///   amount: double.tryParse(_amountController.text),
///   currencyCode: _currencyCode,
///   cycle: _cycle,
///   colorValue: _colorValue,
/// )
/// ```
///
/// ## Design Philosophy
///
/// This preview mirrors the exact styling from home_screen.dart subscription tiles,
/// creating a "what you see is what you get" experience. Users can see their
/// subscription come to life as they configure it.
class SubscriptionPreviewCard extends StatelessWidget {
  /// The subscription name (e.g., "Netflix", "Spotify")
  final String name;

  /// The subscription amount (nullable - shows placeholder if null)
  final double? amount;

  /// The currency code (e.g., "USD", "EUR")
  final String currencyCode;

  /// The billing cycle
  final SubscriptionCycle cycle;

  /// The color as an integer (convert to Color via Color(colorValue))
  final int colorValue;

  const SubscriptionPreviewCard({
    super.key,
    required this.name,
    this.amount,
    required this.currencyCode,
    required this.cycle,
    required this.colorValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(colorValue);
    final displayName = name.isEmpty ? 'Subscription Name' : name;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: AppColors.divider,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            'Preview',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSizes.sm),

          // Subscription Tile Preview (matches home_screen.dart)
          Row(
            children: [
              // Circular gradient icon (exact match from home screen)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.15),
                      color.withValues(alpha: 0.25),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: ServiceIcons.hasCustomIcon(displayName)
                      ? Icon(
                          ServiceIcons.getIconForService(displayName),
                          color: color,
                          size: 26,
                        )
                      : Text(
                          displayName[0].toUpperCase(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: AppSizes.base),

              // Name and amount
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      displayName,
                      style: theme.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSizes.xs),

                    // Amount and cycle
                    Row(
                      children: [
                        Text(
                          amount != null
                              ? CurrencyUtils.formatAmount(amount!, currencyCode)
                              : '\$0.00',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '/${cycle.shortName}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
