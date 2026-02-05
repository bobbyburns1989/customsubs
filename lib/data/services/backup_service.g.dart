// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$backupServiceHash() => r'5bb98c7f822abaf8ce1cc69788ce9df70f4cdddc';

/// Riverpod provider for backup service
///
/// Copied from [backupService].
@ProviderFor(backupService)
final backupServiceProvider = AutoDisposeFutureProvider<BackupService>.internal(
  backupService,
  name: r'backupServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$backupServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BackupServiceRef = AutoDisposeFutureProviderRef<BackupService>;
String _$exportBackupHash() => r'93d777d2e6632cfe11ecece67648d68036b8bd78';

/// Export backup with all current subscriptions
///
/// Copied from [exportBackup].
@ProviderFor(exportBackup)
final exportBackupProvider = AutoDisposeFutureProvider<void>.internal(
  exportBackup,
  name: r'exportBackupProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$exportBackupHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExportBackupRef = AutoDisposeFutureProviderRef<void>;
String _$importBackupHash() => r'8ff9462dfd9b88eab5e2af150da3a0537216184b';

/// Import backup and reschedule notifications
///
/// Copied from [importBackup].
@ProviderFor(importBackup)
final importBackupProvider = AutoDisposeFutureProvider<ImportResult>.internal(
  importBackup,
  name: r'importBackupProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$importBackupHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ImportBackupRef = AutoDisposeFutureProviderRef<ImportResult>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
