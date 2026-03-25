import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:custom_subs/data/services/analytics_service.dart';

/// Lightweight service that prompts for an App Store review after a success moment.
///
/// Triggers once after the user creates their 5th subscription (a meaningful
/// engagement milestone). Apple rate-limits to 3 prompts per 365 days, and
/// we only trigger once — so annoyance risk is minimal.
///
/// State is persisted in Hive settings box:
/// - `subscription_create_count`: incremented on each new subscription
/// - `has_shown_review_prompt`: set to true after the prompt fires
class ReviewService {
  static const String _countKey = 'subscription_create_count';
  static const String _promptShownKey = 'has_shown_review_prompt';
  static const int _triggerThreshold = 5;

  /// Increments the subscription creation counter.
  /// Call after every successful new subscription save.
  Future<void> incrementCreateCount() async {
    final settingsBox = await Hive.openBox('settings');
    final count = settingsBox.get(_countKey, defaultValue: 0) as int;
    await settingsBox.put(_countKey, count + 1);
  }

  /// Checks whether conditions are met to show the review prompt,
  /// and if so, shows it. Returns true if the prompt was shown.
  Future<bool> maybePromptReview() async {
    final settingsBox = await Hive.openBox('settings');
    final count = settingsBox.get(_countKey, defaultValue: 0) as int;
    final hasShown = settingsBox.get(_promptShownKey, defaultValue: false) as bool;

    if (count < _triggerThreshold || hasShown) return false;

    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      AnalyticsService().capture('review_prompt_shown');
      await inAppReview.requestReview();
      await settingsBox.put(_promptShownKey, true);
      return true;
    }

    debugPrint('ReviewService: InAppReview not available on this device');
    return false;
  }
}
