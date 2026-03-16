/// Analytics service wrapping PostHog for anonymous, privacy-first event tracking.
///
/// Follows the existing service pattern (like NotificationService, EntitlementService):
/// - Wrapped in a Riverpod provider (no singletons)
/// - Supports opt-out toggle persisted in Hive settings box
/// - No PII collected — all events are anonymous
/// - Fire-and-forget capture — PostHog batches internally
///
/// PostHog is the second outbound SDK after RevenueCat.
/// `captureApplicationLifecycleEvents` gives us app open/background for free.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:custom_subs/core/constants/posthog_constants.dart';

part 'analytics_service.g.dart';

/// Thin wrapper around PostHog SDK with opt-out support.
///
/// Usage:
/// ```dart
/// final analytics = ref.read(analyticsServiceProvider);
/// analytics.capture('subscription_created', {'category': 'music', 'cycle': 'monthly'});
/// ```
class AnalyticsService {
  // Singleton via factory constructor — ensures the instance initialized in
  // main() is the same one returned by the Riverpod provider. Without this,
  // each `AnalyticsService()` call creates a new object with _initialized=false,
  // so capture() silently drops every event.
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  static const String _optOutKey = 'analytics_opt_out';

  bool _initialized = false;

  /// Initialize PostHog SDK. Call once in main() during app startup.
  ///
  /// Respects saved opt-out preference from Hive settings box.
  /// Skips initialization in debug mode if [PostHogConstants.enableInDebug] is false.
  Future<void> init() async {
    if (_initialized) return;

    // Skip in debug mode if configured to keep dev events out of production
    if (kDebugMode && !PostHogConstants.enableInDebug) {
      debugPrint('PostHog: Skipped init (debug mode disabled)');
      _initialized = true;
      return;
    }

    final config = PostHogConfig(PostHogConstants.apiKey);
    config.host = PostHogConstants.host;
    config.debug = kDebugMode;
    // Auto-track Application Opened / Application Backgrounded events
    config.captureApplicationLifecycleEvents = true;

    await Posthog().setup(config);

    // Respect saved opt-out preference from previous sessions
    final settingsBox = await Hive.openBox('settings');
    final isOptedOut =
        settingsBox.get(_optOutKey, defaultValue: false) as bool;
    if (isOptedOut) {
      await Posthog().disable();
    }

    _initialized = true;
    debugPrint('PostHog: Initialized (opted out: $isOptedOut)');
  }

  /// Track an event with optional properties.
  ///
  /// Silently no-ops if not initialized or user has opted out.
  /// PostHog batches events internally — this is fire-and-forget.
  ///
  /// Properties should be categorical/boolean only — never include PII
  /// like subscription names, amounts, or user-entered text.
  void capture(String eventName, [Map<String, Object>? properties]) {
    if (!_initialized) return;
    Posthog().capture(eventName: eventName, properties: properties);
  }

  /// Check if user has opted out of analytics.
  Future<bool> isOptedOut() async {
    final settingsBox = await Hive.openBox('settings');
    return settingsBox.get(_optOutKey, defaultValue: false) as bool;
  }

  /// Set analytics opt-out preference.
  ///
  /// Persists choice in Hive settings box and immediately enables/disables
  /// the PostHog SDK. Takes effect for all future events.
  Future<void> setOptOut(bool optOut) async {
    final settingsBox = await Hive.openBox('settings');
    await settingsBox.put(_optOutKey, optOut);

    if (optOut) {
      await Posthog().disable();
    } else {
      await Posthog().enable();
    }
  }
}

/// Riverpod provider for the analytics service.
/// Access via `ref.read(analyticsServiceProvider)` in controllers and widgets.
@riverpod
AnalyticsService analyticsService(Ref ref) {
  return AnalyticsService();
}
