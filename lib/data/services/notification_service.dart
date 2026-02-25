import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:custom_subs/data/models/subscription.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_subs/core/utils/notification_router.dart';

part 'notification_service.g.dart';

/// Service for managing all local notifications in CustomSubs.
///
/// **CRITICAL:** This is the #1 feature of the app. Notification reliability
/// is our primary competitive advantage over other subscription trackers.
///
/// ## Responsibilities
/// - Schedule billing reminders (3 per subscription: first, second, day-of)
/// - Schedule trial-end reminders (3 per trial: 3 days, 1 day, day-of)
/// - Cancel outdated notifications when subscriptions are edited/deleted
/// - Request notification permissions from the OS
/// - Provide test notifications for user verification
///
/// ## Key Design Decisions
/// - **Deterministic IDs**: Generated from subscription UUID + type for reliable cancellation
/// - **Timezone-aware**: Uses TZDateTime to ensure notifications fire at correct local time
/// - **Exact timing**: Android uses exactAllowWhileIdle to survive Doze mode
/// - **Platform-specific**: Handles iOS vs Android permission and scheduling differences
///
/// ## Usage Example
/// ```dart
/// // Initialize in main.dart
/// final notificationService = NotificationService();
/// await notificationService.init();
///
/// // Request permissions during onboarding
/// final granted = await notificationService.requestPermissions();
///
/// // Schedule notifications when saving a subscription
/// await notificationService.scheduleNotificationsForSubscription(subscription);
/// ```
///
/// See also: `docs/guides/working-with-notifications.md` for detailed guide
class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initializes the notification system for both iOS and Android.
  ///
  /// **Must be called before any other methods** - typically in `main()` before `runApp()`.
  ///
  /// ## What it does
  /// 1. Initializes timezone database for TZDateTime scheduling
  /// 2. Configures platform-specific notification settings
  /// 3. Creates Android notification channel (required for Android 8.0+)
  /// 4. Sets up notification handlers
  ///
  /// ## Platform Details
  /// - **iOS**: Configures Darwin settings, permissions requested separately
  /// - **Android**: Creates "customsubs_reminders" channel with max importance
  ///
  /// ## Usage
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///
  ///   final notificationService = NotificationService();
  ///   await notificationService.init();  // Initialize before runApp
  ///
  ///   runApp(MyApp());
  /// }
  /// ```
  ///
  /// **Important:** This method is idempotent - safe to call multiple times.
  Future<void> init() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android initialization
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization with notification categories and actions
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      notificationCategories: [
        // iOS notification category with action buttons
        DarwinNotificationCategory(
          'subscription_reminder',
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain(
              'mark_paid',
              'Mark as Paid',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.foreground,
              },
            ),
            DarwinNotificationAction.plain(
              'view_details',
              'View Details',
            ),
          ],
        ),
      ],
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize with notification callback handler for deep linking
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: NotificationRouter.handleNotificationResponse,
    );

    // Create Android notification channel
    const androidChannel = AndroidNotificationChannel(
      'customsubs_reminders',
      'Subscription Reminders',
      description: 'Notifications for upcoming subscription charges',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(androidChannel);

    _initialized = true;
  }

  /// Requests notification permissions from the operating system.
  ///
  /// **Should be called during onboarding** after explaining why notifications matter.
  ///
  /// ## Platform Behavior
  /// - **iOS**: Shows system permission dialog (alert, badge, sound)
  /// - **Android < 13**: Granted by default, returns true
  /// - **Android 13+**: Shows system permission dialog
  ///
  /// ## Returns
  /// `true` if permissions granted, `false` if denied. Defaults to `true` on platforms
  /// that don't require explicit permission.
  ///
  /// ## Usage
  /// ```dart
  /// final granted = await notificationService.requestPermissions();
  ///
  /// if (!granted) {
  ///   // Show dialog explaining importance of notifications
  ///   // Offer to open app settings
  /// }
  /// ```
  ///
  /// **Note:** Users can revoke permissions at any time in system settings.
  /// The app should handle denied permissions gracefully.
  Future<bool> requestPermissions() async {
    // iOS permissions
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final iosGranted = await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Android 13+ permissions
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final androidGranted = await androidPlugin?.requestNotificationsPermission();

    return iosGranted ?? androidGranted ?? true;
  }

  /// Creates a JSON payload for notification with subscription metadata for deep linking.
  ///
  /// The payload is used by [NotificationRouter] to navigate to the correct screen
  /// when the user taps the notification or an action button.
  ///
  /// **Payload Format:**
  /// ```json
  /// {
  ///   "subscriptionId": "uuid",
  ///   "action": "view_detail" | "mark_paid"
  /// }
  /// ```
  ///
  /// **Usage:**
  /// ```dart
  /// await _notifications.zonedSchedule(
  ///   id,
  ///   title,
  ///   body,
  ///   scheduledDate,
  ///   notificationDetails,
  ///   payload: _createPayload(subscription.id), // Add this
  /// );
  /// ```
  ///
  /// **Parameters:**
  /// - [subscriptionId]: UUID of the subscription
  /// - [action]: Action type (defaults to 'view_detail')
  String _createPayload(String subscriptionId, {String action = 'view_detail'}) {
    return NotificationRouter.createPayload(
      subscriptionId: subscriptionId,
      action: action,
    );
  }

  /// Generates a stable, deterministic notification ID from subscription UUID and type.
  ///
  /// ## Why Deterministic IDs?
  /// Random IDs would prevent us from canceling specific notifications when rescheduling.
  /// By computing IDs from subscription UUID + type, we get:
  /// - **Predictable**: Same subscription + type = same ID every time
  /// - **Unique**: UUID + type combination ensures no collisions
  /// - **Cancellable**: Can cancel specific notifications without storing IDs
  ///
  /// ## Notification Types
  /// - Regular subscriptions: `'reminder1'`, `'reminder2'`, `'dayof'`
  /// - Trial subscriptions: `'trial_3days'`, `'trial_1day'`, `'trial_end'`
  ///
  /// ## Example
  /// ```dart
  /// final subId = '123e4567-e89b-12d3-a456-426614174000';
  /// _notificationId(subId, 'reminder1');  // → 1234567890 (deterministic)
  /// _notificationId(subId, 'reminder1');  // → 1234567890 (same ID)
  /// ```
  ///
  /// **Implementation Note:** Uses hashCode % 2147483647 to fit in int32 range.
  ///
  /// See: `docs/decisions/002-notification-id-strategy.md` for full rationale
  int _notificationId(String subscriptionId, String type) {
    return ('$subscriptionId:$type'.hashCode).abs() % 2147483647;
  }

  /// Schedules all notifications for a subscription based on its reminder configuration.
  ///
  /// **This is the main method you'll call** when creating or editing subscriptions.
  ///
  /// ## What it does
  /// 1. Cancels all existing notifications for this subscription (prevents duplicates)
  /// 2. Checks if subscription is active (inactive subs get no notifications)
  /// 3. Routes to appropriate scheduler:
  ///    - Trial subscriptions → schedules 3 trial-end reminders
  ///    - Regular subscriptions → schedules up to 3 billing reminders
  ///
  /// ## Notification Schedule
  ///
  /// **For regular subscriptions:**
  /// - First reminder: X days before (default: 7 days) at configured time
  /// - Second reminder: Y days before (default: 1 day) at configured time
  /// - Day-of reminder: Morning of billing date at configured time
  ///
  /// **For trial subscriptions:**
  /// - 3 days before trial ends
  /// - 1 day before trial ends
  /// - Morning of trial end date
  ///
  /// ## Usage Example
  /// ```dart
  /// // After saving a subscription
  /// final repository = await ref.read(subscriptionRepositoryProvider.future);
  /// await repository.upsert(subscription);
  ///
  /// // Schedule notifications
  /// final notificationService = ref.read(notificationServiceProvider);
  /// await notificationService.scheduleNotificationsForSubscription(subscription);
  /// ```
  ///
  /// ## When to call this method
  /// - ✅ After creating a new subscription
  /// - ✅ After editing an existing subscription (especially dates/amounts)
  /// - ✅ After changing reminder settings
  /// - ✅ After toggling subscription active/inactive status
  /// - ✅ During app launch (to reschedule after device reboot)
  ///
  /// ## Error Handling
  /// Throws `Exception` if service not initialized. Always call `init()` first.
  ///
  /// **Important:** Notifications in the past are automatically skipped.
  ///
  /// See: `docs/guides/working-with-notifications.md` for detailed guide
  Future<void> scheduleNotificationsForSubscription(Subscription subscription) async {
    if (!_initialized) {
      throw Exception('NotificationService not initialized. Call init() first.');
    }

    // Cancel existing notifications first
    await cancelNotificationsForSubscription(subscription.id);

    // SKIP scheduling if subscription is paused
    if (!subscription.isActive) {
      return; // Paused subscriptions get no notifications
    }

    final reminders = subscription.reminders;

    // Handle trial-specific notifications
    if (subscription.isTrial && subscription.trialEndDate != null) {
      await _scheduleTrialNotifications(subscription);
    } else {
      // Regular billing notifications
      if (reminders.firstReminderDays > 0) {
        await _scheduleFirstReminder(subscription);
      }

      if (reminders.secondReminderDays > 0) {
        await _scheduleSecondReminder(subscription);
      }

      if (reminders.remindOnBillingDay) {
        await _scheduleDayOfReminder(subscription);
      }
    }
  }

  /// Schedule first reminder (e.g., 7 days before)
  Future<void> _scheduleFirstReminder(Subscription subscription) async {
    final reminderDate = subscription.nextBillingDate.subtract(
      Duration(days: subscription.reminders.firstReminderDays),
    );

    final scheduledDate = tz.TZDateTime(
      tz.local,
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      subscription.reminders.reminderHour,
      subscription.reminders.reminderMinute,
    );

    // Check if scheduled time has passed (compare full timestamp, not just date)
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    final daysUntil = subscription.reminders.firstReminderDays;
    final formattedDate = DateFormat.yMMMd().format(subscription.nextBillingDate);
    final formattedAmount = _formatAmount(subscription);

    // Rich notification body for expandable view
    final notificationBody = '$formattedAmount charges on $formattedDate\n\nTap to view details or mark as paid.';

    await _notifications.zonedSchedule(
      _notificationId(subscription.id, 'reminder1'),
      '📅 ${subscription.name} — Billing in $daysUntil days',
      '$formattedAmount charges on $formattedDate', // Short body for collapsed view
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'customsubs_reminders',
          'Subscription Reminders',
          channelDescription: 'Notifications for upcoming subscription charges',
          importance: Importance.max,
          priority: Priority.high,
          // BigTextStyle for expandable notifications with more detail
          styleInformation: BigTextStyleInformation(
            notificationBody,
            contentTitle: '📅 ${subscription.name} — Billing in $daysUntil days',
            summaryText: formattedAmount,
          ),
          // Action buttons for quick interactions
          actions: <AndroidNotificationAction>[
            const AndroidNotificationAction(
              'mark_paid',
              'Mark as Paid',
              showsUserInterface: false, // Background action
            ),
            const AndroidNotificationAction(
              'view_details',
              'View Details',
              showsUserInterface: true, // Opens app
            ),
          ],
        ),
        iOS: DarwinNotificationDetails(
          subtitle: 'Billing in $daysUntil days',
          categoryIdentifier: 'subscription_reminder', // Links to category with actions
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // Add payload for deep linking
      payload: _createPayload(subscription.id),
    );
  }

  /// Schedule second reminder (e.g., 1 day before)
  Future<void> _scheduleSecondReminder(Subscription subscription) async {
    final reminderDate = subscription.nextBillingDate.subtract(
      Duration(days: subscription.reminders.secondReminderDays),
    );

    final scheduledDate = tz.TZDateTime(
      tz.local,
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      subscription.reminders.reminderHour,
      subscription.reminders.reminderMinute,
    );

    // Check if scheduled time has passed (compare full timestamp, not just date)
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    final formattedDate = DateFormat.yMMMd().format(subscription.nextBillingDate);
    final formattedAmount = _formatAmount(subscription);

    final daysUntil = subscription.reminders.secondReminderDays;
    final title = daysUntil == 1
        ? '⚠️ ${subscription.name} — Bills tomorrow'
        : '⚠️ ${subscription.name} — Bills in $daysUntil days';

    // Rich notification body
    final notificationBody = '$formattedAmount will be charged on $formattedDate\n\nTap to view details or mark as paid.';

    await _notifications.zonedSchedule(
      _notificationId(subscription.id, 'reminder2'),
      title,
      '$formattedAmount will be charged on $formattedDate',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'customsubs_reminders',
          'Subscription Reminders',
          channelDescription: 'Notifications for upcoming subscription charges',
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(
            notificationBody,
            contentTitle: title,
            summaryText: formattedAmount,
          ),
          actions: <AndroidNotificationAction>[
            const AndroidNotificationAction(
              'mark_paid',
              'Mark as Paid',
              showsUserInterface: false,
            ),
            const AndroidNotificationAction(
              'view_details',
              'View Details',
              showsUserInterface: true,
            ),
          ],
        ),
        iOS: DarwinNotificationDetails(
          subtitle: daysUntil == 1 ? 'Bills tomorrow' : 'Bills in $daysUntil days',
          categoryIdentifier: 'subscription_reminder',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: _createPayload(subscription.id),
    );
  }

  /// Schedule day-of reminder
  Future<void> _scheduleDayOfReminder(Subscription subscription) async {
    final reminderDate = subscription.nextBillingDate;

    final scheduledDate = tz.TZDateTime(
      tz.local,
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      subscription.reminders.reminderHour,
      subscription.reminders.reminderMinute,
    );

    // Check if scheduled time has passed (compare full timestamp, not just date)
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    final formattedAmount = _formatAmount(subscription);
    final notificationBody = '$formattedAmount charge expected today\n\nTap to view details or mark as paid.';

    await _notifications.zonedSchedule(
      _notificationId(subscription.id, 'dayof'),
      '💰 ${subscription.name} — Billing today',
      '$formattedAmount charge expected today',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'customsubs_reminders',
          'Subscription Reminders',
          channelDescription: 'Notifications for upcoming subscription charges',
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(
            notificationBody,
            contentTitle: '💰 ${subscription.name} — Billing today',
            summaryText: formattedAmount,
          ),
          actions: <AndroidNotificationAction>[
            const AndroidNotificationAction(
              'mark_paid',
              'Mark as Paid',
              showsUserInterface: false,
            ),
            const AndroidNotificationAction(
              'view_details',
              'View Details',
              showsUserInterface: true,
            ),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          subtitle: 'Billing today',
          categoryIdentifier: 'subscription_reminder',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: _createPayload(subscription.id),
    );
  }

  /// Schedule trial-specific notifications
  Future<void> _scheduleTrialNotifications(Subscription subscription) async {
    final trialEndDate = subscription.trialEndDate!;

    // 3 days before trial ends
    final threeDaysBefore = trialEndDate.subtract(const Duration(days: 3));
    await _scheduleTrialReminder(
      subscription,
      threeDaysBefore,
      'trial_3days',
      '🔔 ${subscription.name} — Trial ending in 3 days',
    );

    // 1 day before trial ends
    final oneDayBefore = trialEndDate.subtract(const Duration(days: 1));
    await _scheduleTrialReminder(
      subscription,
      oneDayBefore,
      'trial_1day',
      '🔔 ${subscription.name} — Trial ending tomorrow',
    );

    // Morning of trial end date
    await _scheduleTrialReminder(
      subscription,
      trialEndDate,
      'trial_end',
      '🔔 ${subscription.name} — Trial ends today',
    );
  }

  /// Schedule a single trial reminder
  Future<void> _scheduleTrialReminder(
    Subscription subscription,
    DateTime reminderDate,
    String type,
    String title,
  ) async {
    final scheduledDate = tz.TZDateTime(
      tz.local,
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      subscription.reminders.reminderHour,
      subscription.reminders.reminderMinute,
    );

    // Check if scheduled time has passed (compare full timestamp, not just date)
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    final formattedDate = DateFormat.yMMMd().format(subscription.trialEndDate!);
    final postAmount = subscription.postTrialAmount ?? subscription.amount;
    final formattedAmount = NumberFormat.currency(
      symbol: _getCurrencySymbol(subscription.currencyCode),
      decimalDigits: 2,
    ).format(postAmount);

    final notificationBody = 'Free trial ends $formattedDate. You\'ll be charged $formattedAmount/${subscription.cycle.shortName} after.\n\nTap to view details or mark as paid.';

    await _notifications.zonedSchedule(
      _notificationId(subscription.id, type),
      title,
      notificationBody,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'customsubs_reminders',
          'Subscription Reminders',
          channelDescription: 'Notifications for upcoming subscription charges',
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(
            notificationBody,
            contentTitle: title,
            summaryText: formattedAmount,
          ),
          actions: <AndroidNotificationAction>[
            const AndroidNotificationAction('mark_paid', 'Mark as Paid',
              showsUserInterface: false),
            const AndroidNotificationAction('view_details', 'View Details',
              showsUserInterface: true),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          subtitle: 'Trial ending',
          categoryIdentifier: 'subscription_reminder',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: _createPayload(subscription.id),
    );
  }

  /// Cancels all scheduled notifications for a specific subscription.
  ///
  /// **Always called automatically** by `scheduleNotificationsForSubscription()`
  /// before rescheduling to prevent duplicates.
  ///
  /// ## What it cancels
  /// - All 3 regular reminders: `reminder1`, `reminder2`, `dayof`
  /// - All 3 trial reminders: `trial_3days`, `trial_1day`, `trial_end`
  ///
  /// ## Usage
  /// ```dart
  /// // Typically you don't call this directly - it's called automatically
  /// // when rescheduling. But if you need to cancel without rescheduling:
  /// await notificationService.cancelNotificationsForSubscription(subscription.id);
  /// ```
  ///
  /// **Use case:** When deleting a subscription, call this to clean up notifications.
  Future<void> cancelNotificationsForSubscription(String subscriptionId) async {
    await _notifications.cancel(_notificationId(subscriptionId, 'reminder1'));
    await _notifications.cancel(_notificationId(subscriptionId, 'reminder2'));
    await _notifications.cancel(_notificationId(subscriptionId, 'dayof'));
    await _notifications.cancel(_notificationId(subscriptionId, 'trial_3days'));
    await _notifications.cancel(_notificationId(subscriptionId, 'trial_1day'));
    await _notifications.cancel(_notificationId(subscriptionId, 'trial_end'));
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Sends an immediate test notification to verify the system is working.
  ///
  /// **Critical for user trust** - allows users to verify notifications work on their device.
  ///
  /// ## What it does
  /// - Fires immediately (no scheduling)
  /// - Uses fixed ID (999999) that doesn't conflict with subscription notifications
  /// - Shows success message: "✅ Notifications are working!"
  ///
  /// ## Usage
  /// ```dart
  /// // In Settings screen
  /// ListTile(
  ///   title: Text('Test Notification'),
  ///   subtitle: Text('Tap to verify notifications work'),
  ///   onTap: () async {
  ///     final service = ref.read(notificationServiceProvider);
  ///     await service.showTestNotification();
  ///
  ///     ScaffoldMessenger.of(context).showSnackBar(
  ///       SnackBar(content: Text('Test notification sent!')),
  ///     );
  ///   },
  /// );
  /// ```
  ///
  /// **Best practice:** Always provide this feature in Settings so users can
  /// verify their device is configured correctly for notifications.
  Future<void> showTestNotification() async {
    await _notifications.show(
      999999,
      '✅ Notifications are working!',
      'You\'ll be reminded before every charge.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'customsubs_reminders',
          'Subscription Reminders',
          channelDescription: 'Notifications for upcoming subscription charges',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Format amount with currency
  String _formatAmount(Subscription subscription) {
    return NumberFormat.currency(
      symbol: _getCurrencySymbol(subscription.currencyCode),
      decimalDigits: 2,
    ).format(subscription.amount);
  }

  /// Get currency symbol for a currency code
  String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'INR':
        return '₹';
      default:
        return currencyCode;
    }
  }
}

@riverpod
Future<NotificationService> notificationService(Ref ref) async {
  final service = NotificationService();
  await service.init();
  return service;
}
