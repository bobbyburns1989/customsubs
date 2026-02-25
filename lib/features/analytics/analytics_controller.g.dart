// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$analyticsControllerHash() =>
    r'd2dc58c953ca1663c0bcd9859a56edd506a79bad';

/// Controller for the Analytics screen.
///
/// Provides spending analytics including:
/// - Yearly forecast (primary hero metric)
/// - Category breakdown with percentages
/// - Top 5 subscriptions by monthly cost
/// - Multi-currency breakdown
///
/// Automatically saves a monthly snapshot when the analytics screen is opened
/// (once per month, not on every visit). Monthly snapshots are preserved for
/// future features but currently not displayed in the UI.
///
/// Copied from [AnalyticsController].
@ProviderFor(AnalyticsController)
final analyticsControllerProvider = AutoDisposeAsyncNotifierProvider<
    AnalyticsController, AnalyticsData>.internal(
  AnalyticsController.new,
  name: r'analyticsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$analyticsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AnalyticsController = AutoDisposeAsyncNotifier<AnalyticsData>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
