import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:custom_subs/data/models/subscription.dart';
import 'package:custom_subs/data/repositories/subscription_repository.dart';
import 'package:custom_subs/data/services/notification_service.dart';
import 'package:custom_subs/data/services/analytics_service.dart';
import 'package:custom_subs/data/services/backup_service.dart';

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockBox extends Mock implements Box<Subscription> {}

class MockSubscriptionRepository extends Mock
    implements SubscriptionRepository {}

class MockNotificationService extends Mock implements NotificationService {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockBackupService extends Mock implements BackupService {}
