/// RevenueCat configuration for CustomSubs subscription management.
///
/// This file contains all RevenueCat-related constants including API keys,
/// product IDs, and entitlement IDs for iOS and Android platforms.
library;

/// RevenueCat configuration constants.
class RevenueCatConstants {
  RevenueCatConstants._(); // Private constructor to prevent instantiation

  // ============================================================
  // API KEYS
  // ============================================================

  /// iOS API key from RevenueCat dashboard.
  /// Get from: https://app.revenuecat.com/projects/YOUR_PROJECT/api-keys
  static const String iosApiKey = 'appl_rRzabPDSmVyXEYjWSaSuklniHEA';

  /// Android API key from RevenueCat dashboard.
  /// Get from: https://app.revenuecat.com/projects/YOUR_PROJECT/api-keys
  /// Android API key (currently shares iOS key — single RevenueCat app).
  static const String androidApiKey = 'appl_rRzabPDSmVyXEYjWSaSuklniHEA';

  // ============================================================
  // PRODUCT IDS (Must match App Store Connect / Play Console)
  // ============================================================

  /// Monthly premium subscription product ID.
  /// - iOS: Configure in App Store Connect > In-App Purchases
  /// - Android: Configure in Play Console > Subscriptions
  /// - Price: $0.99/month
  static const String monthlyProductId = 'customsubs_premium_monthly';

  // ============================================================
  // ENTITLEMENT IDS (Must match RevenueCat dashboard)
  // ============================================================

  /// Premium entitlement identifier.
  /// This entitlement unlocks:
  /// - Unlimited subscriptions (beyond 5 free)
  /// - Future premium features
  static const String premiumEntitlementId = 'premium';

  // ============================================================
  // FREE MODE TOGGLE
  // ============================================================

  /// Master switch: true = app is completely free, no subscription limits.
  /// RevenueCat SDK still initializes for passive install/subscriber tracking.
  /// To re-monetize: set back to false.
  static const bool isFreeMode = true;

  // ============================================================
  // SUBSCRIPTION LIMITS
  // ============================================================

  /// Maximum number of subscriptions allowed on free tier.
  /// Only enforced when isFreeMode is false.
  static const int maxFreeSubscriptions = 5;

  // ============================================================
  // OFFERING IDS (Optional - for A/B testing)
  // ============================================================

  /// Default offering identifier (usually 'default')
  static const String defaultOfferingId = 'default';
}
