import 'package:flutter/material.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/data/models/subscription.dart';
import 'package:custom_subs/l10n/generated/app_localizations.dart';
import 'package:custom_subs/features/subscription_detail/widgets/info_row.dart';

/// Card displaying reminder configuration for a subscription.
///
/// Shows when and how often the user will be reminded about upcoming charges:
/// - First reminder (days before billing)
/// - Second reminder (days before billing)
/// - Day-of reminder (enabled/disabled)
/// - Reminder time (hour:minute)
///
/// ## Usage
///
/// ```dart
/// ReminderInfoCard(
///   subscription: subscription,
/// )
/// ```
///
/// ## Display Logic
///
/// - Only shows first reminder if > 0 days
/// - Only shows second reminder if > 0 days
/// - Day-of reminder shows "Enabled" when active
/// - Time formatted as HH:MM (24-hour with zero padding)
///
/// ## Example Output
///
/// ```
/// Reminder Settings
/// ─────────────────
/// First Reminder     7 days before
/// Second Reminder    1 day before
/// Day-of Reminder    Enabled
/// Reminder Time      09:00
/// ```
///
/// ## Related Models
///
/// Uses `subscription.reminders` (ReminderConfig):
/// - firstReminderDays: int
/// - secondReminderDays: int
/// - remindOnBillingDay: bool
/// - reminderHour: int
/// - reminderMinute: int
class ReminderInfoCard extends StatelessWidget {
  /// The subscription containing reminder configuration
  final Subscription subscription;

  const ReminderInfoCard({super.key, required this.subscription});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final reminders = subscription.reminders;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.reminderCardTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppSizes.base),

            if (reminders.firstReminderDays > 0)
              InfoRow(
                label: l10n.reminderCardFirst,
                value: l10n.reminderCardFirstValue(reminders.firstReminderDays),
              ),

            if (reminders.secondReminderDays > 0) ...[
              const Divider(height: AppSizes.lg),
              InfoRow(
                label: l10n.reminderCardSecond,
                value: l10n.reminderCardSecondValue(reminders.secondReminderDays),
              ),
            ],

            if (reminders.remindOnBillingDay) ...[
              const Divider(height: AppSizes.lg),
              InfoRow(
                label: l10n.reminderCardDayOf,
                value: l10n.reminderCardEnabled,
              ),
            ],

            const Divider(height: AppSizes.lg),
            InfoRow(
              label: l10n.reminderCardTime,
              value: '${reminders.reminderHour.toString().padLeft(2, '0')}:${reminders.reminderMinute.toString().padLeft(2, '0')}',
            ),
          ],
        ),
      ),
    );
  }
}
