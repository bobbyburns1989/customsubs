/// Paywall screen for upgrading to Premium subscription.
///
/// Displays pricing, features, and purchase CTA.
/// Integrates with RevenueCat for subscription purchase flow.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For PlatformException
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/core/constants/revenue_cat_constants.dart';
import 'package:custom_subs/core/providers/entitlement_provider.dart';
import 'package:custom_subs/core/utils/haptic_utils.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isPurchasing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade to Premium'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () async {
            await HapticUtils.light();
            if (context.mounted) {
              context.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Premium icon
              const Icon(
                Icons.workspace_premium,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSizes.xl),

              // Title
              const Text(
                'Unlock Unlimited Subscriptions',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.base),

              // Subtitle - Trial-first messaging
              const Column(
                children: [
                  Text(
                    'Try Premium Free for 3 Days',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Then just \$0.99/month • Cancel anytime',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.xxxl),

              // Features list
              _buildFeatureItem(
                icon: Icons.add_circle_outline,
                title: 'Unlimited Subscriptions',
                subtitle: 'Track as many subscriptions as you need',
              ),
              const SizedBox(height: AppSizes.lg),

              _buildFeatureItem(
                icon: Icons.notifications_active,
                title: 'All Notification Features',
                subtitle: '7-day, 1-day, and day-of reminders',
              ),
              const SizedBox(height: AppSizes.lg),

              _buildFeatureItem(
                icon: Icons.analytics,
                title: 'Advanced Analytics',
                subtitle: 'Detailed spending insights and charts',
              ),
              const SizedBox(height: AppSizes.lg),

              _buildFeatureItem(
                icon: Icons.backup,
                title: 'Automatic Backups',
                subtitle: 'Never lose your subscription data',
              ),
              const SizedBox(height: AppSizes.xxxl),

              // Trial highlight
              Container(
                padding: const EdgeInsets.all(AppSizes.base),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.primary),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.timer_outlined, color: AppColors.primary),
                    SizedBox(width: AppSizes.base),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '3-Day Free Trial',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Try all premium features risk-free. Cancel before day 3 and pay nothing.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // Current limitation
              Container(
                padding: const EdgeInsets.all(AppSizes.base),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.warning),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.warning),
                    SizedBox(width: AppSizes.base),
                    Expanded(
                      child: Text(
                        'Free tier limited to ${RevenueCatConstants.maxFreeSubscriptions} subscriptions',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.xxxl),

              // Subscribe button
              FilledButton(
                onPressed: _isPurchasing ? null : _handlePurchase,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
                child: _isPurchasing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Start 3-Day Free Trial',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: AppSizes.sm),

              // Trial terms
              const Text(
                'Free for 3 days, then \$0.99/month. Renews monthly. Cancel anytime.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.base),

              // Restore purchases
              TextButton(
                onPressed: _isPurchasing ? null : _handleRestore,
                child: const Text('Restore Purchases'),
              ),
              const SizedBox(height: AppSizes.base),

              // Fine print
              const Text(
                'Subscription managed through App Store. Cancel anytime in settings.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: AppSizes.base),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handlePurchase() async {
    setState(() => _isPurchasing = true);
    await HapticUtils.medium();

    try {
      final service = ref.read(entitlementServiceProvider);
      final success = await service.purchaseMonthlySubscription();

      if (!mounted) return;

      if (success) {
        // Invalidate premium provider to refresh state
        ref.invalidate(isPremiumProvider);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Premium activated! Enjoy unlimited subscriptions.'),
            backgroundColor: AppColors.success,
          ),
        );

        // Close paywall
        context.pop();
      } else {
        // DEBUG: Show detailed failure reason from EntitlementService
        final errorMsg = service.lastErrorMessage ?? 'Unknown error';
        final errorDetails = service.lastErrorDetails;

        String detailsText = 'The purchase did not complete successfully.\n\n';

        if (errorDetails != null) {
          if (errorDetails['error'] == 'NO_OFFERING') {
            detailsText += '❌ Error: No RevenueCat offering found\n\n';
            detailsText += 'Fix: ${errorDetails['suggestion']}\n\n';
            detailsText += 'Total Offerings: ${errorDetails['totalOfferings']}';
          } else if (errorDetails['error'] == 'PACKAGE_NOT_FOUND') {
            detailsText += '❌ Error: Product not found\n\n';
            detailsText += 'Expected: ${errorDetails['expected']}\n\n';
            final available = errorDetails['available'] as List;
            if (available.isEmpty) {
              detailsText += 'Available: NONE\n\n';
            } else {
              detailsText += 'Available:\n';
              for (final product in available) {
                detailsText += '  • $product\n';
              }
            }
            detailsText += '\n${errorDetails['suggestion']}';
          } else if (errorDetails['error'] == 'PLATFORM_EXCEPTION') {
            detailsText += '❌ Error: ${errorDetails['message']}\n\n';
            detailsText += 'Error Code: ${errorDetails['errorCode']}\n\n';
            if (errorDetails['details'] != 'No details') {
              detailsText += 'Details: ${errorDetails['details']}\n\n';
            }
            detailsText += 'Fix: ${errorDetails['suggestion']}';
          } else if (errorDetails['error'] == 'UNEXPECTED_ERROR') {
            detailsText += '❌ Unexpected Error\n\n';
            detailsText += 'Type: ${errorDetails['errorType']}\n\n';
            detailsText += 'Message: ${errorDetails['message']}\n\n';
            detailsText += '${errorDetails['suggestion']}';
          } else if (errorDetails['error'] == 'NO_ENTITLEMENT') {
            detailsText += '❌ Error: Entitlement not granted\n\n';
            detailsText += 'Expected: ${errorDetails['expected']}\n\n';
            final available = errorDetails['available'] as List;
            if (available.isEmpty) {
              detailsText += 'Available Entitlements: NONE\n\n';
            } else {
              detailsText += 'Available Entitlements:\n';
              for (final ent in available) {
                detailsText += '  • $ent\n';
              }
              detailsText += '\n';
            }
            detailsText += 'Fix: ${errorDetails['suggestion']}';
          } else {
            detailsText += 'Error: $errorMsg\n\n';
            detailsText += 'Details: $errorDetails';
          }
        } else {
          detailsText += 'Error: $errorMsg\n\n';
          detailsText += 'Possible reasons:\n';
          detailsText += '• Package not found in RevenueCat\n';
          detailsText += '• Product not configured in App Store\n';
          detailsText += '• Network connection issue\n\n';
          detailsText += 'Please try again or contact support.';
        }

        // Show snackbar with Details button
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: $errorMsg'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 7),
            action: SnackBarAction(
              label: 'Details',
              textColor: Colors.white,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('❌ Purchase Failed'),
                    content: SingleChildScrollView(
                      child: Text(detailsText),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    } on PlatformException catch (e) {
      if (mounted) {
        final errorCode = PurchasesErrorHelper.getErrorCode(e);
        if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
          // User cancelled - no error message needed
          debugPrint('Purchase cancelled by user');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Purchase error: ${e.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Show detailed error in UI for TestFlight debugging
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 7),
            action: SnackBarAction(
              label: 'Copy',
              textColor: Colors.white,
              onPressed: () {
                // User can see the full error
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Error Details'),
                    content: SingleChildScrollView(
                      child: Text(
                        'Error Type: ${e.runtimeType}\n\n'
                        'Message: $e\n\n'
                        'This error has been logged. '
                        'Please screenshot this and send to support.',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isPurchasing = true);
    await HapticUtils.medium();

    try {
      final service = ref.read(entitlementServiceProvider);
      final success = await service.restorePurchases();

      if (!mounted) return;

      if (success) {
        ref.invalidate(isPremiumProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Purchases restored successfully!'),
            backgroundColor: AppColors.success,
          ),
        );

        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No purchases found to restore.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }
}
