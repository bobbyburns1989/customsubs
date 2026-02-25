import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/core/utils/currency_utils.dart';
import 'package:custom_subs/core/utils/haptic_utils.dart';
import 'package:custom_subs/data/models/subscription.dart';
import 'package:custom_subs/core/utils/service_icons.dart';
import 'package:custom_subs/core/extensions/date_extensions.dart';
import 'package:custom_subs/core/providers/settings_provider.dart';
import 'package:custom_subs/core/providers/entitlement_provider.dart';
import 'package:custom_subs/core/widgets/subtle_pressable.dart';
import 'package:custom_subs/core/widgets/skeleton_widgets.dart';
import 'package:custom_subs/core/widgets/empty_state_widget.dart';
import 'package:custom_subs/features/home/home_controller.dart';
import 'package:custom_subs/features/settings/widgets/backup_reminder_dialog.dart';
import 'package:custom_subs/app/router.dart';
import 'package:custom_subs/data/repositories/subscription_repository.dart';
import 'package:custom_subs/data/services/notification_service.dart';
import 'package:flutter/material.dart' as material;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  AnimationController? _listAnimationController;
  List<Animation<double>>? _tileAnimations;

  @override
  void initState() {
    super.initState();
    // Register lifecycle observer to detect app resume
    WidgetsBinding.instance.addObserver(this);

    // Check if backup reminder should be shown (after first frame)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBackupReminder();
    });
  }

  void _initializeListAnimations(int itemCount) {
    _listAnimationController?.dispose();

    _listAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + (itemCount * 50).clamp(0, 300)),
    );

    _tileAnimations = List.generate(itemCount, (index) {
      final start = (index * 0.1).clamp(0.0, 0.6);
      final end = (start + 0.4).clamp(0.0, 1.0);

      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _listAnimationController!,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _listAnimationController!.forward();
  }

  @override
  void dispose() {
    _listAnimationController?.dispose();
    // Clean up lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came back from background - check for overdue dates
      _advanceOverdueDatesIfNeeded();
    }
  }

  /// Advances billing dates that have passed and reschedules notifications.
  ///
  /// Called when:
  /// - App resumes from background (via lifecycle hook)
  /// - User pulls to refresh
  Future<void> _advanceOverdueDatesIfNeeded() async {
    final repository = await ref.read(subscriptionRepositoryProvider.future);
    final notificationService = await ref.read(notificationServiceProvider.future);

    // Advance overdue billing dates and reset isPaid for those subscriptions
    final updatedSubscriptions = await repository.advanceOverdueBillingDates();

    // Auto-resume subscriptions whose resumeDate has passed
    final resumedSubscriptions = await repository.autoResumeSubscriptions();

    // Re-schedule notifications for all affected subscriptions
    for (final subscription in [...updatedSubscriptions, ...resumedSubscriptions]) {
      await notificationService.scheduleNotificationsForSubscription(subscription);
    }

    // Refresh UI if any changes occurred
    if (updatedSubscriptions.isNotEmpty || resumedSubscriptions.isNotEmpty) {
      ref.read(homeControllerProvider.notifier).refresh();
    }
  }

  Future<void> _checkBackupReminder() async {
    final homeController = ref.read(homeControllerProvider.notifier);
    if (homeController.shouldShowBackupReminder()) {
      final dontShowAgain = await showDialog<bool>(
        context: context,
        builder: (context) => const BackupReminderDialog(),
      );

      if (dontShowAgain == true) {
        final settingsRepo = ref.read(settingsRepositoryProvider.notifier);
        await settingsRepo.setBackupReminderShown();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = ref.watch(homeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CustomSubs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              await HapticUtils.light();
              if (context.mounted) {
                context.push(AppRouter.settings);
              }
            },
          ),
        ],
      ),
      body: controller.when(
        data: (subscriptions) {
          if (subscriptions.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.inbox_outlined,
              title: 'No subscriptions yet',
              subtitle:
                  'Tap + to add your first one. We\'ll remind you before every charge.',
              buttonText: 'Add Subscription',
              onButtonPressed: () async {
                await HapticUtils.medium();
                if (!mounted) return;
                // ignore: use_build_context_synchronously
                context.push(AppRouter.addSubscription);
              },
            );
          }

          final homeController = ref.read(homeControllerProvider.notifier);
          final upcoming = homeController.getUpcomingSubscriptions();
          final primaryCurrency = homeController.getPrimaryCurrency();
          final monthlyTotal = homeController.calculateMonthlyTotal();
          final activeCount = homeController.getActiveCount();
          final pausedCount = homeController.getPausedCount();
          final pausedSubscriptions = homeController.getPausedSubscriptions();
          final trialsEndingSoon = homeController.getTrialsEndingSoon();

          return RefreshIndicator(
            onRefresh: () async {
              await HapticUtils.heavy(); // Pull-to-refresh completion
              await _advanceOverdueDatesIfNeeded();
              await homeController.refresh();
            },
            child: CustomScrollView(
              slivers: [
                // Spending Summary Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.base),
                    child: _SpendingSummaryCard(
                      monthlyTotal: monthlyTotal,
                      activeCount: activeCount,
                      pausedCount: pausedCount,
                      currency: primaryCurrency,
                    ),
                  ),
                ),

                // Quick Actions
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.base,
                      vertical: AppSizes.sm,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await HapticUtils.medium();
                              if (context.mounted) {
                                context.push(AppRouter.addSubscription);
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add New'),
                          ),
                        ),
                        const SizedBox(width: AppSizes.base),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await HapticUtils.medium();
                              if (context.mounted) {
                                context.push(AppRouter.analytics);
                              }
                            },
                            icon: const Icon(Icons.analytics_outlined),
                            label: const Text('Analytics'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Trials Ending Soon (if any)
                if (trialsEndingSoon.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.base),
                      child: Card(
                        color: AppColors.trial.withValues(alpha: 0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.base),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: AppColors.trial,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppSizes.sm),
                                  Text(
                                    'Trials Ending Soon',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: AppColors.trial,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSizes.sm),
                              ...trialsEndingSoon.map(
                                (sub) => Padding(
                                  padding: const EdgeInsets.only(top: AppSizes.xs),
                                  child: Text(
                                    '${sub.name} trial ends ${sub.trialEndDate!.toShortRelativeString()}',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // Upcoming Charges Section Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.base,
                      AppSizes.sectionSpacing,
                      AppSizes.base,
                      AppSizes.sm,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Upcoming',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Text(
                          'next 30 days',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),

                // Upcoming Subscriptions List with staggered fade-in
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final subscription = upcoming[index];

                      // Initialize animations on first build
                      if (_tileAnimations == null || _tileAnimations!.length != upcoming.length) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            _initializeListAnimations(upcoming.length);
                          }
                        });
                      }

                      final tile = _SubscriptionTile(
                        subscription: subscription,
                        onTap: () {
                          context.push('${AppRouter.subscriptionDetail}/${subscription.id}');
                        },
                        onMarkPaid: () {
                          homeController.markAsPaid(
                            subscription.id,
                            !subscription.isPaid,
                          );
                        },
                        onDelete: () {
                          _showDeleteDialog(context, subscription, homeController);
                        },
                      );

                      // Wrap in FadeTransition if animations ready
                      if (_tileAnimations != null && index < _tileAnimations!.length) {
                        return FadeTransition(
                          opacity: _tileAnimations![index],
                          child: tile,
                        );
                      }

                      return tile;
                    },
                    childCount: upcoming.length,
                  ),
                ),

                // Paused Subscriptions Section (only show if there are paused subs)
                if (pausedSubscriptions.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.base,
                        AppSizes.sectionSpacing,
                        AppSizes.base,
                        AppSizes.sm,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.pause_circle_outline, size: 20, color: AppColors.textSecondary),
                          const SizedBox(width: AppSizes.sm),
                          Text(
                            'Paused',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Text(
                            '$pausedCount paused',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Paused subscription tiles
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final subscription = pausedSubscriptions[index];
                        return _PausedSubscriptionTile(
                          subscription: subscription,
                          onTap: () {
                            context.push('${AppRouter.subscriptionDetail}/${subscription.id}');
                          },
                          onResume: () {
                            homeController.resumeSubscription(subscription.id);
                          },
                        );
                      },
                      childCount: pausedSubscriptions.length,
                    ),
                  ),
                ],

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSizes.xxxl),
                ),
              ],
            ),
          );
        },
        loading: () => CustomScrollView(
          slivers: [
            // Skeleton spending summary
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.base),
                child: SkeletonBox(width: double.infinity, height: 120, borderRadius: AppSizes.radiusLg),
              ),
            ),

            // Skeleton quick actions
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.base, vertical: AppSizes.sm),
                child: Row(
                  children: [
                    Expanded(child: SkeletonBox(height: 48)),
                    SizedBox(width: AppSizes.base),
                    Expanded(child: SkeletonBox(height: 48)),
                  ],
                ),
              ),
            ),

            // Skeleton subscription tiles (4 tiles)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => const SkeletonSubscriptionTile(),
                childCount: 4,
              ),
            ),
          ],
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    subscription,
    homeController,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subscription'),
        content: Text(
          'This will remove ${subscription.name} and cancel all reminders. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              homeController.deleteSubscription(subscription.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SpendingSummaryCard extends StatefulWidget {
  final double monthlyTotal;
  final int activeCount;
  final int pausedCount;
  final String currency;

  const _SpendingSummaryCard({
    required this.monthlyTotal,
    required this.activeCount,
    required this.pausedCount,
    required this.currency,
  });

  @override
  State<_SpendingSummaryCard> createState() => _SpendingSummaryCardState();
}

class _SpendingSummaryCardState extends State<_SpendingSummaryCard> {
  double _displayValue = 0.0;

  @override
  void initState() {
    super.initState();
    _displayValue = 0.0; // Start from 0 for initial animation
  }

  @override
  void didUpdateWidget(_SpendingSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if value actually changed (prevents re-animation on rebuild)
    if (oldWidget.monthlyTotal != widget.monthlyTotal) {
      _displayValue = oldWidget.monthlyTotal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: _displayValue, end: widget.monthlyTotal),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, child) {
              return Text(
                CurrencyUtils.formatAmount(animatedValue, widget.currency),
                style: theme.textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              );
            },
          ),
          Text(
            '/month',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Consumer(
            builder: (context, ref, child) {
              final isPremiumAsync = ref.watch(isPremiumProvider);
              final isPremium = isPremiumAsync.value ?? false;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.pausedCount > 0
                        ? '${widget.activeCount} active • ${widget.pausedCount} paused'
                        : '${widget.activeCount} active subscription${widget.activeCount == 1 ? '' : 's'}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  if (isPremium) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.workspace_premium,
                            size: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Premium',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SubscriptionTile extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback onTap;
  final VoidCallback onMarkPaid;
  final VoidCallback onDelete;

  const _SubscriptionTile({
    required this.subscription,
    required this.onTap,
    required this.onMarkPaid,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = material.Color(subscription.colorValue);

    return Dismissible(
      key: Key(subscription.id),
      background: Container(
        color: AppColors.success,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: AppSizes.xl),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSizes.xl),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await HapticUtils.medium(); // Mark as paid feedback
          onMarkPaid();
          return false;
        } else {
          return true;
        }
      },
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          await HapticUtils.heavy(); // Destructive action
          onDelete();
        }
      },
      child: SubtlePressable(
        onPressed: () async {
          await HapticUtils.light(); // Navigation feedback
          onTap();
        },
        scale: 0.99, // Extra subtle 1% scale for cards
        child: Card(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSizes.base,
            vertical: AppSizes.xs,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Row(
              children: [
                // Color indicator + Icon with Hero animation
                Hero(
                  tag: 'subscription-icon-${subscription.id}',
                  child: Container(
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
                      child: ServiceIcons.hasCustomIcon(subscription.name)
                          ? Icon(
                              ServiceIcons.getIconForService(subscription.name),
                              color: color,
                              size: 26,
                            )
                          : Text(
                              subscription.name[0].toUpperCase(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
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
                      Text(
                        subscription.name,
                        style: theme.textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Row(
                        children: [
                          Text(
                            CurrencyUtils.formatAmount(
                              subscription.amount,
                              subscription.currencyCode,
                            ),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '/${subscription.cycle.shortName}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Billing info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      subscription.nextBillingDate.toShortRelativeString(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: subscription.isOverdue
                            ? AppColors.error
                            : subscription.daysUntilBilling <= 1
                                ? AppColors.warning
                                : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subscription.daysUntilBilling > 1 && !subscription.isOverdue)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subscription.nextBillingDate.toShortFormattedString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    if (subscription.isPaid)
                      AnimatedOpacity(
                        opacity: subscription.isPaid ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        child: Container(
                          margin: const EdgeInsets.only(top: AppSizes.xs),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.sm,
                            vertical: AppSizes.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                          ),
                          child: Text(
                            'Paid',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (subscription.isTrial)
                      Container(
                        margin: const EdgeInsets.only(top: AppSizes.xs),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.sm,
                          vertical: AppSizes.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.trial.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        ),
                        child: Text(
                          'Trial',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.trial,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PausedSubscriptionTile extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback onTap;
  final VoidCallback onResume;

  const _PausedSubscriptionTile({
    required this.subscription,
    required this.onTap,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = material.Color(subscription.colorValue);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.base,
        vertical: AppSizes.xs,
      ),
      child: Dismissible(
        key: Key('pause-${subscription.id}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          await HapticUtils.medium();
          onResume();
          return false; // Don't actually dismiss, just trigger resume
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSizes.base),
          decoration: BoxDecoration(
            color: AppColors.success,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          child: const Icon(Icons.play_arrow, color: Colors.white),
        ),
        child: SubtlePressable(
          onPressed: () async {
            await HapticUtils.light();
            onTap();
          },
          scale: 0.99,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Row(
                children: [
                  // Desaturated icon
                  Opacity(
                    opacity: 0.5,
                    child: Container(
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
                      ),
                      child: Center(
                        child: ServiceIcons.hasCustomIcon(subscription.name)
                            ? Icon(
                                ServiceIcons.getIconForService(subscription.name),
                                color: color,
                                size: 26,
                              )
                            : Text(
                                subscription.name[0].toUpperCase(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.base),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subscription.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.textSecondary, // Muted
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getPauseStatusText(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Amount (muted)
                  Text(
                    CurrencyUtils.formatAmount(
                      subscription.amount,
                      subscription.currencyCode,
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getPauseStatusText() {
    if (subscription.resumeDate != null) {
      final daysUntil = subscription.resumeDate!.difference(DateTime.now()).inDays;
      if (daysUntil <= 0) {
        return 'Resumes today';
      } else if (daysUntil == 1) {
        return 'Resumes tomorrow';
      } else {
        return 'Resumes in $daysUntil days';
      }
    }

    return 'Paused ${subscription.daysPaused} days ago';
  }
}
