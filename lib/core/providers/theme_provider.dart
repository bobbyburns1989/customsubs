import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_subs/core/providers/settings_provider.dart';

part 'theme_provider.g.dart';

/// Provides the current [ThemeMode] based on persisted dark mode setting.
@riverpod
ThemeMode themeMode(Ref ref) {
  final settingsAsync = ref.watch(settingsRepositoryProvider);

  return settingsAsync.when(
    data: (_) {
      final repository = ref.read(settingsRepositoryProvider.notifier);
      return repository.getIsDarkMode() ? ThemeMode.dark : ThemeMode.light;
    },
    loading: () => ThemeMode.light,
    error: (_, __) => ThemeMode.light,
  );
}
