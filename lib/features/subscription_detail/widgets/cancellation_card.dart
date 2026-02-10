import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/core/utils/haptic_utils.dart';
import 'package:custom_subs/data/models/subscription.dart';

/// Card displaying cancellation information and interactive checklist.
///
/// Helps users cancel their subscription with step-by-step guidance:
/// - Direct link to cancellation page (opens in browser)
/// - Phone number for cancellation (launches phone dialer)
/// - Free-form cancellation notes
/// - Interactive checklist with progress tracking
///
/// ## Usage
///
/// ```dart
/// // Only show if cancellation info exists
/// if (subscription.cancelUrl != null ||
///     subscription.cancelPhone != null ||
///     subscription.cancelNotes != null ||
///     subscription.cancelChecklist.isNotEmpty)
///   CancellationCard(
///     subscription: subscription,
///     onToggleChecklistItem: (index) => controller.toggleChecklistItem(index),
///   )
/// ```
///
/// ## Components
///
/// ### 1. Cancellation URL Button
/// - Full-width primary button
/// - Opens URL in external browser via url_launcher
/// - Only shown if `subscription.cancelUrl != null`
///
/// ### 2. Phone Number Button
/// - Full-width outlined button
/// - Launches phone dialer with tel: URI
/// - Only shown if `subscription.cancelPhone != null`
///
/// ### 3. Cancellation Notes
/// - Light green background container
/// - Displays free-form text instructions
/// - Only shown if `subscription.cancelNotes` is non-empty
///
/// ### 4. Interactive Checklist
/// - LinearProgressIndicator showing completion (green fill)
/// - "X of Y complete" counter
/// - CheckboxListTile for each step
/// - Haptic feedback on check/uncheck (via HapticUtils.selection())
/// - Only shown if `subscription.cancelChecklist` is non-empty
///
/// ## Callback: onToggleChecklistItem
///
/// This callback is fired when user taps a checklist item. The parent
/// controller should update the subscription's `checklistCompleted` array:
///
/// ```dart
/// void toggleChecklistItem(int index) {
///   final subscription = state.value;
///   final newCompleted = List<bool>.from(subscription.checklistCompleted);
///   newCompleted[index] = !newCompleted[index];
///
///   final updated = subscription.copyWith(checklistCompleted: newCompleted);
///   await repository.upsert(updated);
///   ref.invalidateSelf();
/// }
/// ```
///
/// ## Haptic Feedback
///
/// Uses `HapticUtils.selection()` when checklist items are toggled,
/// providing tactile confirmation of user action.
///
/// ## Conditional Rendering
///
/// The card should only be shown if ANY cancellation info exists:
/// ```dart
/// if (subscription.cancelUrl != null ||
///     subscription.cancelPhone != null ||
///     subscription.cancelNotes != null ||
///     subscription.cancelChecklist.isNotEmpty)
///   CancellationCard(...)
/// ```
///
/// ## Related Documentation
///
/// - Cancellation feature spec: CLAUDE.md (Phase 2)
/// - Similar form widget: lib/features/add_subscription/widgets/cancellation_section.dart
class CancellationCard extends StatelessWidget {
  /// The subscription containing cancellation information
  final Subscription subscription;

  /// Callback fired when a checklist item is toggled
  final Function(int) onToggleChecklistItem;

  const CancellationCard({
    super.key,
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
                  onChanged: (_) async {
                    await HapticUtils.selection();
                    onToggleChecklistItem(index);
                  },
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
