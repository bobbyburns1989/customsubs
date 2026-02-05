// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$subscriptionDetailControllerHash() =>
    r'8c60538fb73c37f9ce68c7e2677e4c3101ac0348';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$SubscriptionDetailController
    extends BuildlessAutoDisposeAsyncNotifier<Subscription?> {
  late final String subscriptionId;

  FutureOr<Subscription?> build(
    String subscriptionId,
  );
}

/// Controller for subscription detail screen.
///
/// Provides actions for:
/// - Toggling paid status
/// - Toggling active/paused status
/// - Updating checklist items
/// - Deleting subscription
///
/// Copied from [SubscriptionDetailController].
@ProviderFor(SubscriptionDetailController)
const subscriptionDetailControllerProvider =
    SubscriptionDetailControllerFamily();

/// Controller for subscription detail screen.
///
/// Provides actions for:
/// - Toggling paid status
/// - Toggling active/paused status
/// - Updating checklist items
/// - Deleting subscription
///
/// Copied from [SubscriptionDetailController].
class SubscriptionDetailControllerFamily
    extends Family<AsyncValue<Subscription?>> {
  /// Controller for subscription detail screen.
  ///
  /// Provides actions for:
  /// - Toggling paid status
  /// - Toggling active/paused status
  /// - Updating checklist items
  /// - Deleting subscription
  ///
  /// Copied from [SubscriptionDetailController].
  const SubscriptionDetailControllerFamily();

  /// Controller for subscription detail screen.
  ///
  /// Provides actions for:
  /// - Toggling paid status
  /// - Toggling active/paused status
  /// - Updating checklist items
  /// - Deleting subscription
  ///
  /// Copied from [SubscriptionDetailController].
  SubscriptionDetailControllerProvider call(
    String subscriptionId,
  ) {
    return SubscriptionDetailControllerProvider(
      subscriptionId,
    );
  }

  @override
  SubscriptionDetailControllerProvider getProviderOverride(
    covariant SubscriptionDetailControllerProvider provider,
  ) {
    return call(
      provider.subscriptionId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'subscriptionDetailControllerProvider';
}

/// Controller for subscription detail screen.
///
/// Provides actions for:
/// - Toggling paid status
/// - Toggling active/paused status
/// - Updating checklist items
/// - Deleting subscription
///
/// Copied from [SubscriptionDetailController].
class SubscriptionDetailControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<SubscriptionDetailController,
        Subscription?> {
  /// Controller for subscription detail screen.
  ///
  /// Provides actions for:
  /// - Toggling paid status
  /// - Toggling active/paused status
  /// - Updating checklist items
  /// - Deleting subscription
  ///
  /// Copied from [SubscriptionDetailController].
  SubscriptionDetailControllerProvider(
    String subscriptionId,
  ) : this._internal(
          () => SubscriptionDetailController()..subscriptionId = subscriptionId,
          from: subscriptionDetailControllerProvider,
          name: r'subscriptionDetailControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$subscriptionDetailControllerHash,
          dependencies: SubscriptionDetailControllerFamily._dependencies,
          allTransitiveDependencies:
              SubscriptionDetailControllerFamily._allTransitiveDependencies,
          subscriptionId: subscriptionId,
        );

  SubscriptionDetailControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.subscriptionId,
  }) : super.internal();

  final String subscriptionId;

  @override
  FutureOr<Subscription?> runNotifierBuild(
    covariant SubscriptionDetailController notifier,
  ) {
    return notifier.build(
      subscriptionId,
    );
  }

  @override
  Override overrideWith(SubscriptionDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: SubscriptionDetailControllerProvider._internal(
        () => create()..subscriptionId = subscriptionId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        subscriptionId: subscriptionId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<SubscriptionDetailController,
      Subscription?> createElement() {
    return _SubscriptionDetailControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SubscriptionDetailControllerProvider &&
        other.subscriptionId == subscriptionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, subscriptionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SubscriptionDetailControllerRef
    on AutoDisposeAsyncNotifierProviderRef<Subscription?> {
  /// The parameter `subscriptionId` of this provider.
  String get subscriptionId;
}

class _SubscriptionDetailControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<
        SubscriptionDetailController,
        Subscription?> with SubscriptionDetailControllerRef {
  _SubscriptionDetailControllerProviderElement(super.provider);

  @override
  String get subscriptionId =>
      (origin as SubscriptionDetailControllerProvider).subscriptionId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
