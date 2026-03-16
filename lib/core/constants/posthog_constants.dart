/// PostHog analytics configuration for CustomSubs.
///
/// Contains API key, host, and debug settings.
/// IMPORTANT: Copy-paste the API key from PostHog dashboard — never type manually.
/// (Learned from RevenueCat key typo incidents in Builds 36–43.)
library;

class PostHogConstants {
  PostHogConstants._(); // Private constructor to prevent instantiation

  // ============================================================
  // API KEY (Copy-paste from PostHog dashboard)
  // ============================================================

  /// PostHog project API key.
  /// Get from: PostHog → Project Settings → Project API Key
  static const String apiKey = 'phc_CovarKDf4evTIqgGgU4uN2teDUdxdbn32BVDNjvrKm8';

  // ============================================================
  // HOST
  // ============================================================

  /// PostHog instance host URL.
  /// US Cloud: https://us.i.posthog.com
  /// EU Cloud: https://eu.i.posthog.com
  static const String host = 'https://us.i.posthog.com';

  // ============================================================
  // DEBUG
  // ============================================================

  /// Whether to send analytics events in debug/development mode.
  /// Set to false to keep dev events out of production project.
  static const bool enableInDebug = true;
}
