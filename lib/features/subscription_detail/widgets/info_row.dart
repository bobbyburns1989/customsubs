import 'package:flutter/material.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';

/// A reusable row widget displaying a label-value pair with optional highlight badge.
///
/// Used throughout subscription detail screen to display billing information,
/// reminder settings, and other key-value data in a consistent format.
///
/// ## Visual Structure
///
/// ```
/// [Label]                    [Value] [Badge]
/// ```
///
/// ## Usage
///
/// ```dart
/// // Simple label-value pair
/// InfoRow(
///   label: 'Amount',
///   value: '\$15.99',
/// )
///
/// // With highlight badge (e.g., countdown)
/// InfoRow(
///   label: 'Next Billing',
///   value: 'Jan 15, 2026',
///   highlight: 'in 3 days',
/// )
/// ```
///
/// ## Design Philosophy
///
/// This widget provides consistent formatting for all info rows across the
/// detail screen. The highlight badge uses AppColors.trial for emphasis,
/// making countdowns and time-sensitive information stand out.
class InfoRow extends StatelessWidget {
  /// The label text displayed on the left side
  final String label;

  /// The value text displayed on the right side
  final String value;

  /// Optional highlight badge shown after the value (e.g., countdown text)
  final String? highlight;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (highlight != null) ...[
              const SizedBox(width: AppSizes.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.trial.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Text(
                  highlight!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.trial,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
