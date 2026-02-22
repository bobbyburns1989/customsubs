library;

/// Navigation configuration using GoRouter.

import 'package:go_router/go_router.dart';
import 'package:custom_subs/features/onboarding/onboarding_screen.dart';
import 'package:custom_subs/features/home/home_screen.dart';
import 'package:custom_subs/features/settings/settings_screen.dart';
import 'package:custom_subs/features/add_subscription/add_subscription_screen.dart';
import 'package:custom_subs/features/subscription_detail/subscription_detail_screen.dart';
import 'package:custom_subs/features/analytics/analytics_screen.dart';
import 'package:custom_subs/features/paywall/paywall_screen.dart';
import 'package:custom_subs/core/utils/notification_router.dart';

/// Centralized app routing configuration.
///
/// Uses GoRouter for declarative, type-safe navigation.
/// All route paths are defined as constants for easy reference.
class AppRouter {
  // Route path constants
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String settings = '/settings';
  static const String analytics = '/analytics';
  static const String addSubscription = '/add-subscription';
  static const String editSubscription = '/edit-subscription';
  static const String subscriptionDetail = '/subscription';
  static const String paywall = '/paywall';

  /// Creates the app's router configuration.
  ///
  /// The initial route depends on [hasSeenOnboarding]:
  /// - If `true`: starts at home screen
  /// - If `false`: starts at onboarding screen
  ///
  /// Routes:
  /// - `/onboarding` - First-time user introduction
  /// - `/` - Main home screen with subscription list
  /// - `/settings` - App settings and preferences
  /// - `/analytics` - Spending analytics and insights
  /// - `/add-subscription` - Create new subscription
  /// - `/edit-subscription?id=<id>` - Edit existing subscription
  /// - `/subscription/:id` - View subscription details
  /// - `/paywall` - Premium subscription upgrade screen
  static GoRouter router(bool hasSeenOnboarding) {
    final router = GoRouter(
      initialLocation: hasSeenOnboarding ? home : onboarding,
      routes: [
        GoRoute(
          path: onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: settings,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: analytics,
          builder: (context, state) => const AnalyticsScreen(),
        ),
        GoRoute(
          path: paywall,
          builder: (context, state) => const PaywallScreen(),
        ),
        GoRoute(
          path: addSubscription,
          builder: (context, state) => const AddSubscriptionScreen(),
        ),
        // Edit subscription route uses query parameter for ID
        GoRoute(
          path: editSubscription,
          builder: (context, state) {
            final subscriptionId = state.uri.queryParameters['id'];
            return AddSubscriptionScreen(subscriptionId: subscriptionId);
          },
        ),
        // Detail route uses path parameter for ID
        GoRoute(
          path: '$subscriptionDetail/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final extra = state.extra as Map<String, dynamic>?;
            final autoMarkPaid = extra?['autoMarkPaid'] as bool? ?? false;
            return SubscriptionDetailScreen(
              subscriptionId: id,
              autoMarkPaid: autoMarkPaid,
            );
          },
        ),
      ],
    );

    // Store router instance for notification deep linking
    NotificationRouter.setRouter(router);

    return router;
  }
}
