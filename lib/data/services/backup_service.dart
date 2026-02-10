import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:custom_subs/data/models/subscription.dart';
import 'package:custom_subs/data/repositories/subscription_repository.dart';
import 'package:custom_subs/data/services/notification_service.dart';
import 'package:custom_subs/core/providers/settings_provider.dart';

part 'backup_service.g.dart';

/// Backup service for exporting and importing subscription data.
///
/// Provides data safety features:
/// - Export subscriptions to JSON file
/// - Import subscriptions from JSON file
/// - Share exported files via system share sheet
/// - Duplicate detection on import
/// - Notification rescheduling after import
///
/// ## Usage
/// ```dart
/// final backupService = await ref.read(backupServiceProvider.future);
/// await backupService.exportAndShare();
/// ```
class BackupService {
  static const String appName = 'CustomSubs';
  static const String appVersion = '1.0.0';

  /// Export all subscriptions to JSON format.
  ///
  /// Returns JSON string with metadata header and all subscriptions.
  /// Format:
  /// ```json
  /// {
  ///   "app": "CustomSubs",
  ///   "version": "1.0.0",
  ///   "exportDate": "2026-02-04T14:30:00Z",
  ///   "subscriptionCount": 12,
  ///   "subscriptions": [...]
  /// }
  /// ```
  Future<String> exportToJson(List<Subscription> subscriptions) async {
    final exportData = {
      'app': appName,
      'version': appVersion,
      'exportDate': DateTime.now().toIso8601String(),
      'subscriptionCount': subscriptions.length,
      'subscriptions': subscriptions.map((sub) => sub.toJson()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  /// Export subscriptions and share via system share sheet.
  ///
  /// Creates a temporary JSON file and opens the share sheet,
  /// allowing users to save to Files, email, AirDrop, cloud storage, etc.
  ///
  /// [sharePositionOrigin] is required for iOS/iPadOS to position the share sheet popover.
  Future<void> exportAndShare(
    List<Subscription> subscriptions, {
    Rect? sharePositionOrigin,
  }) async {
    try {
      // Generate JSON
      final jsonContent = await exportToJson(subscriptions);

      // Create temporary file
      final directory = await getTemporaryDirectory();
      final fileName = _generateBackupFileName();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonContent);

      // Share file with position origin for iOS
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'CustomSubs Backup - ${DateTime.now().toString().split(' ')[0]}',
        text: 'CustomSubs subscription backup file',
        sharePositionOrigin: sharePositionOrigin,
      );

      // Clean up temporary file after sharing
      if (result.status == ShareResultStatus.success) {
        await file.delete();
      }
    } catch (e) {
      throw BackupException('Failed to export backup: $e');
    }
  }

  /// Import subscriptions from a backup file.
  ///
  /// Opens file picker, validates JSON, detects duplicates, and imports.
  /// Returns the number of subscriptions imported (excluding duplicates).
  Future<ImportResult> importFromFile(
    List<Subscription> existingSubscriptions,
  ) async {
    try {
      // Open file picker
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        throw BackupException('No file selected');
      }

      final file = result.files.first;
      final String fileContent;

      if (file.path != null) {
        // For mobile platforms with file path
        fileContent = await File(file.path!).readAsString();
      } else if (file.bytes != null) {
        // For web platform with bytes
        fileContent = utf8.decode(file.bytes!);
      } else {
        throw BackupException('Unable to read file content');
      }

      // Parse and validate backup
      final parsedData = await parseBackupFile(fileContent);

      // Detect duplicates
      final duplicates = _detectDuplicates(parsedData, existingSubscriptions);
      final newSubscriptions =
          parsedData.where((sub) => !duplicates.contains(sub)).toList();

      return ImportResult(
        totalFound: parsedData.length,
        duplicates: duplicates.length,
        imported: newSubscriptions.length,
        subscriptions: newSubscriptions,
      );
    } catch (e) {
      if (e is BackupException) rethrow;
      throw BackupException('Failed to import backup: $e');
    }
  }

  /// Parse and validate a backup JSON file.
  ///
  /// Throws [BackupException] if:
  /// - JSON is invalid
  /// - Required fields are missing
  /// - App name doesn't match
  Future<List<Subscription>> parseBackupFile(String jsonContent) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonContent);

      // Validate backup format
      if (data['app'] != appName) {
        throw BackupException(
          'Invalid backup file: expected $appName backup, got ${data['app']}',
        );
      }

      if (data['subscriptions'] == null) {
        throw BackupException('Invalid backup file: missing subscriptions data');
      }

      // Parse subscriptions
      final List<dynamic> subscriptionsJson = data['subscriptions'];
      final subscriptions = subscriptionsJson
          .map((json) => Subscription.fromJson(json as Map<String, dynamic>))
          .toList();

      return subscriptions;
    } on FormatException catch (e) {
      throw BackupException('Invalid JSON format: $e');
    } catch (e) {
      if (e is BackupException) rethrow;
      throw BackupException('Failed to parse backup file: $e');
    }
  }

  /// Detect duplicate subscriptions.
  ///
  /// Duplicates are identified by matching:
  /// - Name (case-insensitive)
  /// - Amount
  /// - Billing cycle
  List<Subscription> _detectDuplicates(
    List<Subscription> newSubscriptions,
    List<Subscription> existingSubscriptions,
  ) {
    final duplicates = <Subscription>[];

    for (final newSub in newSubscriptions) {
      final isDuplicate = existingSubscriptions.any((existing) {
        return existing.name.toLowerCase() == newSub.name.toLowerCase() &&
            existing.amount == newSub.amount &&
            existing.cycle == newSub.cycle;
      });

      if (isDuplicate) {
        duplicates.add(newSub);
      }
    }

    return duplicates;
  }

  /// Generate backup file name with current date.
  ///
  /// Format: customsubs_backup_YYYY-MM-DD.json
  String _generateBackupFileName() {
    final date = DateTime.now();
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return 'customsubs_backup_$dateStr.json';
  }
}

/// Result of an import operation
class ImportResult {
  final int totalFound;
  final int duplicates;
  final int imported;
  final List<Subscription> subscriptions;

  ImportResult({
    required this.totalFound,
    required this.duplicates,
    required this.imported,
    required this.subscriptions,
  });
}

/// Exception thrown when backup operations fail
class BackupException implements Exception {
  final String message;

  BackupException(this.message);

  @override
  String toString() => 'BackupException: $message';
}

/// Riverpod provider for backup service
@riverpod
Future<BackupService> backupService(Ref ref) async {
  return BackupService();
}

/// Export backup with all current subscriptions
@riverpod
Future<void> exportBackup(Ref ref) async {
  final backupService = await ref.read(backupServiceProvider.future);
  final repository = await ref.read(subscriptionRepositoryProvider.future);
  final subscriptions = repository.getAllActive();

  // Note: sharePositionOrigin should be passed when calling exportAndShare directly
  await backupService.exportAndShare(subscriptions);

  // Update last backup date in settings
  final settingsRepo = ref.read(settingsRepositoryProvider.notifier);
  await settingsRepo.setLastBackupDate(DateTime.now());
}

/// Import backup and reschedule notifications
@riverpod
Future<ImportResult> importBackup(Ref ref) async {
  final backupService = await ref.read(backupServiceProvider.future);
  final repository = await ref.read(subscriptionRepositoryProvider.future);
  final existingSubscriptions = repository.getAllActive();

  // Import subscriptions
  final result = await backupService.importFromFile(existingSubscriptions);

  // Save new subscriptions to repository
  for (final subscription in result.subscriptions) {
    await repository.upsert(subscription);
  }

  // Reschedule notifications for all new subscriptions
  if (result.subscriptions.isNotEmpty) {
    final notificationService = await ref.read(notificationServiceProvider.future);
    for (final subscription in result.subscriptions) {
      await notificationService.scheduleNotificationsForSubscription(subscription);
    }
  }

  return result;
}
