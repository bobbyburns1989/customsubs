// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$primaryCurrencyHash() => r'64c91bb5fe5920f0b1041051cf7d21a9e55b02ad';

/// Provider for primary currency (reactive)
///
/// Copied from [primaryCurrency].
@ProviderFor(primaryCurrency)
final primaryCurrencyProvider = AutoDisposeProvider<String>.internal(
  primaryCurrency,
  name: r'primaryCurrencyProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$primaryCurrencyHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PrimaryCurrencyRef = AutoDisposeProviderRef<String>;
String _$settingsRepositoryHash() =>
    r'882657a4e3046e4140192353d788c73f62028934';

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
///
/// Copied from [SettingsRepository].
@ProviderFor(SettingsRepository)
final settingsRepositoryProvider =
    AutoDisposeAsyncNotifierProvider<SettingsRepository, void>.internal(
  SettingsRepository.new,
  name: r'settingsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SettingsRepository = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
