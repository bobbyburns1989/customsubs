import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:custom_subs/core/extensions/theme_extensions.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/core/utils/currency_utils.dart';
import 'package:custom_subs/core/providers/entitlement_provider.dart';
import 'package:custom_subs/core/utils/haptic_utils.dart';
import 'package:custom_subs/data/models/subscription.dart';
import 'package:custom_subs/core/widgets/subscription_icon.dart';
import 'package:custom_subs/core/extensions/date_extensions.dart';
import 'package:custom_subs/core/providers/settings_provider.dart';
import 'package:custom_subs/core/widgets/subtle_pressable.dart';
import 'package:custom_subs/core/widgets/skeleton_widgets.dart';
import 'package:custom_subs/core/widgets/empty_state_widget.dart';
import 'package:custom_subs/features/home/home_controller.dart';
import 'package:custom_subs/core/utils/snackbar_utils.dart';
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
      // Refresh premium status — trial may have expired while backgrounded.
      // Lightweight: RevenueCat reads from its local cache, not the network.
      ref.invalidate(isPremiumProvider);
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
          // Pass days: 31 so subscriptions billing exactly 30 days from now
          // are included in Upcoming rather than falling into Later.
          // (The exclusive upper bound means days=30 would exclude day 30.)
          final upcoming = homeController.getUpcomingSubscriptions(days: 31);
          final unpaidUpcoming = upcoming.where((s) => !s.isPaid).toList();
          final paidUpcoming = upcoming.where((s) => s.isPaid).toList();
          final laterSubscriptions = homeController.getLaterSubscriptions();
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
                      paidUpcomingCount: paidUpcoming.length,
                      upcomingCount: upcoming.length,
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
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.md,
                                vertical: AppSizes.md,
                              ),
                              textStyle: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () async {
                              await HapticUtils.medium();
                              if (context.mounted) {
                                context.push(AppRouter.addSubscription);
                              }
                            },
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text('Add New', maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.md,
                                vertical: AppSizes.md,
                              ),
                              textStyle: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () async {
                              await HapticUtils.medium();
                              if (context.mounted) {
                                context.push(AppRouter.calendar);
                              }
                            },
                            icon: const Icon(Icons.calendar_month_outlined, size: 20),
                            label: const Text('Calendar', maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.md,
                                vertical: AppSizes.md,
                              ),
                              textStyle: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () async {
                              await HapticUtils.medium();
                              if (context.mounted) {
                                context.push(AppRouter.analytics);
                              }
                            },
                            icon: const Icon(Icons.analytics_outlined, size: 20),
                            label: const Text('Analytics', maxLines: 1, overflow: TextOverflow.ellipsis),
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
                        color: context.colors.trial.withValues(alpha: 0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.base),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: context.colors.trial,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppSizes.sm),
                                  Text(
                                    'Trials Ending Soon',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: context.colors.trial,
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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                        // Show paid progress when any are paid, otherwise default label
                        Flexible(
                          child: Text(
                            paidUpcoming.isNotEmpty
                                ? '${paidUpcoming.length} of ${upcoming.length} paid'
                                : 'next 30 days',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: paidUpcoming.isNotEmpty
                                  ? context.colors.success
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Upcoming Subscriptions List with paid divider
                // Layout: [unpaid tiles] → [paid divider] → [paid tiles]
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Only show divider when there are both unpaid AND paid subs
                      final hasDivider = paidUpcoming.isNotEmpty && unpaidUpcoming.isNotEmpty;
                      final dividerIndex = unpaidUpcoming.length;

                      // Initialize animations on first build
                      if (_tileAnimations == null || _tileAnimations!.length != upcoming.length) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            _initializeListAnimations(upcoming.length);
                          }
                        });
                      }

                      // Divider between unpaid and paid groups
                      if (hasDivider && index == dividerIndex) {
                        return _PaidDivider(
                          paidCount: paidUpcoming.length,
                          totalCount: upcoming.length,
                        );
                      }

                      // Resolve actual subscription from the combined list
                      final subIndex = (hasDivider && index > dividerIndex)
                          ? index - 1  // offset past divider
                          : index;
                      final subscription = upcoming[subIndex];

                      final tile = _SubscriptionTile(
                        subscription: subscription,
                        onTap: () {
                          context.push('${AppRouter.subscriptionDetail}/${subscription.id}');
                        },
                        onMarkPaid: () {
                          final newPaidState = !subscription.isPaid;
                          homeController.markAsPaid(
                            subscription.id,
                            newPaidState,
                          );
                          // Show undo snackbar only when marking AS paid
                          if (newPaidState) {
                            SnackBarUtils.show(
                              context,
                              SnackBarUtils.success(
                                '${subscription.name} marked as paid',
                                onUndo: () {
                                  homeController.markAsPaid(subscription.id, false);
                                },
                              ),
                            );
                          }
                        },
                        onDelete: () {
                          _showDeleteDialog(context, subscription, homeController);
                        },
                      );

                      // Wrap in FadeTransition if animations ready
                      if (_tileAnimations != null && subIndex < _tileAnimations!.length) {
                        return FadeTransition(
                          opacity: _tileAnimations![subIndex],
                          child: tile,
                        );
                      }

                      return tile;
                    },
                    // +1 for the divider widget when both unpaid and paid subs exist
                    childCount: upcoming.length + (paidUpcoming.isNotEmpty && unpaidUpcoming.isNotEmpty ? 1 : 0),
                  ),
                ),

                // Later Subscriptions Section (billing 30–90 days out)
                // Ensures no active subscription is ever invisible on Home.
                if (laterSubscriptions.isNotEmpty) ...[
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
                            'Later',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Text(
                            '31–90 days',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final sub = laterSubscriptions[index];
                        return _LaterSubscriptionTile(
                          subscription: sub,
                          onTap: () => context.push(
                            '${AppRouter.subscriptionDetail}/${sub.id}',
                          ),
                        );
                      },
                      childCount: laterSubscriptions.length,
                    ),
                  ),
                ],

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
                          Icon(Icons.pause_circle_outline, size: 20, color: context.colors.textSecondary),
                          const SizedBox(width: AppSizes.sm),
                          Text(
                            'Paused',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Text(
                            '$pausedCount paused',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: context.colors.textSecondary,
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
                    SizedBox(width: AppSizes.sm),
                    Expanded(child: SkeletonBox(height: 48)),
                    SizedBox(width: AppSizes.sm),
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
            style: TextButton.styleFrom(foregroundColor: context.colors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Spending period toggle — Monthly → Yearly → Daily (cycles on tap)
enum _SpendingPeriod { monthly, yearly, daily }

class _SpendingSummaryCard extends StatefulWidget {
  final double monthlyTotal;
  final int activeCount;
  final int pausedCount;
  final String currency;
  final int paidUpcomingCount;
  final int upcomingCount;

  const _SpendingSummaryCard({
    required this.monthlyTotal,
    required this.activeCount,
    required this.pausedCount,
    required this.currency,
    required this.paidUpcomingCount,
    required this.upcomingCount,
  });

  @override
  State<_SpendingSummaryCard> createState() => _SpendingSummaryCardState();
}

class _SpendingSummaryCardState extends State<_SpendingSummaryCard> {
  _SpendingPeriod _period = _SpendingPeriod.monthly;

  // Tracks where the tween animation should start from.
  // On init: 0 (count-up from zero).
  // On monthlyTotal change: old period-adjusted value (smooth transition).
  // On period change: old period's value (so number morphs naturally).
  double _tweenBegin = 0.0;

  // Amount to display for the current period, derived from monthlyTotal.
  double get _targetAmount => _amountForPeriod(widget.monthlyTotal, _period);

  // Period label shown below the amount.
  String get _periodLabel {
    switch (_period) {
      case _SpendingPeriod.monthly:
        return '/month';
      case _SpendingPeriod.yearly:
        return '/year';
      case _SpendingPeriod.daily:
        return '/day';
    }
  }

  // Convert a monthly total to the given period's equivalent.
  double _amountForPeriod(double monthly, _SpendingPeriod period) {
    switch (period) {
      case _SpendingPeriod.monthly:
        return monthly;
      case _SpendingPeriod.yearly:
        return monthly * 12;
      case _SpendingPeriod.daily:
        // Same formula used in analytics_screen.dart
        return monthly * 12 / 365;
    }
  }

  // Cycle to the next period and animate from the current displayed amount.
  void _cyclePeriod() {
    setState(() {
      // Capture current target before changing period so tween starts from here.
      _tweenBegin = _targetAmount;
      _period = _SpendingPeriod.values[
        (_period.index + 1) % _SpendingPeriod.values.length
      ];
    });
  }

  @override
  void didUpdateWidget(_SpendingSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the parent pushes a new monthlyTotal, animate from the old
    // period-adjusted value to prevent a jarring jump.
    if (oldWidget.monthlyTotal != widget.monthlyTotal) {
      _tweenBegin = _amountForPeriod(oldWidget.monthlyTotal, _period);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _cyclePeriod,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: context.colors.primary.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated amount — TweenAnimationBuilder handles smooth
            // transitions both on period toggle and on monthlyTotal updates.
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: _tweenBegin, end: _targetAmount),
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

            // Period label — crossfades on period change.
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _periodLabel,
                // Key forces AnimatedSwitcher to treat each period as a
                // different widget, triggering the crossfade animation.
                key: ValueKey(_period),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.sm),

            // Dot page indicator — hints that the card is tappable.
            // Active dot is wider; inactive dots are small and dim.
            Row(
              mainAxisSize: MainAxisSize.min,
              children: _SpendingPeriod.values.map((p) {
                final isActive = p == _period;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: isActive ? 14 : 6,
                  height: 4,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: isActive ? 0.85 : 0.30,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: AppSizes.sm),

            // Subscription count + optional premium badge
            Consumer(
              builder: (context, ref, child) {
                final isPremiumAsync = ref.watch(isPremiumProvider);
                final isPremium = isPremiumAsync.value ?? false;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        widget.pausedCount > 0
                            ? '${widget.activeCount} active • ${widget.pausedCount} paused'
                            : '${widget.activeCount} active subscription${widget.activeCount == 1 ? '' : 's'}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

            // Paid cycle progress — only shown when at least one upcoming sub is paid
            if (widget.paidUpcomingCount > 0 && widget.upcomingCount > 0) ...[
              const SizedBox(height: AppSizes.xs),
              Text(
                '${widget.paidUpcomingCount} of ${widget.upcomingCount} paid this cycle',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
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
      // Change 5: Swipe indicator — green/check when unpaid, amber/undo when paid
      background: Container(
        color: subscription.isPaid ? context.colors.warning : context.colors.success,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: AppSizes.xl),
        child: Icon(
          subscription.isPaid ? Icons.undo : Icons.check,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(
        color: context.colors.error,
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
        child: AnimatedOpacity(
          opacity: subscription.isPaid ? 0.55 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: Card(
            margin: const EdgeInsets.symmetric(
              horizontal: AppSizes.base,
              vertical: AppSizes.xs,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Row(
              children: [
                // Brand icon with Hero animation for shared element transition
                Hero(
                  tag: 'subscription-icon-${subscription.id}',
                  child: SubscriptionIcon(
                    name: subscription.name,
                    iconName: subscription.iconName,
                    color: color,
                    size: 48,
                    isCircle: true,
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
                        // Mute urgency coloring when already paid
                        color: subscription.isPaid
                            ? context.colors.textTertiary
                            : subscription.isOverdue
                                ? context.colors.error
                                : subscription.daysUntilBilling <= 1
                                    ? context.colors.warning
                                    : context.colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subscription.daysUntilBilling > 1 && !subscription.isOverdue)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subscription.nextBillingDate.toShortFormattedString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: context.colors.textTertiary,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                            color: context.colors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                          ),
                          child: Text(
                            'Paid',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: context.colors.success,
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
                          color: context.colors.trial.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        ),
                        child: Text(
                          'Trial',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: context.colors.trial,
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
      ),
    );
  }
}

/// Divider between unpaid and paid subscriptions in the Upcoming section.
/// Shows a thin line with "Paid · 3 of 8" label in muted green.
class _PaidDivider extends StatelessWidget {
  final int paidCount;
  final int totalCount;

  const _PaidDivider({
    required this.paidCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.base,
        vertical: AppSizes.md,
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 14,
            color: context.colors.success.withValues(alpha: 0.5),
          ),
          const SizedBox(width: AppSizes.xs),
          Text(
            'Paid · $paidCount of $totalCount',
            style: theme.textTheme.bodySmall?.copyWith(
              color: context.colors.success.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Divider(
              color: context.colors.success.withValues(alpha: 0.2),
              thickness: 1,
            ),
          ),
        ],
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
            color: context.colors.success,
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
                  // Desaturated brand icon (paused state — 50% opacity)
                  Opacity(
                    opacity: 0.5,
                    child: SubscriptionIcon(
                      name: subscription.name,
                      iconName: subscription.iconName,
                      color: color,
                      size: 48,
                      isCircle: true,
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
                            color: context.colors.textSecondary, // Muted
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getPauseStatusText(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: context.colors.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                      color: context.colors.textSecondary,
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

/// Tile for subscriptions billing 30–90 days out ("Later" section).
///
/// Deliberately simpler than [_SubscriptionTile]:
/// - No swipe actions (no urgency — just awareness)
/// - Muted text colour to stay visually subordinate to "Upcoming"
/// - Shows absolute date (e.g. "Apr 17") not relative ("in 45 days")
class _LaterSubscriptionTile extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback onTap;

  const _LaterSubscriptionTile({
    required this.subscription,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = material.Color(subscription.colorValue);

    return SubtlePressable(
      onPressed: () async {
        await HapticUtils.light();
        onTap();
      },
      scale: 0.99,
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSizes.base,
          vertical: AppSizes.xs,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Row(
            children: [
              // Brand icon / avatar — slightly muted for "later" section
              Opacity(
                opacity: 0.75,
                child: SubscriptionIcon(
                  name: subscription.name,
                  iconName: subscription.iconName,
                  color: color,
                  size: 40,
                  isCircle: true,
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
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: context.colors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      '${CurrencyUtils.formatAmount(subscription.amount, subscription.currencyCode)}/${subscription.cycle.shortName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),

              // Absolute date (e.g. "Apr 17")
              Text(
                DateFormat.MMMd().format(subscription.nextBillingDate),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
