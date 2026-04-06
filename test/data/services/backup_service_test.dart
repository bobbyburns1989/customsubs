import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:custom_subs/data/services/backup_service.dart';
import 'package:custom_subs/data/models/subscription.dart';
import 'package:custom_subs/data/models/subscription_cycle.dart';
import 'package:custom_subs/data/models/subscription_category.dart';
import 'package:custom_subs/data/models/reminder_config.dart';

import '../../helpers/test_subscription_factory.dart';

void main() {
  late BackupService backupService;

  setUp(() {
    backupService = BackupService();
  });

  group('exportToJson', () {
    test('empty list produces valid JSON with count 0', () async {
      final json = await backupService.exportToJson([]);
      final data = jsonDecode(json) as Map<String, dynamic>;

      expect(data['app'], 'CustomSubs');
      expect(data['version'], '1.0.0');
      expect(data['subscriptionCount'], 0);
      expect(data['subscriptions'], isEmpty);
      expect(data['exportDate'], isNotNull);
    });

    test('list of subs produces correct count and structure', () async {
      final subs = [
        TestSub.create(id: 'sub-1', name: 'Netflix'),
        TestSub.create(id: 'sub-2', name: 'Spotify'),
        TestSub.create(id: 'sub-3', name: 'Hulu'),
      ];

      final json = await backupService.exportToJson(subs);
      final data = jsonDecode(json) as Map<String, dynamic>;

      expect(data['subscriptionCount'], 3);
      final subsList = data['subscriptions'] as List;
      expect(subsList.length, 3);
      expect(subsList[0]['name'], 'Netflix');
      expect(subsList[1]['name'], 'Spotify');
      expect(subsList[2]['name'], 'Hulu');
    });
  });

  group('parseBackupFile', () {
    test('parses valid export JSON', () async {
      final subs = [TestSub.create(id: 'parse-test', name: 'TestSub')];
      final json = await backupService.exportToJson(subs);

      final result = await backupService.parseBackupFile(json);
      expect(result.subscriptions.length, 1);
      expect(result.subscriptions.first.name, 'TestSub');
      expect(result.parseErrors, isEmpty);
    });

    test('throws on invalid JSON', () async {
      expect(
        () => backupService.parseBackupFile('not valid json {'),
        throwsA(isA<BackupException>()),
      );
    });

    test('throws on wrong app name', () async {
      final json = jsonEncode({
        'app': 'OtherApp',
        'subscriptions': [],
      });
      expect(
        () => backupService.parseBackupFile(json),
        throwsA(isA<BackupException>()),
      );
    });

    test('throws on missing subscriptions key', () async {
      final json = jsonEncode({
        'app': 'CustomSubs',
      });
      expect(
        () => backupService.parseBackupFile(json),
        throwsA(isA<BackupException>()),
      );
    });

    test('extra unknown fields do not crash', () async {
      final json = jsonEncode({
        'app': 'CustomSubs',
        'version': '99.0',
        'unknownField': true,
        'subscriptions': [],
      });
      final result = await backupService.parseBackupFile(json);
      expect(result.subscriptions, isEmpty);
    });
  });

  group('full roundtrip', () {
    test('diverse subscriptions survive export -> parse with all fields', () async {
      final subs = [
        // Regular monthly sub
        TestSub.create(
          id: 'rt-1',
          name: 'Netflix',
          amount: 17.99,
          currencyCode: 'EUR',
          cycle: SubscriptionCycle.monthly,
          category: SubscriptionCategory.entertainment,
          iconName: 'netflix',
          colorValue: 0xFFE50914,
          notes: 'Family plan',
        ),
        // Yearly sub, paid
        TestSub.create(
          id: 'rt-2',
          name: 'Amazon Prime',
          amount: 139.0,
          cycle: SubscriptionCycle.yearly,
          category: SubscriptionCategory.shopping,
          isPaid: true,
          lastMarkedPaidDate: DateTime(2026, 3, 1),
        ),
        // Paused sub with auto-resume
        TestSub.paused(
          id: 'rt-3',
          name: 'Gym',
          pausedDate: DateTime(2026, 2, 15),
          resumeDate: DateTime(2026, 4, 1),
          pauseCount: 2,
        ),
        // Trial sub
        TestSub.trial(
          id: 'rt-4',
          name: 'Notion',
          daysUntilEnd: 10,
          postTrialAmount: 10.0,
        ),
        // Sub with cancel checklist — use Subscription() directly since
        // TestSub.create doesn't expose cancel fields
        Subscription(
          id: 'rt-5',
          name: 'Adobe CC',
          amount: 59.99,
          currencyCode: 'USD',
          cycle: SubscriptionCycle.monthly,
          nextBillingDate: DateTime(2026, 5, 1),
          startDate: DateTime(2025, 1, 1),
          category: SubscriptionCategory.productivity,
          colorValue: 0xFFFF0000,
          reminders: ReminderConfig(),
          cancelUrl: 'https://adobe.com/cancel',
          cancelPhone: '1-800-833-6687',
          cancelNotes: 'Must call to cancel',
          cancelChecklist: ['Log in', 'Navigate to plans', 'Cancel'],
          checklistCompleted: [true, false, false],
        ),
      ];

      final jsonStr = await backupService.exportToJson(subs);
      final result = await backupService.parseBackupFile(jsonStr);
      final restored = result.subscriptions;

      expect(restored.length, 5);

      // Verify first sub fields
      final netflix = restored.firstWhere((s) => s.id == 'rt-1');
      expect(netflix.name, 'Netflix');
      expect(netflix.amount, 17.99);
      expect(netflix.currencyCode, 'EUR');
      expect(netflix.cycle, SubscriptionCycle.monthly);
      expect(netflix.category, SubscriptionCategory.entertainment);
      expect(netflix.iconName, 'netflix');
      expect(netflix.colorValue, 0xFFE50914);
      expect(netflix.notes, 'Family plan');

      // Verify paid sub
      final prime = restored.firstWhere((s) => s.id == 'rt-2');
      expect(prime.isPaid, true);
      expect(prime.lastMarkedPaidDate, DateTime(2026, 3, 1));

      // Verify paused sub
      final gym = restored.firstWhere((s) => s.id == 'rt-3');
      expect(gym.isActive, false);
      expect(gym.pausedDate, DateTime(2026, 2, 15));
      expect(gym.resumeDate, DateTime(2026, 4, 1));
      expect(gym.pauseCount, 2);

      // Verify trial sub
      final notion = restored.firstWhere((s) => s.id == 'rt-4');
      expect(notion.isTrial, true);
      expect(notion.trialEndDate, isNotNull);
      expect(notion.postTrialAmount, 10.0);

      // Verify cancel checklist
      final adobe = restored.firstWhere((s) => s.id == 'rt-5');
      expect(adobe.cancelUrl, 'https://adobe.com/cancel');
      expect(adobe.cancelChecklist.length, 3);
      expect(adobe.checklistCompleted, [true, false, false]);
    });
  });

  group('detectDuplicates', () {
    test('detects UUID match', () {
      final existing = [TestSub.create(id: 'same-id', name: 'Netflix')];
      final imports = [TestSub.create(id: 'same-id', name: 'Netflix Renamed')];

      final dupes = backupService.detectDuplicates(imports, existing);
      expect(dupes.length, 1);
    });

    test('detects name + amount + cycle match (case-insensitive)', () {
      final existing = [
        TestSub.create(id: 'ex-1', name: 'Netflix', amount: 15.99,
            cycle: SubscriptionCycle.monthly),
      ];
      final imports = [
        TestSub.create(id: 'new-1', name: 'netflix', amount: 15.99,
            cycle: SubscriptionCycle.monthly),
      ];

      final dupes = backupService.detectDuplicates(imports, existing);
      expect(dupes.length, 1);
    });

    test('different amount is NOT a duplicate', () {
      final existing = [
        TestSub.create(id: 'ex-1', name: 'Netflix', amount: 15.99),
      ];
      final imports = [
        TestSub.create(id: 'new-1', name: 'Netflix', amount: 22.99),
      ];

      final dupes = backupService.detectDuplicates(imports, existing);
      expect(dupes, isEmpty);
    });

    test('different cycle is NOT a duplicate', () {
      final existing = [
        TestSub.create(id: 'ex-1', name: 'Netflix', amount: 15.99,
            cycle: SubscriptionCycle.monthly),
      ];
      final imports = [
        TestSub.create(id: 'new-1', name: 'Netflix', amount: 15.99,
            cycle: SubscriptionCycle.yearly),
      ];

      final dupes = backupService.detectDuplicates(imports, existing);
      expect(dupes, isEmpty);
    });

    test('empty existing list means no duplicates', () {
      final imports = [TestSub.create(id: 'new-1')];
      final dupes = backupService.detectDuplicates(imports, []);
      expect(dupes, isEmpty);
    });

    test('empty import list means no duplicates', () {
      final existing = [TestSub.create(id: 'ex-1')];
      final dupes = backupService.detectDuplicates([], existing);
      expect(dupes, isEmpty);
    });
  });

  group('backward compatibility', () {
    test('JSON missing optional fields uses defaults', () async {
      // Simulate an older backup that is missing newer fields
      final json = jsonEncode({
        'app': 'CustomSubs',
        'version': '1.0.0',
        'exportDate': '2025-01-01T00:00:00.000',
        'subscriptionCount': 1,
        'subscriptions': [
          {
            'id': 'old-sub',
            'name': 'Old Netflix',
            'amount': 9.99,
            'currencyCode': 'USD',
            'cycle': 'monthly',
            'nextBillingDate': '2025-02-01T00:00:00.000',
            'startDate': '2025-01-01T00:00:00.000',
            'category': 'entertainment',
            'colorValue': 0xFF000000,
            'reminders': {},
            // Missing: isActive, isPaid, isTrial, pauseCount, resumeDate, etc.
          },
        ],
      });

      final result = await backupService.parseBackupFile(json);
      final sub = result.subscriptions.first;

      // Verify defaults
      expect(sub.isActive, true);
      expect(sub.isPaid, false);
      expect(sub.isTrial, false);
      expect(sub.pauseCount, 0);
      expect(sub.resumeDate, isNull);
      expect(sub.pausedDate, isNull);
      expect(sub.lastMarkedPaidDate, isNull);
    });
  });

  group('validateSubscription', () {
    test('valid subscription returns null', () {
      final sub = TestSub.create();
      expect(BackupService.validateSubscription(sub), isNull);
    });

    test('empty name returns error', () {
      final sub = TestSub.create(name: '  ');
      expect(BackupService.validateSubscription(sub), contains('Empty name'));
    });

    test('negative amount returns error', () {
      final sub = TestSub.create(amount: -5.0);
      expect(BackupService.validateSubscription(sub), contains('Negative amount'));
    });
  });
}
