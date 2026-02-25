import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/core/utils/haptic_utils.dart';
import 'package:custom_subs/core/utils/snackbar_utils.dart';
import 'package:custom_subs/core/widgets/skeleton_widgets.dart';
import 'package:custom_subs/features/subscription_detail/subscription_detail_controller.dart';
import 'package:custom_subs/features/home/home_controller.dart';
import 'package:custom_subs/app/router.dart';
import 'package:custom_subs/data/services/undo_service.dart';
import 'package:custom_subs/data/repositories/subscription_repository.dart';
import 'package:custom_subs/data/services/notification_service.dart';
import 'package:custom_subs/data/models/subscription.dart';
import 'package:custom_subs/features/subscription_detail/widgets/notes_card.dart';
import 'package:custom_subs/features/subscription_detail/widgets/header_card.dart';
import 'package:custom_subs/features/subscription_detail/widgets/billing_info_card.dart';
import 'package:custom_subs/features/subscription_detail/widgets/cancellation_card.dart';
import 'package:custom_subs/features/subscription_detail/widgets/reminder_info_card.dart';

/// Subscription Detail Screen
///
/// Displays full details of a subscription with actions:
/// - View billing info, amounts, dates
/// - Mark as paid / Resume / Pause
/// - Access cancellation information
/// - Edit or delete subscription
class SubscriptionDetailScreen extends ConsumerStatefulWidget {
  final String subscriptionId;
  final bool autoMarkPaid;

  const SubscriptionDetailScreen({
    super.key,
    required this.subscriptionId,
    this.autoMarkPaid = false,
  });

  @override
  ConsumerState<SubscriptionDetailScreen> createState() =>
      _SubscriptionDetailScreenState();
}

class _SubscriptionDetailScreenState
    extends ConsumerState<SubscriptionDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Generate animations for up to 6 cards (max possible)
    _fadeAnimations = List.generate(6, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.1,
            (index * 0.1) + 0.4,
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    _slideAnimations = List.generate(6, (index) {
      return Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.1,
            (index * 0.1) + 0.4,
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    // Auto-mark as paid if triggered from notification
    if (widget.autoMarkPaid) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final controller = ref.read(
          subscriptionDetailControllerProvider(widget.subscriptionId).notifier,
        );
        await controller.togglePaid();

        if (mounted) {
          SnackBarUtils.show(
            context,
            SnackBarUtils.success('Marked as paid ✓'),
          );
        }
      });
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(
      subscriptionDetailControllerProvider(widget.subscriptionId),
    );

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
        int cardIndex = 0;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Details'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                await HapticUtils.light();
                if (context.mounted) {
                  context.pop();
                }
              },
            ),
            actions: [
              // Edit button
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  await HapticUtils.light();
                  if (context.mounted) {
                    context.push(
                      '${AppRouter.addSubscription}?id=${subscription.id}',
                    );
                  }
                },
              ),
              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  await HapticUtils.light();
                  if (context.mounted) {
                    _showDeleteConfirmation(context, ref);
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card 0: Header with icon, name, status (always present)
                SlideTransition(
                  position: _slideAnimations[cardIndex],
                  child: FadeTransition(
                    opacity: _fadeAnimations[cardIndex++],
                    child: HeaderCard(
                      subscription: subscription,
                      subscriptionColor: subscriptionColor,
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.base),

                // Card 1: Subscription Actions (conditional based on pause state)
                SlideTransition(
                  position: _slideAnimations[cardIndex],
                  child: FadeTransition(
                    opacity: _fadeAnimations[cardIndex++],
                    child: subscription.isActive
                        ? _ActiveSubscriptionActions(
                            subscription: subscription,
                            onMarkPaid: () async {
                              await HapticUtils.medium();
                              ref
                                  .read(subscriptionDetailControllerProvider(
                                          widget.subscriptionId)
                                      .notifier)
                                  .togglePaid();
                            },
                            onPause: () => _showPauseDialog(context, ref, subscription),
                          )
                        : _PausedSubscriptionActions(
                            subscription: subscription,
                            onResume: () async {
                              await HapticUtils.medium();
                              ref
                                  .read(subscriptionDetailControllerProvider(
                                          widget.subscriptionId)
                                      .notifier)
                                  .resumeSubscription();
                            },
                          ),
                  ),
                ),

                const SizedBox(height: AppSizes.base),

                // Card 2: Billing info card (always present)
                SlideTransition(
                  position: _slideAnimations[cardIndex],
                  child: FadeTransition(
                    opacity: _fadeAnimations[cardIndex++],
                    child: BillingInfoCard(subscription: subscription),
                  ),
                ),

                const SizedBox(height: AppSizes.base),

                // Card 3: Cancellation info (conditional)
                if (subscription.cancelUrl != null ||
                    subscription.cancelPhone != null ||
                    subscription.cancelNotes != null ||
                    subscription.cancelChecklist.isNotEmpty)
                  SlideTransition(
                    position: _slideAnimations[cardIndex],
                    child: FadeTransition(
                      opacity: _fadeAnimations[cardIndex++],
                      child: CancellationCard(
                        subscription: subscription,
                        onToggleChecklistItem: (index) => ref
                            .read(subscriptionDetailControllerProvider(
                                    widget.subscriptionId)
                                .notifier)
                            .toggleChecklistItem(index),
                      ),
                    ),
                  ),

                const SizedBox(height: AppSizes.base),

                // Card 4: Notes card (conditional)
                if (subscription.notes != null && subscription.notes!.isNotEmpty)
                  SlideTransition(
                    position: _slideAnimations[cardIndex],
                    child: FadeTransition(
                      opacity: _fadeAnimations[cardIndex++],
                      child: NotesCard(notes: subscription.notes!),
                    ),
                  ),

                const SizedBox(height: AppSizes.base),

                // Card 5: Reminder info (always present)
                SlideTransition(
                  position: _slideAnimations[cardIndex],
                  child: FadeTransition(
                    opacity: _fadeAnimations[cardIndex++],
                    child: ReminderInfoCard(subscription: subscription),
                  ),
                ),

                const SizedBox(height: AppSizes.xxl),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('Details'),
          leading: const BackButton(),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.base),
          child: Column(
            children: [
              // Skeleton header card
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.lg),
                  child: Column(
                    children: [
                      SkeletonBox(width: 80, height: 80, borderRadius: AppSizes.radiusLg),
                      SizedBox(height: AppSizes.base),
                      SkeletonBox(width: 120, height: 24),
                      SizedBox(height: AppSizes.sm),
                      SkeletonBox(width: 100, height: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.base),
              const SkeletonBox(height: 48), // Mark as paid button
              const SizedBox(height: AppSizes.base),
              // Billing info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.base),
                  child: Column(
                    children: List.generate(
                      4,
                      (index) => const Padding(
                        padding: EdgeInsets.only(bottom: AppSizes.md),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SkeletonBox(width: 80, height: 14),
                            SkeletonBox(width: 100, height: 14),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
              await HapticUtils.heavy(); // Destructive action haptic

              // Cache subscription before deleting for UNDO functionality
              final controller = ref.read(
                subscriptionDetailControllerProvider(widget.subscriptionId).notifier,
              );
              final currentSubscription = await ref.read(
                subscriptionDetailControllerProvider(widget.subscriptionId).future,
              );

              if (currentSubscription != null) {
                final undoService = UndoService();
                undoService.cacheDeletedSubscription(currentSubscription);
              }

              // Delete subscription
              await controller.deleteSubscription();

              if (context.mounted) {
                Navigator.of(context).pop(); // Close dialog
                context.pop(); // Go back to home

                // Show success snackbar with UNDO
                SnackBarUtils.show(
                  context,
                  SnackBarUtils.success(
                    'Subscription deleted',
                    onUndo: () async {
                      await HapticUtils.medium();
                      final undoService = UndoService();
                      final cached = undoService.getDeletedSubscription();

                      if (cached != null) {
                        // Restore subscription to database
                        final repository = await ref.read(
                          subscriptionRepositoryProvider.future,
                        );
                        await repository.upsert(cached);

                        // Re-schedule notifications
                        final notificationService = await ref.read(
                          notificationServiceProvider.future,
                        );
                        await notificationService
                            .scheduleNotificationsForSubscription(cached);

                        // Refresh home screen to show restored subscription
                        ref.invalidate(homeControllerProvider);

                        if (context.mounted) {
                          SnackBarUtils.show(
                            context,
                            SnackBarUtils.info('Subscription restored'),
                          );
                        }
                      }
                    },
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showPauseDialog(BuildContext context, WidgetRef ref, Subscription subscription) {
    DateTime? selectedResumeDate;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Pause Subscription'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'While paused:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSizes.sm),
              const Row(
                children: [
                  Icon(Icons.notifications_off, size: 16, color: AppColors.textSecondary),
                  SizedBox(width: AppSizes.sm),
                  Expanded(child: Text('No reminders will be sent')),
                ],
              ),
              const SizedBox(height: AppSizes.xs),
              const Row(
                children: [
                  Icon(Icons.pause_circle_outline, size: 16, color: AppColors.textSecondary),
                  SizedBox(width: AppSizes.sm),
                  Expanded(child: Text('Billing dates won\'t advance')),
                ],
              ),
              const SizedBox(height: AppSizes.xs),
              const Row(
                children: [
                  Icon(Icons.trending_down, size: 16, color: AppColors.textSecondary),
                  SizedBox(width: AppSizes.sm),
                  Expanded(child: Text('Excluded from spending totals')),
                ],
              ),

              const SizedBox(height: AppSizes.lg),

              const Text(
                'Auto-resume date (optional):',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSizes.sm),
              OutlinedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => selectedResumeDate = picked);
                  }
                },
                child: Text(
                  selectedResumeDate != null
                      ? DateFormat('MMM d, y').format(selectedResumeDate!)
                      : 'Resume manually',
                ),
              ),

              if (selectedResumeDate != null) ...[
                const SizedBox(height: AppSizes.sm),
                TextButton(
                  onPressed: () => setState(() => selectedResumeDate = null),
                  child: const Text('Clear date'),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await HapticUtils.medium();
                ref
                    .read(subscriptionDetailControllerProvider(widget.subscriptionId).notifier)
                    .pauseSubscription(resumeDate: selectedResumeDate);
              },
              child: const Text('Pause'),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widget for active subscription actions
class _ActiveSubscriptionActions extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback onMarkPaid;
  final VoidCallback onPause;

  const _ActiveSubscriptionActions({
    required this.subscription,
    required this.onMarkPaid,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Mark as Paid button (2/3 width)
        Expanded(
          flex: 2,
          child: OutlinedButton.icon(
            onPressed: onMarkPaid,
            icon: Icon(
              subscription.isPaid
                  ? Icons.check_circle
                  : Icons.check_circle_outline,
            ),
            label: Text(subscription.isPaid ? 'Paid' : 'Mark as Paid'),
          ),
        ),

        const SizedBox(width: AppSizes.md),

        // Pause button (1/3 width)
        Expanded(
          flex: 1,
          child: OutlinedButton(
            onPressed: onPause,
            child: const Icon(Icons.pause, size: 20),
          ),
        ),
      ],
    );
  }
}

// Helper widget for paused subscription actions
class _PausedSubscriptionActions extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback onResume;

  const _PausedSubscriptionActions({
    required this.subscription,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Pause status info card
        Container(
          padding: const EdgeInsets.all(AppSizes.base),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(Icons.pause_circle, color: AppColors.primary),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subscription Paused',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getResumeInfoText(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSizes.md),

        // Resume button
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onResume,
            icon: const Icon(Icons.play_arrow, size: 20),
            label: const Text('Resume Subscription'),
          ),
        ),
      ],
    );
  }

  String _getResumeInfoText() {
    if (subscription.resumeDate != null) {
      final formatter = DateFormat('MMM d, y');
      return 'Auto-resumes on ${formatter.format(subscription.resumeDate!)}';
    }
    return 'Paused ${subscription.daysPaused} days ago';
  }
}
