library;

/// Centralized error handling utilities for CustomSubs.
///
/// Provides user-friendly error messages and standardized error handling
/// across all async operations in the app.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:custom_subs/core/utils/snackbar_utils.dart';

/// Custom exception types for better error categorization
class StorageException implements Exception {
  final String message;
  StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}

class NotificationException implements Exception {
  final String message;
  NotificationException(this.message);

  @override
  String toString() => 'NotificationException: $message';
}

class FileOperationException implements Exception {
  final String message;
  FileOperationException(this.message);

  @override
  String toString() => 'FileOperationException: $message';
}

class ParseException implements Exception {
  final String message;
  ParseException(this.message);

  @override
  String toString() => 'ParseException: $message';
}

/// Error handler utility for converting exceptions to user-friendly messages
class ErrorHandler {
  /// Converts an exception to a user-friendly error message
  static String getUserMessage(Object error, {String? context}) {
    // Custom exceptions
    if (error is StorageException) {
      return 'Failed to save data: ${error.message}';
    }
    if (error is NotificationException) {
      return 'Failed to schedule notification: ${error.message}';
    }
    if (error is FileOperationException) {
      return 'File operation failed: ${error.message}';
    }
    if (error is ParseException) {
      return 'Failed to parse data: ${error.message}';
    }

    // System exceptions
    if (error is FileSystemException) {
      return 'File system error: ${error.message}';
    }
    if (error is FormatException) {
      return 'Invalid data format: ${error.message}';
    }
    if (error is IOException) {
      return 'I/O error: ${error.toString()}';
    }

    // Fallback
    final contextStr = context != null ? ' ($context)' : '';
    return 'An unexpected error occurred$contextStr. Please try again.';
  }

  /// Executes an async operation with error handling
  /// Returns result on success, null on error
  /// Shows snackbar with error message if context is provided
  static Future<T?> handleAsync<T>(
    Future<T> Function() operation, {
    BuildContext? context,
    String? errorContext,
    bool showSnackbar = true,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      debugPrint('Error in ${errorContext ?? 'async operation'}: $error');
      debugPrint('Stack trace: $stackTrace');

      if (context != null && context.mounted && showSnackbar) {
        final message = getUserMessage(error, context: errorContext);
        SnackBarUtils.show(
          context,
          SnackBarUtils.error(message),
        );
      }

      return null;
    }
  }

  /// Executes a sync operation with error handling
  /// Returns result on success, null on error
  static T? handleSync<T>(
    T Function() operation, {
    BuildContext? context,
    String? errorContext,
    bool showSnackbar = true,
  }) {
    try {
      return operation();
    } catch (error, stackTrace) {
      debugPrint('Error in ${errorContext ?? 'sync operation'}: $error');
      debugPrint('Stack trace: $stackTrace');

      if (context != null && context.mounted && showSnackbar) {
        final message = getUserMessage(error, context: errorContext);
        SnackBarUtils.show(
          context,
          SnackBarUtils.error(message),
        );
      }

      return null;
    }
  }

  /// Shows an error dialog with detailed information
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? details,
  }) async {
    if (!context.mounted) return;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (details != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Details:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                details,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
