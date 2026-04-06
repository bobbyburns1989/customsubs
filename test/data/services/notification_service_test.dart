import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:custom_subs/data/models/reminder_config.dart';
import 'package:custom_subs/data/services/notification_service.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_subscription_factory.dart';

void main() {
  late MockFlutterLocalNotificationsPlugin mockPlugin;
  late NotificationService service;

  setUpAll(() {
    // Initialize timezone database for TZDateTime usage in tests
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/New_York'));

    // Register fallback values for mocktail matchers
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(tz.TZDateTime.now(tz.local));
    registerFallbackValue(AndroidScheduleMode.exactAllowWhileIdle);
    registerFallbackValue(UILocalNotificationDateInterpretation.absoluteTime);
    registerFallbackValue(const InitializationSettings());
  });

  setUp(() {
    TestSub.resetCounter();
    mockPlugin = MockFlutterLocalNotificationsPlugin();

    // Stub plugin methods that init() calls
    when(() => mockPlugin.initialize(
      any(),
      onDidReceiveNotificationResponse: any(named: 'onDidReceiveNotificationResponse'),
    )).thenAnswer((_) async => true);

    when(() => mockPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()).thenReturn(null);

    // Stub scheduling / cancellation / show
    when(() => mockPlugin.zonedSchedule(
      any(), any(), any(), any(), any(),
      androidScheduleMode: any(named: 'androidScheduleMode'),
      uiLocalNotificationDateInterpretation: any(named: 'uiLocalNotificationDateInterpretation'),
      matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
      payload: any(named: 'payload'),
    )).thenAnswer((_) async {});

    when(() => mockPlugin.cancel(any())).thenAnswer((_) async {});
    when(() => mockPlugin.cancelAll()).thenAnswer((_) async {});
    when(() => mockPlugin.show(any(), any(), any(), any(),
        payload: any(named: 'payload'))).thenAnswer((_) async {});

    service = NotificationService(notifications: mockPlugin);
  });

  /// Helper: init the service so _initialized = true
  Future<void> initService() async {
    await service.init();
  }

  // ─── Deterministic IDs ────────────────────────────────────────

  group('notificationId (deterministic ID)', () {
    test('produces same ID for same subscriptionId + type', () {
      final id1 = NotificationService.notificationId('abc-123', 'reminder1');
      final id2 = NotificationService.notificationId('abc-123', 'reminder1');
      expect(id1, equals(id2));
    });

    test('produces different IDs for different types', () {
      final reminder1 = NotificationService.notificationId('abc-123', 'reminder1');
      final reminder2 = NotificationService.notificationId('abc-123', 'reminder2');
      final dayof = NotificationService.notificationId('abc-123', 'dayof');

      expect(reminder1, isNot(equals(reminder2)));
      expect(reminder1, isNot(equals(dayof)));
      expect(reminder2, isNot(equals(dayof)));
    });

    test('produces different IDs for different subscriptionIds', () {
      final id1 = NotificationService.notificationId('sub-a', 'reminder1');
      final id2 = NotificationService.notificationId('sub-b', 'reminder1');
      expect(id1, isNot(equals(id2)));
    });

    test('result is within int32 range', () {
      // Test with various inputs including edge cases
      for (final subId in ['', 'a', 'abc-123-def-456-ghi-789', '🎉']) {
        for (final type in ['reminder1', 'reminder2', 'dayof', 'trial_end']) {
          final id = NotificationService.notificationId(subId, type);
          expect(id, greaterThanOrEqualTo(0));
          expect(id, lessThan(2147483647));
        }
      }
    });
  });

  // ─── scheduleNotificationsForSubscription ─────────────────────

  group('scheduleNotificationsForSubscription', () {
    test('throws if service not initialized', () async {
      // Do NOT call initService()
      final sub = TestSub.billingInDays(10);

      expect(
        () => service.scheduleNotificationsForSubscription(sub),
        throwsException,
      );
    });

    test('cancels existing notifications before scheduling new ones', () async {
      await initService();
      final sub = TestSub.billingInDays(10, id: 'sub-1');

      await service.scheduleNotificationsForSubscription(sub);

      // Should cancel all 6 notification types for this subscription
      verify(() => mockPlugin.cancel(
          NotificationService.notificationId('sub-1', 'reminder1'))).called(1);
      verify(() => mockPlugin.cancel(
          NotificationService.notificationId('sub-1', 'reminder2'))).called(1);
      verify(() => mockPlugin.cancel(
          NotificationService.notificationId('sub-1', 'dayof'))).called(1);
      verify(() => mockPlugin.cancel(
          NotificationService.notificationId('sub-1', 'trial_3days'))).called(1);
      verify(() => mockPlugin.cancel(
          NotificationService.notificationId('sub-1', 'trial_1day'))).called(1);
      verify(() => mockPlugin.cancel(
          NotificationService.notificationId('sub-1', 'trial_end'))).called(1);
    });

    test('skips scheduling for paused subscription but still cancels', () async {
      await initService();
      final sub = TestSub.paused(id: 'paused-sub');

      await service.scheduleNotificationsForSubscription(sub);

      // Cancel was called (cleanup)
      verify(() => mockPlugin.cancel(any())).called(6);
      // But zonedSchedule was NOT called (no new notifications)
      verifyNever(() => mockPlugin.zonedSchedule(
        any(), any(), any(), any(), any(),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        uiLocalNotificationDateInterpretation: any(named: 'uiLocalNotificationDateInterpretation'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        payload: any(named: 'payload'),
      ));
    });

    test('skips scheduling for paid subscription but still cancels', () async {
      await initService();
      final sub = TestSub.paid(id: 'paid-sub');

      await service.scheduleNotificationsForSubscription(sub);

      // Cancel was called
      verify(() => mockPlugin.cancel(any())).called(6);
      // But zonedSchedule was NOT called
      verifyNever(() => mockPlugin.zonedSchedule(
        any(), any(), any(), any(), any(),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        uiLocalNotificationDateInterpretation: any(named: 'uiLocalNotificationDateInterpretation'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        payload: any(named: 'payload'),
      ));
    });

    test('schedules reminders for active regular subscription', () async {
      await initService();
      // Default ReminderConfig: firstReminderDays=7, secondReminderDays=1, remindOnBillingDay=true
      final sub = TestSub.billingInDays(20, id: 'regular-sub');

      await service.scheduleNotificationsForSubscription(sub);

      // Should call zonedSchedule 3 times (first, second, day-of)
      verify(() => mockPlugin.zonedSchedule(
        any(), any(), any(), any(), any(),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        uiLocalNotificationDateInterpretation: any(named: 'uiLocalNotificationDateInterpretation'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        payload: any(named: 'payload'),
      )).called(3);
    });

    test('skips firstReminder when firstReminderDays is 0', () async {
      await initService();
      final sub = TestSub.billingInDays(20, id: 'no-first',
        reminders: ReminderConfig(
          firstReminderDays: 0,
          secondReminderDays: 1,
          remindOnBillingDay: true,
        ),
      );

      await service.scheduleNotificationsForSubscription(sub);

      // Only 2 notifications (second + day-of), not 3
      verify(() => mockPlugin.zonedSchedule(
        any(), any(), any(), any(), any(),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        uiLocalNotificationDateInterpretation: any(named: 'uiLocalNotificationDateInterpretation'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        payload: any(named: 'payload'),
      )).called(2);
    });

    test('skips secondReminder when secondReminderDays is 0', () async {
      await initService();
      final sub = TestSub.billingInDays(20, id: 'no-second',
        reminders: ReminderConfig(
          firstReminderDays: 7,
          secondReminderDays: 0,
          remindOnBillingDay: true,
        ),
      );

      await service.scheduleNotificationsForSubscription(sub);

      // Only 2 notifications (first + day-of), not 3
      verify(() => mockPlugin.zonedSchedule(
        any(), any(), any(), any(), any(),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        uiLocalNotificationDateInterpretation: any(named: 'uiLocalNotificationDateInterpretation'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        payload: any(named: 'payload'),
      )).called(2);
    });

    test('skips dayOfReminder when remindOnBillingDay is false', () async {
      await initService();
      final sub = TestSub.billingInDays(20, id: 'no-dayof',
        reminders: ReminderConfig(
          firstReminderDays: 7,
          secondReminderDays: 1,
          remindOnBillingDay: false,
        ),
      );

      await service.scheduleNotificationsForSubscription(sub);

      // Only 2 notifications (first + second), not 3
      verify(() => mockPlugin.zonedSchedule(
        any(), any(), any(), any(), any(),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        uiLocalNotificationDateInterpretation: any(named: 'uiLocalNotificationDateInterpretation'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        payload: any(named: 'payload'),
      )).called(2);
    });

    test('routes to trial notifications when isTrial with trialEndDate', () async {
      await initService();
      final sub = TestSub.trial(id: 'trial-sub', daysUntilEnd: 10);

      await service.scheduleNotificationsForSubscription(sub);

      // Trial schedules 3 notifications: 3 days, 1 day, day-of trial end
      verify(() => mockPlugin.zonedSchedule(
        any(), any(), any(), any(), any(),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        uiLocalNotificationDateInterpretation: any(named: 'uiLocalNotificationDateInterpretation'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        payload: any(named: 'payload'),
      )).called(3);
    });
  });

  // ─── Past notification skipping ───────────────────────────────

  group('Past notification skipping', () {
    test('skips all reminders when billing date is tomorrow and reminders are in the past', () async {
      await initService();
      // Billing tomorrow: 7-day reminder would be 6 days ago (past),
      // 1-day reminder is today (might be past depending on hour)
      // Use a firstReminderDays=7 — it's definitely in the past for billing tomorrow
      final sub = TestSub.billingInDays(1, id: 'tomorrow-sub',
        reminders: ReminderConfig(
          firstReminderDays: 7,  // 7 days before tomorrow = 6 days ago (past)
          secondReminderDays: 3, // 3 days before tomorrow = 2 days ago (past)
          remindOnBillingDay: false,
        ),
      );

      await service.scheduleNotificationsForSubscription(sub);

      // Both reminders should be skipped (in the past)
      verifyNever(() => mockPlugin.zonedSchedule(
        any(), any(), any(), any(), any(),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        uiLocalNotificationDateInterpretation: any(named: 'uiLocalNotificationDateInterpretation'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        payload: any(named: 'payload'),
      ));
    });

    test('schedules future reminders but skips past ones', () async {
      await initService();
      // Billing in 5 days: 7-day reminder is 2 days ago (SKIP),
      // 1-day reminder is in 4 days (SCHEDULE), day-of in 5 days (SCHEDULE)
      final sub = TestSub.billingInDays(5, id: 'mixed-sub',
        reminders: ReminderConfig(
          firstReminderDays: 7,
          secondReminderDays: 1,
          remindOnBillingDay: true,
        ),
      );

      await service.scheduleNotificationsForSubscription(sub);

      // Only 2 scheduled (second + day-of); first was in the past
      verify(() => mockPlugin.zonedSchedule(
        any(), any(), any(), any(), any(),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        uiLocalNotificationDateInterpretation: any(named: 'uiLocalNotificationDateInterpretation'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        payload: any(named: 'payload'),
      )).called(2);
    });
  });

  // ─── cancelNotificationsForSubscription ───────────────────────

  group('cancelNotificationsForSubscription', () {
    test('cancels all 6 notification types with correct IDs', () async {
      await initService();

      await service.cancelNotificationsForSubscription('sub-abc');

      // Verify the specific IDs for all 6 notification types
      final expectedTypes = ['reminder1', 'reminder2', 'dayof', 'trial_3days', 'trial_1day', 'trial_end'];
      for (final type in expectedTypes) {
        verify(() => mockPlugin.cancel(
            NotificationService.notificationId('sub-abc', type))).called(1);
      }
    });
  });

  // ─── cancelAllNotifications ───────────────────────────────────

  group('cancelAllNotifications', () {
    test('delegates to plugin cancelAll', () async {
      await initService();
      await service.cancelAllNotifications();
      verify(() => mockPlugin.cancelAll()).called(1);
    });
  });

  // ─── showTestNotification ─────────────────────────────────────

  group('showTestNotification', () {
    test('calls show with ID 999999 and correct content', () async {
      await initService();
      await service.showTestNotification();

      verify(() => mockPlugin.show(
        999999,
        any(that: contains('Notifications are working')),
        any(that: contains('reminded before every charge')),
        any(),
        payload: any(named: 'payload'),
      )).called(1);
    });
  });

  // ─── areNotificationsEnabled ──────────────────────────────────

  group('areNotificationsEnabled', () {
    test('returns true optimistically when no Android plugin available', () async {
      await initService();
      // mockPlugin already returns null for resolvePlatformSpecificImplementation

      final result = await service.areNotificationsEnabled();
      expect(result, isTrue);
    });
  });

  // ─── Scheduling correctness ───────────────────────────────────

  group('Scheduling correctness', () {
    test('first reminder uses correct notification ID', () async {
      await initService();
      final sub = TestSub.billingInDays(20, id: 'id-check-sub');

      await service.scheduleNotificationsForSubscription(sub);

      final expectedId = NotificationService.notificationId('id-check-sub', 'reminder1');
      verify(() => mockPlugin.zonedSchedule(
        expectedId, any(), any(), any(), any(),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        uiLocalNotificationDateInterpretation: any(named: 'uiLocalNotificationDateInterpretation'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        payload: any(named: 'payload'),
      )).called(1);
    });

    test('schedules nothing when all reminders disabled', () async {
      await initService();
      final sub = TestSub.billingInDays(20, id: 'all-off',
        reminders: ReminderConfig(
          firstReminderDays: 0,
          secondReminderDays: 0,
          remindOnBillingDay: false,
        ),
      );

      await service.scheduleNotificationsForSubscription(sub);

      verifyNever(() => mockPlugin.zonedSchedule(
        any(), any(), any(), any(), any(),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        uiLocalNotificationDateInterpretation: any(named: 'uiLocalNotificationDateInterpretation'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        payload: any(named: 'payload'),
      ));
    });
  });

  // ─── init idempotency ─────────────────────────────────────────

  group('Initialization', () {
    test('init is idempotent - second call is a no-op', () async {
      await initService();
      await initService(); // second call

      // initialize should only be called once
      verify(() => mockPlugin.initialize(
        any(),
        onDidReceiveNotificationResponse: any(named: 'onDidReceiveNotificationResponse'),
      )).called(1);
    });
  });
}
