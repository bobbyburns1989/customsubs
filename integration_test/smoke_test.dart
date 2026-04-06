import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:custom_subs/data/models/subscription.dart';
import 'package:custom_subs/data/models/subscription_cycle.dart';
import 'package:custom_subs/data/models/subscription_category.dart';
import 'package:custom_subs/data/models/reminder_config.dart';
import 'package:custom_subs/app/app.dart';

/// Integration smoke test: verifies the app launches and renders without crash.
///
/// Initializes real Hive (in-memory) and timezone, but skips PostHog and
/// RevenueCat via provider overrides.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Initialize Hive
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SubscriptionAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SubscriptionCycleAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SubscriptionCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(ReminderConfigAdapter());
    }

    // Initialize timezone
    tzdata.initializeTimeZones();
  });

  testWidgets('app launches without crash', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CustomSubsApp(),
      ),
    );

    // Wait for initial async operations (Hive box open, FutureBuilder, etc.)
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify the app rendered a MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
