import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/core/extensions/date_extensions.dart';
import 'package:custom_subs/core/extensions/theme_extensions.dart';
import 'package:custom_subs/core/utils/haptic_utils.dart';
import 'package:custom_subs/core/widgets/subscription_icon.dart';
import 'package:custom_subs/core/widgets/subtle_pressable.dart';
import 'package:custom_subs/data/models/subscription.dart';

/// Displays the list of subscriptions billing on a selected calendar day.
///
/// Shows a header with the date and daily total, followed by tappable
/// subscription tiles that navigate to the detail screen.
/// Shows a muted message when no subscriptions bill on the selected date.
class DayDetailList extends StatelessWidget {
  final DateTime day;
  final List<Subscription> subscriptions;
  final String primaryCurrency;
  final double dayTotal;

  const DayDetailList({
    super.key,
    required this.day,
    required this.subscriptions,
    required this.primaryCurrency,
    required this.dayTotal,
  });

  @override
  Widget build(BuildContext context) {
    if (subscriptions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSizes.xxl),
        child: Center(
          child: Text(
            'No bills on this date',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: context.colors.textTertiary,
                ),
          ),
        ),
      );
    }

    final currencyFormat = NumberFormat.simpleCurrency(name: primaryCurrency);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header: date label + daily total
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.base),
          child: Row(
            children: [
              Text(
                day.toShortFormattedString(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              if (subscriptions.length > 1)
                Text(
                  currencyFormat.format(dayTotal),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFamily: 'DM Mono',
                        color: context.colors.textSecondary,
                      ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.sm),

        // Subscription tiles
        ...subscriptions.map((sub) => _DayDetailTile(
              subscription: sub,
              primaryCurrency: primaryCurrency,
            )),
      ],
    );
  }
}

/// A simplified subscription tile for the calendar day detail view.
///
/// Shows brand icon, name, amount/cycle, and navigates to the detail
/// screen on tap. No swipe actions — this is a read-only view.
class _DayDetailTile extends StatelessWidget {
  final Subscription subscription;
  final String primaryCurrency;

  const _DayDetailTile({
    required this.subscription,
    required this.primaryCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.simpleCurrency(name: subscription.currencyCode);

    return SubtlePressable(
      onPressed: () async {
        await HapticUtils.light();
        if (context.mounted) {
          context.push('/subscription/${subscription.id}');
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSizes.base,
          vertical: AppSizes.xs,
        ),
        padding: const EdgeInsets.all(AppSizes.base),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: context.colors.border, width: 1),
        ),
        child: Row(
          children: [
            // Brand icon
            SubscriptionIcon(
              name: subscription.name,
              iconName: subscription.iconName,
              color: Color(subscription.colorValue),
              size: 40,
              isCircle: true,
            ),
            const SizedBox(width: AppSizes.md),

            // Name + amount
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subscription.name,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${currencyFormat.format(subscription.amount)}/${subscription.cycle.shortName}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            // Cycle label
            Text(
              subscription.cycle.displayName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.colors.textTertiary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
