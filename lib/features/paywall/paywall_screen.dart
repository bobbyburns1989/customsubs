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
import 'package:url_launcher/url_launcher.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isPurchasing = false;
  bool _isLoadingOffering = true;
  Offering? _cachedOffering;
  String? _offeringError;
  Package? _monthlyPackage; // Cache the monthly package for price/trial display

  @override
  void initState() {
    super.initState();
    // Pre-load offerings to prevent timeout during purchase
    _preloadOffering();
  }

  /// Detect if device is a tablet (iPad or large Android tablet)
  bool _isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 600; // Standard tablet threshold
  }

  /// Pre-fetch offering to avoid sandbox timeout when user taps Subscribe.
  /// This gives StoreKit daemon time to connect before purchase attempt.
  Future<void> _preloadOffering() async {
    setState(() {
      _isLoadingOffering = true;
      _offeringError = null;
      _monthlyPackage = null;
    });

    try {
      final service = ref.read(entitlementServiceProvider);
      final offerings = await service.getOfferingsWithRetry();
      _cachedOffering = offerings;

      if (_cachedOffering == null) {
        _offeringError = 'No subscription available. Please try again later.';
        debugPrint('❌ PAYWALL: No offering available');
      } else {
        debugPrint('✅ PAYWALL: Offering pre-loaded successfully');
        debugPrint('   Packages: ${_cachedOffering!.availablePackages.length}');

        // Find and cache the monthly package for dynamic price/trial display
        try {
          _monthlyPackage = _cachedOffering!.availablePackages.firstWhere(
            (package) =>
                package.storeProduct.identifier == RevenueCatConstants.monthlyProductId,
          );
          debugPrint('   Monthly package found: ${_monthlyPackage!.storeProduct.priceString}');
        } catch (e) {
          // Try fallback to package type
          try {
            _monthlyPackage = _cachedOffering!.availablePackages.firstWhere(
              (package) => package.packageType == PackageType.monthly,
            );
            debugPrint('   Monthly package found by type: ${_monthlyPackage!.storeProduct.priceString}');
          } catch (e) {
            debugPrint('⚠️ Monthly package not found in offering');
            _offeringError = 'Monthly subscription not available.';
          }
        }
      }
    } catch (e) {
      _offeringError = 'Failed to load subscription: $e';
      debugPrint('❌ PAYWALL: Offering pre-load failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingOffering = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pre-compute dynamic values from StoreKit (or fallback strings for loading state)
    final priceString = _monthlyPackage?.storeProduct.priceString ?? '\$0.99';
    final hasIntro = _monthlyPackage?.storeProduct.introductoryPrice != null;
    final trialPeriod = hasIntro
        ? _monthlyPackage!.storeProduct.introductoryPrice!.period
        : '3 days';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Go Premium'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () async {
            await HapticUtils.light();
            if (context.mounted) context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // SingleChildScrollView ensures very small devices (iPhone SE) can still
          // scroll if needed, while larger iPhones see everything without scrolling.
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.lg,
            vertical: AppSizes.base,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header: icon + title + inline price ───────────────────
              const SizedBox(height: AppSizes.sm),
              const Icon(
                Icons.workspace_premium,
                size: 56, // Compact (was 80px)
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSizes.sm),
              const Text(
                'Go Premium',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.xs),

              // PRICE — prominent, Apple compliance (was a tall bordered box)
              // Shows inline with trial info on a single line for compactness.
              _isLoadingOffering
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    )
                  : Text(
                      '$priceString/month · $trialPeriod free trial',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),

              const SizedBox(height: AppSizes.xl),

              // ── Feature checkmarks ─────────────────────────────────────
              // Compact single-line rows replace the tall icon+subtitle items.
              _buildCompactFeatureRow('Unlimited subscriptions'),
              _buildCompactFeatureRow('All reminders — 7-day, 1-day, day-of'),
              _buildCompactFeatureRow('Spending analytics & yearly forecast'),
              _buildCompactFeatureRow('Backup & restore your data'),

              const SizedBox(height: AppSizes.xl),

              // ── Inline error + retry (if preload failed) ───────────────
              // Subscribe button is still enabled — service layer retries internally.
              // (Build 33 fix: never permanently disable the subscribe button.)
              if (_offeringError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          size: 14, color: AppColors.warning),
                      const SizedBox(width: 4),
                      const Text(
                        'Could not load pricing. ',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: _preloadOffering,
                        child: const Text(
                          'Retry',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Subscribe button ───────────────────────────────────────
              // NOTE: Do NOT gate on _offeringError here.
              // Pre-load is an optimization only. purchaseMonthlySubscription()
              // does its own fresh fetch with fallback (Build 33 Apple fix).
              FilledButton(
                onPressed:
                    (_isPurchasing || _isLoadingOffering) ? null : _handlePurchase,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
                child: _isLoadingOffering || _isPurchasing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        // Dynamic button text from StoreKit
                        'Subscribe for $priceString/month',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: AppSizes.sm),

              // ── Trial terms (Apple required disclosure) ────────────────
              Text(
                'Free for $trialPeriod, then $priceString/month. Renews monthly. Cancel anytime.',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.xs),

              // ── Restore · Terms · Privacy in one compact row ───────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: _isPurchasing ? null : _handleRestore,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.xs, vertical: AppSizes.xs),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Restore',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.primary)),
                  ),
                  const Text(' · ',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textTertiary)),
                  TextButton(
                    onPressed: () => _openUrl('https://customsubs.us/terms'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.xs, vertical: AppSizes.xs),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Terms',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.primary)),
                  ),
                  const Text(' · ',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textTertiary)),
                  TextButton(
                    onPressed: () => _openUrl('https://customsubs.us/privacy'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.xs, vertical: AppSizes.xs),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Privacy',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.primary)),
                  ),
                ],
              ),

              // ── Fine print ─────────────────────────────────────────────
              Text(
                'Managed through App Store. Free tier: ${RevenueCatConstants.maxFreeSubscriptions} subscriptions.',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textTertiary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.sm),
            ],
          ),
        ),
      ),
    );
  }

  /// Compact single-line feature row with a green checkmark.
  /// Replaces the previous tall icon-box + two-line text layout.
  Widget _buildCompactFeatureRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: AppColors.primary, size: 20),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePurchase() async {
    setState(() => _isPurchasing = true);
    await HapticUtils.medium();

    // If pre-load failed, attempt one more fetch before going to purchase.
    // This handles the case where the paywall opened during a sandbox hiccup
    // but the user taps Subscribe after connectivity recovers.
    if (_cachedOffering == null && !_isLoadingOffering) {
      debugPrint('⚠️ PAYWALL: Cached offering null at purchase time, re-fetching...');
      await _preloadOffering();
    }

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

  /// Open URL in external browser
  Future<void> _openUrl(String urlString) async {
    await HapticUtils.light();

    try {
      final url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open $urlString'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
