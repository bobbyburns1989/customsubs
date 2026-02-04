import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/core/utils/currency_utils.dart';
import 'package:custom_subs/core/utils/service_icons.dart';
import 'package:custom_subs/core/extensions/date_extensions.dart';
import 'package:custom_subs/features/home/home_controller.dart';
import 'package:custom_subs/app/router.dart';
import 'package:flutter/material.dart' as material;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final controller = ref.watch(homeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CustomSubs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRouter.settings),
          ),
        ],
      ),
      body: controller.when(
        data: (subscriptions) {
          if (subscriptions.isEmpty) {
            return _EmptyState(
              onAddPressed: () => context.push(AppRouter.addSubscription),
            );
          }

          final homeController = ref.read(homeControllerProvider.notifier);
          final upcoming = homeController.getUpcomingSubscriptions();
          final monthlyTotal = homeController.calculateMonthlyTotal();
          final activeCount = homeController.getActiveCount();
          final trialsEndingSoon = homeController.getTrialsEndingSoon();

          return RefreshIndicator(
            onRefresh: () => homeController.refresh(),
            child: CustomScrollView(
              slivers: [
                // Spending Summary Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.base),
                    child: _SpendingSummaryCard(
                      monthlyTotal: monthlyTotal,
                      activeCount: activeCount,
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
                            onPressed: () => context.push(AppRouter.addSubscription),
                            icon: const Icon(Icons.add),
                            label: const Text('Add New'),
                          ),
                        ),
                        const SizedBox(width: AppSizes.base),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Navigate to analytics
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
                        color: AppColors.trial.withOpacity(0.1),
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
                      AppSizes.lg,
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

                // Upcoming Subscriptions List
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final subscription = upcoming[index];
                      return _SubscriptionTile(
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
                    },
                    childCount: upcoming.length,
                  ),
                ),

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSizes.xxxl),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
      floatingActionButton: controller.maybeWhen(
        data: (subs) => subs.isNotEmpty
            ? FloatingActionButton(
                onPressed: () => context.push(AppRouter.addSubscription),
                child: const Icon(Icons.add),
              )
            : null,
        orElse: () => null,
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

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddPressed;

  const _EmptyState({required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/CustomSubsLOGO.png',
              width: 250,
              height: 100,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: AppSizes.xxxl),
            Text(
              'No subscriptions yet',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.base),
            Text(
              'Tap + to add your first one. We\'ll remind you before every charge.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.xxl),
            ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: const Text('Add Subscription'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpendingSummaryCard extends StatelessWidget {
  final double monthlyTotal;
  final int activeCount;

  const _SpendingSummaryCard({
    required this.monthlyTotal,
    required this.activeCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            CurrencyUtils.formatAmount(monthlyTotal, 'USD'),
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '/month',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            '$activeCount active subscription${activeCount == 1 ? '' : 's'}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionTile extends StatelessWidget {
  final subscription;
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
          onMarkPaid();
          return false;
        } else {
          return true;
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete();
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSizes.base,
          vertical: AppSizes.xs,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.base),
            child: Row(
              children: [
                // Color indicator + Icon
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.2),
                  child: ServiceIcons.hasCustomIcon(subscription.name)
                      ? Icon(
                          ServiceIcons.getIconForService(subscription.name),
                          color: color,
                          size: 24,
                        )
                      : Text(
                          subscription.name[0].toUpperCase(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(width: AppSizes.base),

                // Name and amount
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              subscription.name,
                              style: theme.textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (subscription.isPaid)
                            Container(
                              margin: const EdgeInsets.only(left: AppSizes.sm),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.sm,
                                vertical: AppSizes.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
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
                        ],
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
                                : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
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
                          color: AppColors.trial.withOpacity(0.1),
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
