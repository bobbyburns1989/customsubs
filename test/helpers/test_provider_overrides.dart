import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:custom_subs/data/repositories/subscription_repository.dart';
import 'package:custom_subs/data/services/notification_service.dart';
import 'package:custom_subs/data/services/analytics_service.dart';
import 'package:custom_subs/core/providers/settings_provider.dart';

import 'mocks.dart';

/// Creates a list of Riverpod provider overrides for controller/widget tests.
///
/// Returns pre-configured mocks that won't throw. Override individual mocks
/// by passing your own instances.
List<Override> testProviderOverrides({
  MockSubscriptionRepository? repository,
  MockNotificationService? notificationService,
  MockAnalyticsService? analytics,
}) {
  final repo = repository ?? MockSubscriptionRepository();
  final notif = notificationService ?? MockNotificationService();
  final anal = analytics ?? MockAnalyticsService();

  // Stub analytics to be no-op by default
  when(() => anal.capture(any(), any())).thenReturn(null);

  return [
    subscriptionRepositoryProvider.overrideWith((ref) async => repo),
    notificationServiceProvider.overrideWith((ref) async => notif),
    analyticsServiceProvider.overrideWith((ref) => anal),
    primaryCurrencyProvider.overrideWith((ref) => 'USD'),
  ];
}

/// Creates a ProviderContainer with test overrides.
///
/// Caller is responsible for calling `container.dispose()` in tearDown.
ProviderContainer createTestContainer({
  MockSubscriptionRepository? repository,
  MockNotificationService? notificationService,
  MockAnalyticsService? analytics,
}) {
  return ProviderContainer(
    overrides: testProviderOverrides(
      repository: repository,
      notificationService: notificationService,
      analytics: analytics,
    ),
  );
}
