/// Navigation configuration using GoRouter.

import 'package:go_router/go_router.dart';
import 'package:custom_subs/features/onboarding/onboarding_screen.dart';
import 'package:custom_subs/features/home/home_screen.dart';
import 'package:custom_subs/features/settings/settings_screen.dart';
import 'package:custom_subs/features/add_subscription/add_subscription_screen.dart';
import 'package:custom_subs/features/subscription_detail/subscription_detail_screen.dart';

/// Centralized app routing configuration.
///
/// Uses GoRouter for declarative, type-safe navigation.
/// All route paths are defined as constants for easy reference.
class AppRouter {
  // Route path constants
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String settings = '/settings';
  static const String addSubscription = '/add-subscription';
  static const String editSubscription = '/edit-subscription';
  static const String subscriptionDetail = '/subscription';

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
  /// - `/add-subscription` - Create new subscription
  /// - `/edit-subscription?id=<id>` - Edit existing subscription
  /// - `/subscription/:id` - View subscription details
  static GoRouter router(bool hasSeenOnboarding) {
    return GoRouter(
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
            return SubscriptionDetailScreen(subscriptionId: id);
          },
        ),
      ],
    );
  }
}
