import 'dart:ui';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_subs/core/providers/settings_provider.dart';

part 'locale_provider.g.dart';

/// Supported locales for the app.
const supportedLocaleCodes = ['en', 'fr', 'es'];

/// Provides the current [Locale] based on persisted user preference.
///
/// Returns null when "System Default" is selected, which tells MaterialApp
/// to use the device's system locale (falling back to English if unsupported).
@riverpod
Locale? appLocale(Ref ref) {
  final settingsAsync = ref.watch(settingsRepositoryProvider);

  return settingsAsync.when(
    data: (_) {
      final repository = ref.read(settingsRepositoryProvider.notifier);
      final localeCode = repository.getAppLocale();
      // null = system default (let MaterialApp resolve)
      if (localeCode == null) return null;
      return Locale(localeCode);
    },
    loading: () => null,
    error: (_, __) => null,
  );
}
