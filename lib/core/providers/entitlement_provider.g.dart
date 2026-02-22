// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isPremiumHash() => r'e79099073099aa41864d06987eae22faf56ce53a';

/// Provider for checking if user has premium entitlement.
///
/// This is a FutureProvider that fetches the current premium status
/// from RevenueCat. It caches the result and can be invalidated
/// after purchases to refresh the state.
///
/// Usage:
/// ```dart
/// final isPremium = ref.watch(isPremiumProvider);
/// isPremium.when(
///   data: (hasPremium) => hasPremium ? Text('Premium') : Text('Free'),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error'),
/// );
/// ```
///
/// Copied from [isPremium].
@ProviderFor(isPremium)
final isPremiumProvider = AutoDisposeFutureProvider<bool>.internal(
  isPremium,
  name: r'isPremiumProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isPremiumHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsPremiumRef = AutoDisposeFutureProviderRef<bool>;
String _$entitlementServiceHash() =>
    r'4887a278ad6227678cdd59faeb36b88094aa688b';

/// Provider for EntitlementService singleton.
///
/// Provides access to the EntitlementService for purchase flows.
///
/// Usage:
/// ```dart
/// final service = ref.read(entitlementServiceProvider);
/// final success = await service.purchaseMonthlySubscription();
/// ```
///
/// Copied from [entitlementService].
@ProviderFor(entitlementService)
final entitlementServiceProvider =
    AutoDisposeProvider<EntitlementService>.internal(
  entitlementService,
  name: r'entitlementServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$entitlementServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EntitlementServiceRef = AutoDisposeProviderRef<EntitlementService>;
String _$isInFreeTrialHash() => r'4a3e2a78acc893183ce082a6cedd749e51f40f7d';

/// Provider for checking if user is in free trial.
///
/// Returns true if user has active premium trial that hasn't expired yet.
///
/// Usage:
/// ```dart
/// final isTrialAsync = ref.watch(isInFreeTrialProvider);
/// isTrialAsync.when(
///   data: (inTrial) => inTrial ? Text('On Trial') : Text('Not on Trial'),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error'),
/// );
/// ```
///
/// Copied from [isInFreeTrial].
@ProviderFor(isInFreeTrial)
final isInFreeTrialProvider = AutoDisposeFutureProvider<bool>.internal(
  isInFreeTrial,
  name: r'isInFreeTrialProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isInFreeTrialHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsInFreeTrialRef = AutoDisposeFutureProviderRef<bool>;
String _$trialRemainingDaysHash() =>
    r'5d310260c797adb19a15137b62da238831a1b173';

/// Provider for getting remaining trial days.
///
/// Returns number of days remaining in trial, or 0 if no trial.
///
/// Usage:
/// ```dart
/// final daysAsync = ref.watch(trialRemainingDaysProvider);
/// daysAsync.when(
///   data: (days) => Text('$days days remaining'),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error'),
/// );
/// ```
///
/// Copied from [trialRemainingDays].
@ProviderFor(trialRemainingDays)
final trialRemainingDaysProvider = AutoDisposeFutureProvider<int>.internal(
  trialRemainingDays,
  name: r'trialRemainingDaysProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$trialRemainingDaysHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TrialRemainingDaysRef = AutoDisposeFutureProviderRef<int>;
String _$trialEndDateHash() => r'5cd819a066c8c19e5d43d2d623bd89c45651170a';

/// Provider for getting trial end date.
///
/// Returns DateTime when trial expires, or null if no active trial.
///
/// Usage:
/// ```dart
/// final endDateAsync = ref.watch(trialEndDateProvider);
/// endDateAsync.when(
///   data: (date) => date != null
///     ? Text('Expires: ${date.toLocal()}')
///     : Text('No trial'),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error'),
/// );
/// ```
///
/// Copied from [trialEndDate].
@ProviderFor(trialEndDate)
final trialEndDateProvider = AutoDisposeFutureProvider<DateTime?>.internal(
  trialEndDate,
  name: r'trialEndDateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$trialEndDateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TrialEndDateRef = AutoDisposeFutureProviderRef<DateTime?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
