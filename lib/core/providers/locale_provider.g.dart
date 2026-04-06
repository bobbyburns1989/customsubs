// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appLocaleHash() => r'becbe22d972a0e96d882ca5db23cd039ac8f4d44';

/// Provides the current [Locale] based on persisted user preference.
///
/// Returns null when "System Default" is selected, which tells MaterialApp
/// to use the device's system locale (falling back to English if unsupported).
///
/// Copied from [appLocale].
@ProviderFor(appLocale)
final appLocaleProvider = AutoDisposeProvider<Locale?>.internal(
  appLocale,
  name: r'appLocaleProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appLocaleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppLocaleRef = AutoDisposeProviderRef<Locale?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
