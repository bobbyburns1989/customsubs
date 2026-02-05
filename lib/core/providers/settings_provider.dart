import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'settings_provider.g.dart';

/// Settings provider for app-wide preferences.
///
/// Stores user preferences in Hive local storage:
/// - Primary currency for totals and display
/// - Default reminder time for new subscriptions
/// - Onboarding completion status
/// - Backup reminder shown status
///
/// ## Usage
/// ```dart
/// // Read primary currency
/// final currency = ref.watch(primaryCurrencyProvider);
///
/// // Update primary currency
/// await ref.read(settingsRepositoryProvider).setPrimaryCurrency('EUR');
/// ```
@riverpod
class SettingsRepository extends _$SettingsRepository {
  static const String _boxName = 'settings';
  static const String _primaryCurrencyKey = 'primary_currency';
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String _defaultReminderHourKey = 'default_reminder_hour';
  static const String _defaultReminderMinuteKey = 'default_reminder_minute';
  static const String _backupReminderShownKey = 'backup_reminder_shown';
  static const String _lastBackupDateKey = 'last_backup_date';

  Box? _box;

  @override
  FutureOr<void> build() async {
    _box = await Hive.openBox(_boxName);
    return null;
  }

  Box get _getBox {
    if (_box == null || !_box!.isOpen) {
      throw Exception('SettingsRepository not initialized. Call build() first.');
    }
    return _box!;
  }

  // Primary Currency

  /// Get primary currency (default: USD)
  String getPrimaryCurrency() {
    return _getBox.get(_primaryCurrencyKey, defaultValue: 'USD') as String;
  }

  /// Set primary currency
  Future<void> setPrimaryCurrency(String currencyCode) async {
    await _getBox.put(_primaryCurrencyKey, currencyCode);
    // Invalidate self to trigger rebuild
    ref.invalidateSelf();
  }

  // Onboarding

  /// Check if user has completed onboarding
  bool hasSeenOnboarding() {
    return _getBox.get(_hasSeenOnboardingKey, defaultValue: false) as bool;
  }

  /// Mark onboarding as complete
  Future<void> setOnboardingComplete() async {
    await _getBox.put(_hasSeenOnboardingKey, true);
  }

  // Default Reminder Time

  /// Get default reminder hour (default: 9 AM)
  int getDefaultReminderHour() {
    return _getBox.get(_defaultReminderHourKey, defaultValue: 9) as int;
  }

  /// Get default reminder minute (default: 0)
  int getDefaultReminderMinute() {
    return _getBox.get(_defaultReminderMinuteKey, defaultValue: 0) as int;
  }

  /// Set default reminder time
  Future<void> setDefaultReminderTime(int hour, int minute) async {
    await _getBox.put(_defaultReminderHourKey, hour);
    await _getBox.put(_defaultReminderMinuteKey, minute);
  }

  // Backup Reminder

  /// Check if backup reminder has been shown
  bool hasShownBackupReminder() {
    return _getBox.get(_backupReminderShownKey, defaultValue: false) as bool;
  }

  /// Mark backup reminder as shown
  Future<void> setBackupReminderShown() async {
    await _getBox.put(_backupReminderShownKey, true);
  }

  // Last Backup Date

  /// Get last backup date (null if never backed up)
  DateTime? getLastBackupDate() {
    final timestamp = _getBox.get(_lastBackupDateKey) as String?;
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  /// Update last backup date
  Future<void> setLastBackupDate(DateTime date) async {
    await _getBox.put(_lastBackupDateKey, date.toIso8601String());
  }
}

/// Provider for primary currency (reactive)
@riverpod
String primaryCurrency(Ref ref) {
  // Watch the settings repository
  final settingsAsync = ref.watch(settingsRepositoryProvider);

  return settingsAsync.when(
    data: (_) {
      final repository = ref.read(settingsRepositoryProvider.notifier);
      return repository.getPrimaryCurrency();
    },
    loading: () => 'USD',
    error: (_, __) => 'USD',
  );
}
