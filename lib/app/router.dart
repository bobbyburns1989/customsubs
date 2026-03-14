library;

/// Navigation configuration using GoRouter.

import 'package:flutter/cupertino.dart';
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
///
/// Transitions:
/// - CupertinoPage (iOS slide) for content push routes
/// - Fade (250ms) for modal-style screens (Settings, Paywall)
/// - Default MaterialPage for root/onboarding
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

  /// Creates a fade transition page for modal-style screens.
  /// Used by Settings and Paywall to distinguish them from
  /// hierarchical push navigation.
  static CustomTransitionPage<void> _fadePage({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
    );
  }

  /// Creates the app's router configuration.
  ///
  /// The initial route depends on [hasSeenOnboarding]:
  /// - If `true`: starts at home screen
  /// - If `false`: starts at onboarding screen
  ///
  /// Routes:
  /// - `/onboarding` - First-time user introduction
  /// - `/` - Main home screen with subscription list
  /// - `/settings` - App settings and preferences (fade)
  /// - `/analytics` - Spending analytics and insights (iOS slide)
  /// - `/add-subscription` - Create new subscription (iOS slide)
  /// - `/edit-subscription?id=<id>` - Edit existing subscription (iOS slide)
  /// - `/subscription/:id` - View subscription details (iOS slide + Hero)
  /// - `/paywall` - Premium subscription upgrade screen (fade)
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
          pageBuilder: (context, state) => _fadePage(
            key: state.pageKey,
            child: const SettingsScreen(),
          ),
        ),
        GoRoute(
          path: analytics,
          pageBuilder: (context, state) => CupertinoPage(
            key: state.pageKey,
            child: const AnalyticsScreen(),
          ),
        ),
        GoRoute(
          path: paywall,
          pageBuilder: (context, state) => _fadePage(
            key: state.pageKey,
            child: const PaywallScreen(),
          ),
        ),
        GoRoute(
          path: addSubscription,
          pageBuilder: (context, state) => CupertinoPage(
            key: state.pageKey,
            child: const AddSubscriptionScreen(),
          ),
        ),
        // Edit subscription route uses query parameter for ID
        GoRoute(
          path: editSubscription,
          pageBuilder: (context, state) {
            final subscriptionId = state.uri.queryParameters['id'];
            return CupertinoPage(
              key: state.pageKey,
              child: AddSubscriptionScreen(subscriptionId: subscriptionId),
            );
          },
        ),
        // Detail route uses path parameter for ID
        GoRoute(
          path: '$subscriptionDetail/:id',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id']!;
            final extra = state.extra as Map<String, dynamic>?;
            final autoMarkPaid = extra?['autoMarkPaid'] as bool? ?? false;
            return CupertinoPage(
              key: state.pageKey,
              child: SubscriptionDetailScreen(
                subscriptionId: id,
                autoMarkPaid: autoMarkPaid,
              ),
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
