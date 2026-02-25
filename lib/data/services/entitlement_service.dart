/// Service for managing RevenueCat subscription entitlements.
///
/// This service handles:
/// - Initializing RevenueCat SDK
/// - Checking premium entitlement status
/// - Presenting paywalls
/// - Restoring purchases
library;

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'; // For PlatformException
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:custom_subs/core/constants/revenue_cat_constants.dart';

/// Service for RevenueCat subscription management.
class EntitlementService {
  /// Private constructor for singleton pattern.
  EntitlementService._();

  /// Singleton instance.
  static final EntitlementService instance = EntitlementService._();

  /// Whether RevenueCat has been initialized.
  bool _isInitialized = false;

  /// Last error message for debugging (accessible from UI)
  String? lastErrorMessage;

  /// Last error details for debugging
  Map<String, dynamic>? lastErrorDetails;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  /// Initialize RevenueCat SDK.
  ///
  /// Must be called during app startup before checking entitlements.
  /// Safe to call multiple times (will only initialize once).
  Future<void> initialize() async {
    debugPrint('');
    debugPrint('╔════════════════════════════════════════════════╗');
    debugPrint('║   REVENUECAT INITIALIZATION                    ║');
    debugPrint('╚════════════════════════════════════════════════╝');

    if (_isInitialized) {
      debugPrint('⚠️ RevenueCat already initialized - skipping');
      return;
    }

    try {
      final platform = Platform.isIOS ? 'iOS' : 'Android';
      final apiKey = Platform.isIOS
          ? RevenueCatConstants.iosApiKey
          : RevenueCatConstants.androidApiKey;

      debugPrint('Platform: $platform');
      debugPrint('API Key: ${apiKey.substring(0, 10)}...${apiKey.substring(apiKey.length - 4)}');
      debugPrint('Debug Mode: ${kDebugMode ? "ENABLED" : "DISABLED"}');

      // Configure RevenueCat with platform-specific API keys
      final configuration = PurchasesConfiguration(apiKey);

      // Optional: Enable debug logs in development
      if (kDebugMode) {
        debugPrint('Setting RevenueCat log level to DEBUG...');
        await Purchases.setLogLevel(LogLevel.debug);
      }

      debugPrint('Configuring RevenueCat SDK...');
      await Purchases.configure(configuration);

      // Verify configuration by checking customer info
      final customerInfo = await Purchases.getCustomerInfo();
      debugPrint('Customer Info Retrieved: ${customerInfo.originalAppUserId}');

      _isInitialized = true;

      debugPrint('');
      debugPrint('✅ RevenueCat initialized successfully');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('');
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('❌ RevenueCat initialization failed!');
      debugPrint('Error: $e');
      debugPrint('Stack Trace:');
      debugPrint(stackTrace.toString());
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('');
      debugPrint('⚠️ App will run in FREE TIER mode (no premium features)');
      // Don't rethrow - app should work without RevenueCat in degraded mode
    }
  }

  // ============================================================
  // ENTITLEMENT CHECKS
  // ============================================================

  /// Check if user has premium entitlement (unlimited subscriptions).
  ///
  /// Returns:
  /// - `true` if user has active premium subscription
  /// - `false` if user is on free tier or RevenueCat unavailable
  ///
  /// This method is safe to call frequently - RevenueCat caches results.
  Future<bool> hasPremiumEntitlement() async {
    if (!_isInitialized) {
      debugPrint('⚠️ RevenueCat not initialized, treating as free tier');
      return false;
    }

    try {
      // Get latest customer info from RevenueCat
      final customerInfo = await Purchases.getCustomerInfo();

      // Check if user has the premium entitlement
      final entitlement = customerInfo.entitlements
          .all[RevenueCatConstants.premiumEntitlementId];

      final hasPremium = entitlement?.isActive ?? false;

      // 🆕 Enhanced debug logging
      if (hasPremium) {
        // Parse ISO 8601 string to DateTime (RevenueCat returns dates as strings)
        final expirationDateString = entitlement?.expirationDate;
        final expirationDate = expirationDateString != null
            ? DateTime.parse(expirationDateString)
            : null;
        final willRenew = entitlement?.willRenew ?? false;

        debugPrint('✅ Premium entitlement ACTIVE');
        debugPrint('   └─ Will renew: $willRenew');
        debugPrint('   └─ Expiration: ${expirationDate?.toLocal() ?? "Never"}');

        // Trial detection
        final isTrialActive = await isInFreeTrial();
        if (isTrialActive) {
          final daysRemaining = await getRemainingTrialDays();
          debugPrint('   └─ 🆓 FREE TRIAL - $daysRemaining days remaining');
        }
      } else {
        debugPrint('🔒 Free tier - no premium entitlement');
      }

      return hasPremium;
    } catch (e) {
      debugPrint('❌ Error checking entitlement: $e');
      // On error, assume free tier (fail-safe)
      return false;
    }
  }

  // ============================================================
  // FREE TRIAL TRACKING
  // ============================================================

  /// Get the trial end date if user is in active trial period.
  ///
  /// Returns:
  /// - DateTime if user has active trial entitlement with expiration date
  /// - null if no trial or trial expired
  Future<DateTime?> getTrialEndDate() async {
    if (!_isInitialized) {
      debugPrint('⚠️ RevenueCat not initialized, cannot get trial end date');
      return null;
    }

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement =
          customerInfo.entitlements.all[RevenueCatConstants.premiumEntitlementId];

      if (entitlement == null) {
        debugPrint('📅 No premium entitlement found - no trial data');
        return null;
      }

      // Parse ISO 8601 string to DateTime (RevenueCat returns dates as strings)
      final expirationDateString = entitlement.expirationDate;
      final expirationDate = expirationDateString != null
          ? DateTime.parse(expirationDateString)
          : null;
      final isActive = entitlement.isActive;

      if (isActive && expirationDate != null) {
        final now = DateTime.now();
        if (expirationDate.isAfter(now)) {
          debugPrint(
              '✅ Active trial detected - expires: ${expirationDate.toIso8601String()}');
          return expirationDate;
        } else {
          debugPrint('⏰ Trial expired at: ${expirationDate.toIso8601String()}');
          return null;
        }
      }

      debugPrint('📅 No active trial (entitlement not active or no expiration)');
      return null;
    } catch (e) {
      debugPrint('❌ Error getting trial end date: $e');
      return null;
    }
  }

  /// Get remaining days in trial period.
  ///
  /// Returns:
  /// - Number of days remaining (e.g., 2 means trial ends in 2 days)
  /// - 0 if trial expired or no trial
  Future<int> getRemainingTrialDays() async {
    final expirationDate = await getTrialEndDate();
 
    if (expirationDate == null) {
      debugPrint('📅 No trial - returning 0 days remaining');
      return 0;
    }

    final now = DateTime.now();
    final difference = expirationDate.difference(now);
    final daysRemaining = difference.inDays;

    debugPrint(
        '✅ Trial days remaining: $daysRemaining (expires: ${expirationDate.toLocal()})');

    return daysRemaining > 0 ? daysRemaining : 0;
  }

  /// Check if user is currently in free trial period.
  ///
  /// Returns:
  /// - true if trial is active and not expired
  /// - false otherwise
  Future<bool> isInFreeTrial() async {
    final trialEndDate = await getTrialEndDate();
    final isInTrial = trialEndDate != null;

    debugPrint('🆓 Free trial status: ${isInTrial ? "ACTIVE" : "INACTIVE"}');

    return isInTrial;
  }

  /// Check if user can add more subscriptions based on current count.
  ///
  /// Parameters:
  /// - [currentSubscriptionCount] - Number of subscriptions user currently has
  ///
  /// Returns:
  /// - `true` if user can add more subscriptions
  /// - `false` if user hit free limit and needs to upgrade
  Future<bool> canAddMoreSubscriptions(int currentSubscriptionCount) async {
    // Premium users have unlimited subscriptions
    final isPremium = await hasPremiumEntitlement();
    if (isPremium) {
      return true;
    }

    // Free users limited to maxFreeSubscriptions
    return currentSubscriptionCount < RevenueCatConstants.maxFreeSubscriptions;
  }

  // ============================================================
  // PURCHASE FLOW
  // ============================================================

  /// Get available subscription offerings.
  ///
  /// Returns the default offering with packages (monthly subscription).
  /// Used to display pricing in paywall.
  ///
  /// Uses fallback logic:
  /// 1. Try offerings.current (marked as current in dashboard)
  /// 2. Fall back to explicit 'default' offering by ID
  /// This ensures we get the offering even if 'current' flag isn't set properly.
  Future<Offering?> getOfferings() async {
    if (!_isInitialized) {
      debugPrint('⚠️ RevenueCat not initialized');
      return null;
    }

    try {
      final offerings = await Purchases.getOfferings();

      // Try current offering first, fall back to explicit 'default' lookup
      final offering = offerings.current ?? offerings.all[RevenueCatConstants.defaultOfferingId];

      if (offering == null) {
        debugPrint('⚠️ No current offering and no "${RevenueCatConstants.defaultOfferingId}" offering found');
        debugPrint('   Available offerings: ${offerings.all.keys.join(", ")}');
      }

      return offering;
    } catch (e) {
      debugPrint('❌ Error fetching offerings: $e');
      return null;
    }
  }

  /// Get offerings with retry logic for sandbox environment.
  ///
  /// Sandbox can be flaky - retry up to 3 times with exponential backoff.
  /// This is critical for iPad sandbox testing where StoreKit daemon
  /// connection can be slow or timeout on first attempt.
  ///
  /// Returns the current offering, or null if all retries fail.
  Future<Offering?> getOfferingsWithRetry({
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    if (!_isInitialized) {
      debugPrint('⚠️ RevenueCat not initialized');
      return null;
    }

    int attempt = 0;
    Duration delay = initialDelay;

    while (attempt < maxRetries) {
      attempt++;
      debugPrint('📡 Fetching offerings (attempt $attempt/$maxRetries)...');

      try {
        final offerings = await Purchases.getOfferings();

        // Try current offering first, fall back to explicit 'default' lookup
        final offering = offerings.current ?? offerings.all[RevenueCatConstants.defaultOfferingId];

        if (offering != null) {
          debugPrint('✅ Offerings fetched successfully on attempt $attempt');
          debugPrint('   Offering ID: ${offering.identifier}');
          debugPrint('   Packages: ${offering.availablePackages.length}');
          if (offerings.current == null) {
            debugPrint('   ℹ️ Used fallback to "${RevenueCatConstants.defaultOfferingId}" offering (current was null)');
          }
          return offering;
        } else {
          debugPrint('⚠️ No current offering and no "${RevenueCatConstants.defaultOfferingId}" offering found (attempt $attempt)');
          debugPrint('   Available offerings: ${offerings.all.keys.join(", ")}');
          if (attempt < maxRetries) {
            debugPrint('   Retrying in ${delay.inSeconds}s...');
            await Future.delayed(delay);
            delay *= 2; // Exponential backoff: 1s, 2s, 4s
          }
        }
      } catch (e) {
        debugPrint('❌ Error fetching offerings (attempt $attempt): $e');
        if (attempt < maxRetries) {
          debugPrint('   Retrying in ${delay.inSeconds}s...');
          await Future.delayed(delay);
          delay *= 2; // Exponential backoff
        } else {
          debugPrint('❌ All retry attempts failed');
          return null;
        }
      }
    }

    return null;
  }

  /// Purchase the monthly premium subscription.
  ///
  /// Presents the native App Store/Play Store purchase flow.
  ///
  /// Returns:
  /// - `true` if purchase succeeded
  /// - `false` if purchase failed or was cancelled
  Future<bool> purchaseMonthlySubscription() async {
    debugPrint('');
    debugPrint('╔════════════════════════════════════════════════╗');
    debugPrint('║   PURCHASE FLOW INITIATED                      ║');
    debugPrint('╚════════════════════════════════════════════════╝');
    debugPrint('Platform: ${Platform.isIOS ? "iOS" : "Android"}');
    debugPrint('RevenueCat Initialized: $_isInitialized');
    debugPrint('Target Product: ${RevenueCatConstants.monthlyProductId}');

    if (!_isInitialized) {
      debugPrint('❌ RevenueCat not initialized - aborting purchase');
      return false;
    }

    // iOS 18.0-18.5 Workaround: Add delay to stabilize StoreKit daemon connection
    // Reference: https://www.revenuecat.com/docs/known-store-issues/storekit/ios-18-purchase-fails
    if (Platform.isIOS) {
      debugPrint('');
      debugPrint('⚙️  iOS detected - applying StoreKit stabilization delay (500ms)');
      debugPrint('   This prevents iOS 18.x purchase sheet failures in sandbox');
      await Future.delayed(const Duration(milliseconds: 500));
    }

    try {
      debugPrint('');
      debugPrint('📡 Fetching offerings from RevenueCat...');
      debugPrint('   OS: ${Platform.operatingSystem}');
      debugPrint('   OS Version: ${Platform.operatingSystemVersion}');

      // Get available offerings
      final offerings = await Purchases.getOfferings();
      final offering = offerings.current;

      debugPrint('Total Offerings: ${offerings.all.length}');
      debugPrint('Current Offering: ${offering?.identifier ?? "NONE"}');

      if (offering == null) {
        debugPrint('');
        debugPrint('❌ CRITICAL: No current offering available');
        debugPrint('   Check RevenueCat dashboard configuration');
        debugPrint('   Ensure default offering exists and has products');

        // Store error for UI display
        lastErrorMessage = 'No offering available';
        lastErrorDetails = {
          'error': 'NO_OFFERING',
          'totalOfferings': offerings.all.length,
          'suggestion': 'Check RevenueCat Dashboard → Offerings → Create "default" offering',
        };

        return false;
      }

      // 🆕 Debug log offering details
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📦 PURCHASE FLOW DEBUG - Available Offerings');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('Offering ID: ${offering.identifier}');
      debugPrint('Total Packages: ${offering.availablePackages.length}');
      debugPrint('Looking for Product ID: ${RevenueCatConstants.monthlyProductId}');
      debugPrint('');

      debugPrint('📋 All Available Packages:');
      for (int i = 0; i < offering.availablePackages.length; i++) {
        final package = offering.availablePackages[i];
        debugPrint('');
        debugPrint('Package #${i + 1}:');
        debugPrint('  ├─ Package Identifier: "${package.identifier}"');
        debugPrint('  ├─ Product ID: "${package.storeProduct.identifier}"');
        debugPrint('  ├─ Price: ${package.storeProduct.priceString}');
        debugPrint('  ├─ Package Type: ${package.packageType}');

        // Check if this matches our search criteria
        final matchesPackageId = package.identifier == RevenueCatConstants.monthlyProductId;
        final matchesProductId = package.storeProduct.identifier == RevenueCatConstants.monthlyProductId;
        debugPrint('  ├─ Matches by package.identifier? $matchesPackageId');
        debugPrint('  ├─ Matches by storeProduct.identifier? $matchesProductId');

        // 🆕 Trial information logging
        final introPrice = package.storeProduct.introductoryPrice;
        if (introPrice != null) {
          debugPrint('  ├─ 🆓 Trial Available: YES');
          debugPrint('  │  ├─ Trial Price: ${introPrice.priceString}');
          debugPrint('  │  ├─ Trial Period: ${introPrice.period}');
          debugPrint('  │  └─ Trial Cycles: ${introPrice.cycles}');
        } else {
          debugPrint('  └─ 🆓 Trial Available: NO');
        }

        if (matchesProductId) {
          debugPrint('  ✅ THIS IS THE PACKAGE WE WANT!');
        }
      }

      debugPrint('');
      debugPrint('🔍 Searching for package...');

      // Find monthly package - TRY BOTH METHODS
      Package? monthlyPackage;

      // Method 1: Try by storeProduct.identifier (CORRECT)
      try {
        monthlyPackage = offering.availablePackages.firstWhere(
          (package) =>
              package.storeProduct.identifier == RevenueCatConstants.monthlyProductId,
        );
        debugPrint('✅ Found package using storeProduct.identifier');
      } catch (e) {
        debugPrint('❌ Method 1 failed: storeProduct.identifier not found');
      }

      // Method 2: Fallback to package.identifier if Method 1 failed
      if (monthlyPackage == null) {
        try {
          monthlyPackage = offering.availablePackages.firstWhere(
            (package) =>
                package.identifier == RevenueCatConstants.monthlyProductId,
          );
          debugPrint('✅ Found package using package.identifier (fallback)');
        } catch (e) {
          debugPrint('❌ Method 2 failed: package.identifier not found');
        }
      }

      // Method 3: Try by package type if both failed
      if (monthlyPackage == null) {
        try {
          monthlyPackage = offering.availablePackages.firstWhere(
            (package) => package.packageType == PackageType.monthly,
          );
          debugPrint('⚠️ Found package using PackageType.monthly (last resort)');
          debugPrint('   Product ID: ${monthlyPackage.storeProduct.identifier}');
        } catch (e) {
          debugPrint('❌ Method 3 failed: No monthly package type found');
        }
      }

      if (monthlyPackage == null) {
        debugPrint('');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('❌ CRITICAL ERROR: Monthly package not found!');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('Expected Product ID: ${RevenueCatConstants.monthlyProductId}');
        debugPrint('Available Products:');
        for (final package in offering.availablePackages) {
          debugPrint('  - ${package.storeProduct.identifier}');
        }
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        // Store error for UI display
        final availableProducts = offering.availablePackages
            .map((p) => p.storeProduct.identifier)
            .toList();

        lastErrorMessage = 'Package not found';
        lastErrorDetails = {
          'error': 'PACKAGE_NOT_FOUND',
          'expected': RevenueCatConstants.monthlyProductId,
          'available': availableProducts,
          'suggestion': 'Add product "${RevenueCatConstants.monthlyProductId}" to RevenueCat offering',
        };

        throw Exception(
          'Monthly package not found. Expected: "${RevenueCatConstants.monthlyProductId}". '
          'Available: ${availableProducts.join(", ")}'
        );
      }

      debugPrint('');
      debugPrint('✅ Package Selected:');
      debugPrint('  ├─ Package ID: ${monthlyPackage.identifier}');
      debugPrint('  ├─ Product ID: ${monthlyPackage.storeProduct.identifier}');
      debugPrint('  └─ Price: ${monthlyPackage.storeProduct.priceString}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      debugPrint('');
      debugPrint('💳 Initiating purchase with App Store/Play Store...');
      debugPrint('   Product: ${monthlyPackage.storeProduct.identifier}');
      debugPrint('   Price: ${monthlyPackage.storeProduct.priceString}');

      // Initiate purchase
      final customerInfo = await Purchases.purchasePackage(monthlyPackage);

      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📥 PURCHASE RESPONSE RECEIVED');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Check if purchase granted premium entitlement
      final hasPremium = customerInfo.entitlements
              .all[RevenueCatConstants.premiumEntitlementId]?.isActive ??
          false;

      debugPrint('Premium Entitlement Active: $hasPremium');
      debugPrint('Total Entitlements: ${customerInfo.entitlements.all.length}');

      // Log all entitlements
      if (customerInfo.entitlements.all.isNotEmpty) {
        debugPrint('');
        debugPrint('All Entitlements:');
        for (final entry in customerInfo.entitlements.all.entries) {
          debugPrint('  - ${entry.key}: ${entry.value.isActive ? "ACTIVE ✅" : "inactive"}');
        }
      }

      // Check if trial started
      final isTrialActive = await isInFreeTrial();
      debugPrint('');
      debugPrint('Trial Status: ${isTrialActive ? "ACTIVE 🆓" : "Not in trial"}');

      if (isTrialActive) {
        final daysRemaining = await getRemainingTrialDays();
        final trialEndDate = await getTrialEndDate();
        debugPrint('  ├─ Days Remaining: $daysRemaining');
        debugPrint('  └─ Expires: ${trialEndDate?.toLocal()}');
      }

      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(hasPremium ? '✅ PURCHASE SUCCESSFUL' : '⚠️ PURCHASE COMPLETED BUT NO PREMIUM ACCESS');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('');

      // If purchase succeeded but premium not granted, capture error details
      if (!hasPremium) {
        final availableEntitlements = customerInfo.entitlements.all.keys.toList();

        lastErrorMessage = 'Entitlement not granted';
        lastErrorDetails = {
          'error': 'NO_ENTITLEMENT',
          'expected': RevenueCatConstants.premiumEntitlementId,
          'available': availableEntitlements,
          'totalEntitlements': customerInfo.entitlements.all.length,
          'suggestion': 'The purchase completed but the "${RevenueCatConstants.premiumEntitlementId}" entitlement was not activated. '
              'Check RevenueCat Dashboard → Entitlements → Ensure product is attached to entitlement.',
        };

        debugPrint('⚠️ ERROR CAPTURED: Purchase completed but entitlement not granted');
        debugPrint('   Expected entitlement: ${RevenueCatConstants.premiumEntitlementId}');
        debugPrint('   Available entitlements: ${availableEntitlements.isEmpty ? "NONE" : availableEntitlements.join(", ")}');
      }

      return hasPremium;
    } on PlatformException catch (e) {
      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ PLATFORM EXCEPTION DURING PURCHASE');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      debugPrint('Error Code: $errorCode');
      debugPrint('Error Message: ${e.message}');
      debugPrint('Error Details: ${e.details}');

      String errorReason = 'Unknown platform error';
      String suggestion = 'Please try again or contact support.';

      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('Reason: User cancelled the purchase');
        errorReason = 'Purchase cancelled by user';
        suggestion = 'Tap "Start 3-Day Free Trial" to try again';
      } else if (errorCode == PurchasesErrorCode.productAlreadyPurchasedError) {
        debugPrint('Reason: Product already purchased - try "Restore Purchases"');
        errorReason = 'Product already purchased';
        suggestion = 'Tap "Restore Purchases" to restore your subscription';
      } else if (errorCode == PurchasesErrorCode.storeProblemError) {
        debugPrint('Reason: App Store/Play Store connection issue');
        errorReason = 'App Store connection problem';
        suggestion = 'Check your internet connection and try again';
      } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
        debugPrint('Reason: Purchases not allowed on this device');
        errorReason = 'Purchases not allowed';
        suggestion = 'Check Settings → Screen Time → Content & Privacy Restrictions';
      } else if (errorCode == PurchasesErrorCode.purchaseInvalidError) {
        debugPrint('Reason: Product configuration invalid - check App Store Connect');
        errorReason = 'Product not configured properly';
        suggestion = 'Please contact support - product configuration issue';
      } else {
        debugPrint('Reason: ${errorCode.toString()}');
        errorReason = errorCode.toString();
      }

      // Store error for UI display
      lastErrorMessage = errorReason;
      lastErrorDetails = {
        'error': 'PLATFORM_EXCEPTION',
        'errorCode': errorCode.toString(),
        'message': e.message ?? 'No message',
        'details': e.details?.toString() ?? 'No details',
        'suggestion': suggestion,
      };

      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('');
      return false;
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ UNEXPECTED ERROR DURING PURCHASE');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('Error Type: ${e.runtimeType}');
      debugPrint('Error Message: $e');
      debugPrint('Stack Trace:');
      debugPrint(stackTrace.toString());
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('');

      // Store error for UI display
      lastErrorMessage = 'Unexpected error';
      lastErrorDetails = {
        'error': 'UNEXPECTED_ERROR',
        'errorType': e.runtimeType.toString(),
        'message': e.toString(),
        'stackTrace': stackTrace.toString().substring(0, 500), // Truncate for UI
        'suggestion': 'Please screenshot this error and contact support',
      };

      return false;
    }
  }

  /// Restore previous purchases.
  ///
  /// Useful when user reinstalls app or switches devices.
  ///
  /// Returns:
  /// - `true` if premium entitlement was restored
  /// - `false` if no purchases to restore
  Future<bool> restorePurchases() async {
    if (!_isInitialized) {
      debugPrint('⚠️ RevenueCat not initialized');
      return false;
    }

    try {
      final customerInfo = await Purchases.restorePurchases();

      final hasPremium = customerInfo.entitlements
              .all[RevenueCatConstants.premiumEntitlementId]?.isActive ??
          false;

      debugPrint('Restore completed. Premium status: $hasPremium');
      return hasPremium;
    } catch (e) {
      debugPrint('❌ Restore error: $e');
      return false;
    }
  }

  // ============================================================
  // USER IDENTIFICATION (Optional)
  // ============================================================

  /// Set user identifier for RevenueCat analytics.
  ///
  /// Optional - only needed if you track users across devices.
  Future<void> identifyUser(String userId) async {
    if (!_isInitialized) return;

    try {
      await Purchases.logIn(userId);
      debugPrint('User identified: $userId');
    } catch (e) {
      debugPrint('❌ User identification error: $e');
    }
  }

  /// Clear user identification (logout).
  Future<void> logoutUser() async {
    if (!_isInitialized) return;

    try {
      await Purchases.logOut();
      debugPrint('User logged out');
    } catch (e) {
      debugPrint('❌ Logout error: $e');
    }
  }
}
