// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_subscription_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$addSubscriptionControllerHash() =>
    r'deca5e16fa0d2fdea261cfdef600af21143dca38';

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

abstract class _$AddSubscriptionController
    extends BuildlessAutoDisposeAsyncNotifier<Subscription?> {
  late final String? subscriptionId;

  FutureOr<Subscription?> build(
    String? subscriptionId,
  );
}

/// See also [AddSubscriptionController].
@ProviderFor(AddSubscriptionController)
const addSubscriptionControllerProvider = AddSubscriptionControllerFamily();

/// See also [AddSubscriptionController].
class AddSubscriptionControllerFamily
    extends Family<AsyncValue<Subscription?>> {
  /// See also [AddSubscriptionController].
  const AddSubscriptionControllerFamily();

  /// See also [AddSubscriptionController].
  AddSubscriptionControllerProvider call(
    String? subscriptionId,
  ) {
    return AddSubscriptionControllerProvider(
      subscriptionId,
    );
  }

  @override
  AddSubscriptionControllerProvider getProviderOverride(
    covariant AddSubscriptionControllerProvider provider,
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
  String? get name => r'addSubscriptionControllerProvider';
}

/// See also [AddSubscriptionController].
class AddSubscriptionControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<AddSubscriptionController,
        Subscription?> {
  /// See also [AddSubscriptionController].
  AddSubscriptionControllerProvider(
    String? subscriptionId,
  ) : this._internal(
          () => AddSubscriptionController()..subscriptionId = subscriptionId,
          from: addSubscriptionControllerProvider,
          name: r'addSubscriptionControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$addSubscriptionControllerHash,
          dependencies: AddSubscriptionControllerFamily._dependencies,
          allTransitiveDependencies:
              AddSubscriptionControllerFamily._allTransitiveDependencies,
          subscriptionId: subscriptionId,
        );

  AddSubscriptionControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.subscriptionId,
  }) : super.internal();

  final String? subscriptionId;

  @override
  FutureOr<Subscription?> runNotifierBuild(
    covariant AddSubscriptionController notifier,
  ) {
    return notifier.build(
      subscriptionId,
    );
  }

  @override
  Override overrideWith(AddSubscriptionController Function() create) {
    return ProviderOverride(
      origin: this,
      override: AddSubscriptionControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<AddSubscriptionController,
      Subscription?> createElement() {
    return _AddSubscriptionControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AddSubscriptionControllerProvider &&
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
mixin AddSubscriptionControllerRef
    on AutoDisposeAsyncNotifierProviderRef<Subscription?> {
  /// The parameter `subscriptionId` of this provider.
  String? get subscriptionId;
}

class _AddSubscriptionControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<AddSubscriptionController,
        Subscription?> with AddSubscriptionControllerRef {
  _AddSubscriptionControllerProviderElement(super.provider);

  @override
  String? get subscriptionId =>
      (origin as AddSubscriptionControllerProvider).subscriptionId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
