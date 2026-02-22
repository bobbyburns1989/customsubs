/// Deep linking router for handling notification taps and actions.
///
/// Routes users to the appropriate screens when they interact with notifications,
/// including support for notification action buttons like "Mark as Paid" and "View Details".
library;

import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

/// Handles notification tap callbacks and routes to appropriate screens.
///
/// **Responsibilities:**
/// - Parse notification payloads (JSON with subscriptionId + action)
/// - Navigate to subscription detail screens via GoRouter
/// - Execute notification actions (view detail, mark as paid)
/// - Handle background vs foreground actions
///
/// **Integration:**
/// Called from NotificationService during initialization via
/// `onDidReceiveNotificationResponse` callback.
///
/// **Payload Format:**
/// ```json
/// {
///   "subscriptionId": "uuid-string",
///   "action": "view_detail" | "mark_paid"
/// }
/// ```
///
/// **Usage:**
/// ```dart
/// // In app/router.dart, store the router instance:
/// final router = GoRouter(...);
/// NotificationRouter.setRouter(router);
///
/// // In NotificationService.init():
/// await _notifications.initialize(
///   initSettings,
///   onDidReceiveNotificationResponse: NotificationRouter.handleNotificationResponse,
/// );
/// ```
class NotificationRouter {
  NotificationRouter._(); // Private constructor - static utility class

  /// Stored GoRouter instance for navigation without BuildContext.
  ///
  /// Set via [setRouter] during app initialization. This allows the
  /// notification callback to navigate without access to a BuildContext.
  static GoRouter? _router;

  /// Stores the GoRouter instance for use in notification callbacks.
  ///
  /// **Must be called during app initialization** before notifications can
  /// navigate successfully.
  ///
  /// **Usage:**
  /// ```dart
  /// // In app/router.dart or main.dart:
  /// final router = AppRouter.router(hasSeenOnboarding);
  /// NotificationRouter.setRouter(router);
  /// ```
  ///
  /// **Parameters:**
  /// - [router]: The app's GoRouter instance
  static void setRouter(GoRouter router) {
    _router = router;
  }

  /// Handles notification tap or action button press.
  ///
  /// Called automatically by flutter_local_notifications when:
  /// - User taps notification body
  /// - User taps an action button ("Mark as Paid", "View Details")
  ///
  /// **Behavior:**
  /// - Parses JSON payload to extract subscriptionId and action type
  /// - Navigates to subscription detail screen via GoRouter
  /// - For "mark_paid" action: passes extra parameter to auto-toggle paid status
  /// - For "view_detail" action: simple navigation to detail screen
  ///
  /// **Error Handling:**
  /// - Silent failure if payload is invalid or missing
  /// - Silent failure if subscriptionId is null
  /// - Silent failure if router not set
  /// - Logs errors to debug console
  ///
  /// **Parameters:**
  /// - [response]: Notification response from flutter_local_notifications
  ///
  /// **Example Flow:**
  /// 1. User taps "Mark as Paid" on notification
  /// 2. Callback receives response with payload: `{"subscriptionId": "123", "action": "mark_paid"}`
  /// 3. Router navigates to `/subscription/123` with `extra: {'autoMarkPaid': true}`
  /// 4. SubscriptionDetailScreen receives autoMarkPaid parameter
  /// 5. Screen auto-toggles paid status in initState
  static Future<void> handleNotificationResponse(
    NotificationResponse response,
  ) async {
    // Early return if no payload
    final payload = response.payload;
    if (payload == null || payload.isEmpty) {
      debugPrint('NotificationRouter: No payload in notification response');
      return;
    }

    // Early return if router not initialized
    if (_router == null) {
      debugPrint('NotificationRouter: Router not initialized. Call setRouter() first.');
      return;
    }

    try {
      // Parse JSON payload
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final subscriptionId = data['subscriptionId'] as String?;
      final action = data['action'] as String? ?? 'view_detail';

      // Validate subscription ID
      if (subscriptionId == null || subscriptionId.isEmpty) {
        debugPrint('NotificationRouter: Missing subscriptionId in payload');
        return;
      }

      debugPrint('NotificationRouter: Handling action "$action" for subscription $subscriptionId');

      // Route based on action type
      switch (action) {
        case 'mark_paid':
          // Navigate to detail screen with auto-mark flag
          // The screen will automatically toggle paid status in initState
          _router!.push(
            '/subscription/$subscriptionId',
            extra: {'autoMarkPaid': true},
          );
          break;

        case 'view_detail':
        default:
          // Simple navigation to detail screen (default behavior)
          _router!.push('/subscription/$subscriptionId');
      }
    } catch (e, stackTrace) {
      // Silent failure - don't crash the app
      // Log error for debugging
      debugPrint('NotificationRouter: Error handling notification response: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Creates a JSON payload for notification with subscription metadata.
  ///
  /// **Usage:**
  /// ```dart
  /// final payload = NotificationRouter.createPayload(
  ///   subscriptionId: subscription.id,
  ///   action: 'mark_paid', // or 'view_detail'
  /// );
  /// ```
  ///
  /// **Parameters:**
  /// - [subscriptionId]: UUID of the subscription
  /// - [action]: Action type ('view_detail' or 'mark_paid')
  ///
  /// **Returns:**
  /// JSON string in format: `{"subscriptionId":"uuid","action":"mark_paid"}`
  static String createPayload({
    required String subscriptionId,
    String action = 'view_detail',
  }) {
    return jsonEncode({
      'subscriptionId': subscriptionId,
      'action': action,
    });
  }
}
