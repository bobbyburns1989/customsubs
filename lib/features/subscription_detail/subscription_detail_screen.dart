import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/core/utils/currency_utils.dart';
import 'package:custom_subs/core/utils/service_icons.dart';
import 'package:custom_subs/core/extensions/date_extensions.dart';
import 'package:custom_subs/core/widgets/subtle_pressable.dart';
import 'package:custom_subs/features/subscription_detail/subscription_detail_controller.dart';
import 'package:custom_subs/app/router.dart';
import 'package:custom_subs/data/models/subscription.dart';

/// Subscription Detail Screen
///
/// Displays full details of a subscription with actions:
/// - View billing info, amounts, dates
/// - Mark as paid / Resume / Pause
/// - Access cancellation information
/// - Edit or delete subscription
class SubscriptionDetailScreen extends ConsumerWidget {
  final String subscriptionId;

  const SubscriptionDetailScreen({
    super.key,
    required this.subscriptionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(subscriptionDetailControllerProvider(subscriptionId));

    return controller.when(
      data: (subscription) {
        if (subscription == null) {
          // Subscription deleted or not found
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.pop();
            }
          });
          return const Scaffold(
            body: Center(child: Text('Subscription not found')),
          );
        }

        final subscriptionColor = Color(subscription.colorValue);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Details'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            actions: [
              // Edit button
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push(
                  '${AppRouter.addSubscription}?id=${subscription.id}',
                ),
              ),
              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _showDeleteConfirmation(context, ref),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with icon, name, status
                _HeaderCard(
                  subscription: subscription,
                  subscriptionColor: subscriptionColor,
                ),

                const SizedBox(height: AppSizes.base),

                // Quick actions
                _QuickActionsRow(
                  subscription: subscription,
                  onTogglePaid: () => ref
                      .read(subscriptionDetailControllerProvider(subscriptionId).notifier)
                      .togglePaid(),
                  onToggleActive: () => ref
                      .read(subscriptionDetailControllerProvider(subscriptionId).notifier)
                      .toggleActive(),
                ),

                const SizedBox(height: AppSizes.base),

                // Billing info card
                _BillingInfoCard(subscription: subscription),

                const SizedBox(height: AppSizes.base),

                // Cancellation info (if exists)
                if (subscription.cancelUrl != null ||
                    subscription.cancelPhone != null ||
                    subscription.cancelNotes != null ||
                    subscription.cancelChecklist.isNotEmpty)
                  _CancellationCard(
                    subscription: subscription,
                    onToggleChecklistItem: (index) => ref
                        .read(subscriptionDetailControllerProvider(subscriptionId).notifier)
                        .toggleChecklistItem(index),
                  ),

                const SizedBox(height: AppSizes.base),

                // Notes card (if exists)
                if (subscription.notes != null && subscription.notes!.isNotEmpty)
                  _NotesCard(notes: subscription.notes!),

                const SizedBox(height: AppSizes.base),

                // Reminder info
                _ReminderInfoCard(subscription: subscription),

                const SizedBox(height: AppSizes.xxl),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppSizes.base),
              Text('Error loading subscription: $error'),
              const SizedBox(height: AppSizes.base),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subscription?'),
        content: const Text(
          'This will permanently delete this subscription and cancel all reminders. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () async {
              // Delete subscription
              await ref
                  .read(subscriptionDetailControllerProvider(subscriptionId).notifier)
                  .deleteSubscription();

              if (context.mounted) {
                Navigator.of(context).pop(); // Close dialog
                context.pop(); // Go back to home

                // Show confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Subscription deleted')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Header card with icon, name, and status badge
class _HeaderCard extends StatelessWidget {
  final Subscription subscription;
  final Color subscriptionColor;

  const _HeaderCard({
    required this.subscription,
    required this.subscriptionColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: subscriptionColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              ),
              child: Center(
                child: subscription.iconName != null
                    ? Icon(
                        ServiceIcons.getIconForService(subscription.iconName!),
                        size: 40,
                        color: subscriptionColor,
                      )
                    : Text(
                        subscription.name.substring(0, 1).toUpperCase(),
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: subscriptionColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: AppSizes.base),

            // Name
            Text(
              subscription.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSizes.sm),

            // Amount + Cycle
            Text(
              '${CurrencyUtils.formatAmount(subscription.amount, subscription.currencyCode)}/${subscription.cycle.shortName}',
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: AppSizes.base),

            // Status badges
            Wrap(
              spacing: AppSizes.sm,
              runSpacing: AppSizes.sm,
              alignment: WrapAlignment.center,
              children: [
                // Active/Paused badge
                _StatusBadge(
                  label: subscription.isActive ? 'Active' : 'Paused',
                  color: subscription.isActive ? AppColors.success : AppColors.inactive,
                ),

                // Trial badge
                if (subscription.isTrial)
                  const _StatusBadge(
                    label: 'Trial',
                    color: AppColors.trial,
                  ),

                // Paid badge with fade animation
                AnimatedOpacity(
                  opacity: subscription.isPaid ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  child: const _StatusBadge(
                    label: 'Paid',
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Status badge widget with smooth color transitions
class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.base,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        child: Text(label),
      ),
    );
  }
}

/// Quick actions row (Mark Paid, Pause/Resume)
class _QuickActionsRow extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback onTogglePaid;
  final VoidCallback onToggleActive;

  const _QuickActionsRow({
    required this.subscription,
    required this.onTogglePaid,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SubtlePressable(
            onPressed: onTogglePaid,
            child: OutlinedButton.icon(
              onPressed: null, // SubtlePressable handles the tap
              icon: Icon(
                subscription.isPaid ? Icons.check_circle : Icons.check_circle_outline,
              ),
              label: Text(subscription.isPaid ? 'Paid' : 'Mark as Paid'),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.base),
        Expanded(
          child: SubtlePressable(
            onPressed: onToggleActive,
            child: OutlinedButton.icon(
              onPressed: null, // SubtlePressable handles the tap
              icon: Icon(
                subscription.isActive ? Icons.pause_circle_outline : Icons.play_circle_outline,
              ),
              label: Text(subscription.isActive ? 'Pause' : 'Resume'),
            ),
          ),
        ),
      ],
    );
  }
}

/// Billing information card
class _BillingInfoCard extends StatelessWidget {
  final Subscription subscription;

  const _BillingInfoCard({required this.subscription});

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
            _InfoRow(
              label: 'Next Billing',
              value: subscription.nextBillingDate.toFormattedString(),
              highlight: subscription.nextBillingDate.toShortRelativeString(),
            ),

            const Divider(height: AppSizes.lg),

            // Billing cycle
            _InfoRow(
              label: 'Billing Cycle',
              value: subscription.cycle.displayName,
            ),

            const Divider(height: AppSizes.lg),

            // Amount
            _InfoRow(
              label: 'Amount',
              value: CurrencyUtils.formatAmount(
                subscription.amount,
                subscription.currencyCode,
              ),
            ),

            const Divider(height: AppSizes.lg),

            // Start date
            _InfoRow(
              label: 'Started',
              value: subscription.startDate.toFormattedString(),
            ),

            // Trial info (if applicable)
            if (subscription.isTrial) ...[
              const Divider(height: AppSizes.lg),
              _InfoRow(
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

/// Cancellation information card
class _CancellationCard extends StatelessWidget {
  final Subscription subscription;
  final Function(int) onToggleChecklistItem;

  const _CancellationCard({
    required this.subscription,
    required this.onToggleChecklistItem,
  });

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
              'How to Cancel',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppSizes.base),

            // Cancel URL button
            if (subscription.cancelUrl != null) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    final url = Uri.parse(subscription.cancelUrl!);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open Cancellation Page'),
                ),
              ),
              const SizedBox(height: AppSizes.base),
            ],

            // Phone number button
            if (subscription.cancelPhone != null) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final url = Uri.parse('tel:${subscription.cancelPhone!}');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                  icon: const Icon(Icons.phone),
                  label: Text('Call ${subscription.cancelPhone!}'),
                ),
              ),
              const SizedBox(height: AppSizes.base),
            ],

            // Cancellation notes
            if (subscription.cancelNotes != null && subscription.cancelNotes!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(AppSizes.base),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Text(
                  subscription.cancelNotes!,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: AppSizes.base),
            ],

            // Checklist
            if (subscription.cancelChecklist.isNotEmpty) ...[
              Text(
                'Cancellation Steps',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSizes.sm),

              // Progress indicator
              LinearProgressIndicator(
                value: subscription.checklistCompleted.where((c) => c).length /
                    subscription.cancelChecklist.length,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                '${subscription.checklistCompleted.where((c) => c).length} of ${subscription.cancelChecklist.length} complete',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppSizes.base),

              // Checklist items
              ...List.generate(subscription.cancelChecklist.length, (index) {
                return CheckboxListTile(
                  value: subscription.checklistCompleted[index],
                  onChanged: (_) => onToggleChecklistItem(index),
                  title: Text(subscription.cancelChecklist[index]),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

/// Notes card
class _NotesCard extends StatelessWidget {
  final String notes;

  const _NotesCard({required this.notes});

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
              'Notes',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.base),
            Text(
              notes,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Reminder information card
class _ReminderInfoCard extends StatelessWidget {
  final Subscription subscription;

  const _ReminderInfoCard({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reminders = subscription.reminders;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reminder Settings',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppSizes.base),

            if (reminders.firstReminderDays > 0)
              _InfoRow(
                label: 'First Reminder',
                value: '${reminders.firstReminderDays} days before',
              ),

            if (reminders.secondReminderDays > 0) ...[
              const Divider(height: AppSizes.lg),
              _InfoRow(
                label: 'Second Reminder',
                value: '${reminders.secondReminderDays} days before',
              ),
            ],

            if (reminders.remindOnBillingDay) ...[
              const Divider(height: AppSizes.lg),
              const _InfoRow(
                label: 'Day-of Reminder',
                value: 'Enabled',
              ),
            ],

            const Divider(height: AppSizes.lg),
            _InfoRow(
              label: 'Reminder Time',
              value: '${reminders.reminderHour.toString().padLeft(2, '0')}:${reminders.reminderMinute.toString().padLeft(2, '0')}',
            ),
          ],
        ),
      ),
    );
  }
}

/// Info row widget (label + value)
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final String? highlight;

  const _InfoRow({
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
