import 'package:flutter/material.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/core/utils/currency_utils.dart';
import 'package:custom_subs/core/utils/service_icons.dart';
import 'package:custom_subs/data/models/subscription.dart';
import 'package:custom_subs/features/subscription_detail/widgets/status_badge.dart';

/// Header card displaying subscription icon, name, amount, and status badges.
///
/// The visual "hero" of the detail screen - shows the subscription's identity
/// and current state at a glance. Includes Hero animation support for smooth
/// transitions from the home screen.
///
/// ## Visual Hierarchy
///
/// ```
/// ┌─────────────────────────────┐
/// │      [Icon with Hero]        │
/// │      Subscription Name       │
/// │      $15.99/month           │
/// │    [Trial] [Paid] badges    │
/// └─────────────────────────────┘
/// ```
///
/// ## Usage
///
/// ```dart
/// final subscriptionColor = Color(subscription.colorValue);
///
/// HeaderCard(
///   subscription: subscription,
///   subscriptionColor: subscriptionColor,
/// )
/// ```
///
/// ## Hero Animation
///
/// The icon container is wrapped in a Hero widget with tag:
/// `'subscription-icon-\${subscription.id}'`
///
/// This enables smooth shared element transition from home screen tiles
/// to detail screen when user taps a subscription.
///
/// ## Icon Logic
///
/// - **Template subscriptions:** Shows icon from ServiceIcons (e.g., Netflix logo)
/// - **Custom subscriptions:** Shows first letter of name in colored circle
/// - Background: 15% opacity of subscription color with rounded corners
///
/// ## Status Badges
///
/// Displays up to 2 badges:
/// - **Trial badge:** Yellow/amber - shown when `subscription.isTrial` is true
/// - **Paid badge:** Green - animated fade in/out based on `subscription.isPaid`
///
/// The Paid badge uses AnimatedOpacity (250ms) for smooth state transitions.
///
/// ## Animations
///
/// - Hero transition from home screen (native Flutter Hero)
/// - Paid badge fade in/out (250ms, Curves.easeOut)
///
/// See: docs/design/MICRO_ANIMATIONS.md (#3 Badge Fade In/Out)
class HeaderCard extends StatelessWidget {
  /// The subscription to display
  final Subscription subscription;

  /// The color for icon background and text
  final Color subscriptionColor;

  const HeaderCard({
    super.key,
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
            // Icon with Hero animation
            Hero(
              tag: 'subscription-icon-${subscription.id}',
              child: Container(
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
                // Trial badge
                if (subscription.isTrial)
                  const StatusBadge(
                    label: 'Trial',
                    color: AppColors.trial,
                  ),

                // Paid badge with fade animation
                AnimatedOpacity(
                  opacity: subscription.isPaid ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  child: const StatusBadge(
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
