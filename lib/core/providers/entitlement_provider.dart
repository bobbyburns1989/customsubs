/// Riverpod provider for subscription entitlement state.
///
/// Provides reactive access to premium subscription status throughout the app.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:custom_subs/data/services/entitlement_service.dart';

part 'entitlement_provider.g.dart';

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
@riverpod
Future<bool> isPremium(IsPremiumRef ref) async {
  final entitlementService = EntitlementService.instance;
  return await entitlementService.hasPremiumEntitlement();
}

/// Provider for EntitlementService singleton.
///
/// Provides access to the EntitlementService for purchase flows.
///
/// Usage:
/// ```dart
/// final service = ref.read(entitlementServiceProvider);
/// final success = await service.purchaseMonthlySubscription();
/// ```
@riverpod
EntitlementService entitlementService(EntitlementServiceRef ref) {
  return EntitlementService.instance;
}

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
@riverpod
Future<bool> isInFreeTrial(IsInFreeTrialRef ref) async {
  final entitlementService = EntitlementService.instance;
  return await entitlementService.isInFreeTrial();
}

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
@riverpod
Future<int> trialRemainingDays(TrialRemainingDaysRef ref) async {
  final entitlementService = EntitlementService.instance;
  return await entitlementService.getRemainingTrialDays();
}

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
@riverpod
Future<DateTime?> trialEndDate(TrialEndDateRef ref) async {
  final entitlementService = EntitlementService.instance;
  return await entitlementService.getTrialEndDate();
}
