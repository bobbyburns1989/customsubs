import 'dart:io';
import 'package:hive/hive.dart';
import 'package:custom_subs/data/models/subscription.dart';
import 'package:custom_subs/data/models/subscription_cycle.dart';
import 'package:custom_subs/data/models/subscription_category.dart';
import 'package:custom_subs/data/models/reminder_config.dart';

/// Provides real Hive initialization for repository tests.
///
/// Uses a temp directory so tests are isolated and don't affect app data.
/// Call [initTestHive] in setUp and [cleanupTestHive] in tearDown.
class HiveTestUtils {
  static Directory? _tempDir;

  /// Initialize Hive with a temp directory and register all adapters.
  static Future<void> initTestHive() async {
    _tempDir = await Directory.systemTemp.createTemp('customsubs_test_');
    Hive.init(_tempDir!.path);

    // Register adapters if not already registered
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
  }

  /// Close Hive and clean up temp directory.
  static Future<void> cleanupTestHive() async {
    await Hive.close();
    if (_tempDir != null && _tempDir!.existsSync()) {
      await _tempDir!.delete(recursive: true);
    }
    _tempDir = null;
  }
}
