import 'package:flutter/material.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/core/utils/currency_utils.dart';
import 'package:custom_subs/core/extensions/date_extensions.dart';
import 'package:custom_subs/data/models/subscription.dart';
import 'package:custom_subs/features/subscription_detail/widgets/info_row.dart';

/// Card displaying billing cycle, amounts, dates, and trial information.
///
/// Shows all essential billing information in a clean, scannable format:
/// - Next billing date (with countdown badge)
/// - Billing cycle (monthly, yearly, etc.)
/// - Amount (formatted with currency)
/// - Start date
/// - Trial information (if applicable)
///
/// ## Usage
///
/// ```dart
/// BillingInfoCard(
///   subscription: subscription,
/// )
/// ```
///
/// ## Display Logic
///
/// **Standard subscriptions:**
/// ```
/// Billing Information
/// ───────────────────
/// Next Billing    Jan 15, 2026  [in 3 days]
/// Billing Cycle   Monthly
/// Amount          $15.99
/// Started         Dec 1, 2025
/// ```
///
/// **Trial subscriptions:**
/// ```
/// Billing Information
/// ───────────────────
/// Next Billing    Jan 15, 2026  [in 3 days]
/// Billing Cycle   Monthly
/// Amount          $0.00
/// Started         Dec 1, 2025
/// Trial Ends      Jan 10, 2026  [in 1 day]
///                 Then $15.99/month
/// ```
///
/// ## Trial Behavior
///
/// When `subscription.isTrial` is true:
/// - Shows "Trial Ends" row with countdown badge
/// - Shows "Then $X.XX/cycle" line if `postTrialAmount` exists
/// - Amount row shows current trial amount (usually $0.00)
///
/// ## Date Formatting
///
/// Uses `DateExtensions` for human-friendly dates:
/// - `.toFormattedString()` → "Jan 15, 2026"
/// - `.toShortRelativeString()` → "in 3 days", "Tomorrow", "Today"
///
/// The countdown badge uses AppColors.trial (amber) for visual emphasis.
///
/// ## Related Extensions
///
/// - `DateExtensions.toFormattedString()` (core/extensions/date_extensions.dart)
/// - `DateExtensions.toShortRelativeString()` (core/extensions/date_extensions.dart)
/// - `CurrencyUtils.formatAmount()` (core/utils/currency_utils.dart)
class BillingInfoCard extends StatelessWidget {
  /// The subscription containing billing information
  final Subscription subscription;

  const BillingInfoCard({super.key, required this.subscription});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Billing Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppSizes.base),

            // Next billing date
            InfoRow(
              label: 'Next Billing',
              value: subscription.nextBillingDate.toFormattedString(),
              highlight: subscription.nextBillingDate.toShortRelativeString(),
            ),

            const Divider(height: AppSizes.lg),

            // Billing cycle
            InfoRow(
              label: 'Billing Cycle',
              value: subscription.cycle.displayName,
            ),

            const Divider(height: AppSizes.lg),

            // Amount
            InfoRow(
              label: 'Amount',
              value: CurrencyUtils.formatAmount(
                subscription.amount,
                subscription.currencyCode,
              ),
            ),

            const Divider(height: AppSizes.lg),

            // Start date
            InfoRow(
              label: 'Started',
              value: subscription.startDate.toFormattedString(),
            ),

            // Trial info (if applicable)
            if (subscription.isTrial) ...[
              const Divider(height: AppSizes.lg),
              InfoRow(
                label: 'Trial Ends',
                value: subscription.trialEndDate?.toFormattedString() ?? 'Unknown',
                highlight: subscription.trialEndDate?.toShortRelativeString(),
              ),
              if (subscription.postTrialAmount != null) ...[
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Then ${CurrencyUtils.formatAmount(subscription.postTrialAmount!, subscription.currencyCode)}/${subscription.cycle.shortName}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
