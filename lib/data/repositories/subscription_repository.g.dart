// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$subscriptionRepositoryHash() =>
    r'9ee4ac64588be8bcbf14a120df921ab267e1268e';

/// See also [subscriptionRepository].
@ProviderFor(subscriptionRepository)
final subscriptionRepositoryProvider =
    AutoDisposeFutureProvider<SubscriptionRepository>.internal(
  subscriptionRepository,
  name: r'subscriptionRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$subscriptionRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SubscriptionRepositoryRef
    = AutoDisposeFutureProviderRef<SubscriptionRepository>;
String _$activeSubscriptionsHash() =>
    r'cc97c383701041291b26a402a07560c21e45b27a';

/// See also [activeSubscriptions].
@ProviderFor(activeSubscriptions)
final activeSubscriptionsProvider =
    AutoDisposeStreamProvider<List<Subscription>>.internal(
  activeSubscriptions,
  name: r'activeSubscriptionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeSubscriptionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveSubscriptionsRef
    = AutoDisposeStreamProviderRef<List<Subscription>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
