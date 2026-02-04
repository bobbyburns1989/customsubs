/// Application root widget and configuration.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:custom_subs/app/theme.dart';
import 'package:custom_subs/app/router.dart';

/// Root application widget for CustomSubs.
///
/// Responsible for:
/// - Applying Material 3 theme
/// - Setting up GoRouter navigation
/// - Determining initial route based on onboarding status
/// - Showing loading state during initialization
class CustomSubsApp extends ConsumerWidget {
  const CustomSubsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<bool>(
      future: _getOnboardingStatus(),
      builder: (context, snapshot) {
        // Show loading spinner while checking onboarding status
        if (!snapshot.hasData) {
          return MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // Configure router with appropriate initial route
        final hasSeenOnboarding = snapshot.data!;
        final router = AppRouter.router(hasSeenOnboarding);

        return MaterialApp.router(
          title: 'CustomSubs',
          theme: AppTheme.lightTheme,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }

  /// Checks if the user has completed the onboarding flow.
  ///
  /// Returns `true` if onboarding has been seen, `false` otherwise.
  /// The onboarding status is persisted in the 'settings' Hive box.
  ///
  /// If an error occurs reading from Hive, returns `false` to show
  /// onboarding as a safety measure (better to show it twice than skip it).
  Future<bool> _getOnboardingStatus() async {
    try {
      final settingsBox = await Hive.openBox('settings');
      return settingsBox.get('hasSeenOnboarding', defaultValue: false);
    } catch (e) {
      // If we can't read settings, assume onboarding not seen
      return false;
    }
  }
}
