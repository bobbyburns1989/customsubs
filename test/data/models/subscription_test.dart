import 'package:flutter_test/flutter_test.dart';
import 'package:custom_subs/data/models/subscription.dart';
import 'package:custom_subs/data/models/subscription_cycle.dart';
import 'package:custom_subs/data/models/subscription_category.dart';
import 'package:custom_subs/data/models/reminder_config.dart';

import '../../helpers/test_subscription_factory.dart';

void main() {
  group('Subscription', () {
    group('toJson / fromJson roundtrip', () {
      test('preserves all 26 fields when fully populated', () {
        final now = DateTime(2026, 3, 15, 10, 30);
        final sub = Subscription(
          id: 'test-uuid-123',
          name: 'Netflix',
          amount: 17.99,
          currencyCode: 'EUR',
          cycle: SubscriptionCycle.monthly,
          nextBillingDate: DateTime(2026, 4, 15),
          startDate: DateTime(2025, 1, 1),
          category: SubscriptionCategory.entertainment,
          isActive: true,
          isTrial: true,
          trialEndDate: DateTime(2026, 3, 20),
          postTrialAmount: 24.99,
          cancelUrl: 'https://cancel.example.com',
          cancelPhone: '1-800-555-0100',
          cancelNotes: 'Cancel before trial ends',
          cancelChecklist: ['Log in', 'Go to settings', 'Click cancel'],
          checklistCompleted: [true, false, false],
          notes: 'Family plan',
          iconName: 'netflix',
          colorValue: 0xFFE50914,
          reminders: ReminderConfig(
            firstReminderDays: 3,
            secondReminderDays: 1,
            remindOnBillingDay: false,
            reminderHour: 10,
            reminderMinute: 30,
          ),
          isPaid: true,
          lastMarkedPaidDate: now,
          pausedDate: DateTime(2026, 3, 10),
          resumeDate: DateTime(2026, 3, 25),
          pauseCount: 2,
        );

        final json = sub.toJson();
        final restored = Subscription.fromJson(json);

        expect(restored.id, sub.id);
        expect(restored.name, sub.name);
        expect(restored.amount, sub.amount);
        expect(restored.currencyCode, sub.currencyCode);
        expect(restored.cycle, sub.cycle);
        expect(restored.nextBillingDate, sub.nextBillingDate);
        expect(restored.startDate, sub.startDate);
        expect(restored.category, sub.category);
        expect(restored.isActive, sub.isActive);
        expect(restored.isTrial, sub.isTrial);
        expect(restored.trialEndDate, sub.trialEndDate);
        expect(restored.postTrialAmount, sub.postTrialAmount);
        expect(restored.cancelUrl, sub.cancelUrl);
        expect(restored.cancelPhone, sub.cancelPhone);
        expect(restored.cancelNotes, sub.cancelNotes);
        expect(restored.cancelChecklist, sub.cancelChecklist);
        expect(restored.checklistCompleted, sub.checklistCompleted);
        expect(restored.notes, sub.notes);
        expect(restored.iconName, sub.iconName);
        expect(restored.colorValue, sub.colorValue);
        expect(restored.reminders, sub.reminders);
        expect(restored.isPaid, sub.isPaid);
        expect(restored.lastMarkedPaidDate, sub.lastMarkedPaidDate);
        expect(restored.pausedDate, sub.pausedDate);
        expect(restored.resumeDate, sub.resumeDate);
        expect(restored.pauseCount, sub.pauseCount);
      });

      test('handles null optional fields', () {
        // TestSub.create doesn't expose cancel fields, so use defaults
        // which are already null for optional fields.
        final sub = TestSub.create(
          iconName: null,
          notes: null,
          trialEndDate: null,
          postTrialAmount: null,
          pausedDate: null,
          resumeDate: null,
          lastMarkedPaidDate: null,
        );

        final json = sub.toJson();
        final restored = Subscription.fromJson(json);

        expect(restored.iconName, isNull);
        expect(restored.notes, isNull);
        expect(restored.cancelUrl, isNull);
        expect(restored.trialEndDate, isNull);
        expect(restored.postTrialAmount, isNull);
        expect(restored.pausedDate, isNull);
        expect(restored.resumeDate, isNull);
        expect(restored.lastMarkedPaidDate, isNull);
      });

      test('unknown cycle in JSON defaults to monthly', () {
        final json = TestSub.create().toJson();
        json['cycle'] = 'nonexistent_cycle';
        final restored = Subscription.fromJson(json);
        expect(restored.cycle, SubscriptionCycle.monthly);
      });

      test('unknown category in JSON defaults to other', () {
        final json = TestSub.create().toJson();
        json['category'] = 'nonexistent_category';
        final restored = Subscription.fromJson(json);
        expect(restored.category, SubscriptionCategory.other);
      });

      test('missing optional booleans default correctly', () {
        final json = TestSub.create().toJson();
        json.remove('isActive');
        json.remove('isPaid');
        json.remove('isTrial');
        json.remove('pauseCount');
        final restored = Subscription.fromJson(json);
        expect(restored.isActive, true);
        expect(restored.isPaid, false);
        expect(restored.isTrial, false);
        expect(restored.pauseCount, 0);
      });
    });

    group('calculateNextBillingDate', () {
      Subscription subWithDate(DateTime date, SubscriptionCycle cycle) {
        return TestSub.create(nextBillingDate: date, cycle: cycle);
      }

      test('weekly: adds 7 days', () {
        final sub = subWithDate(DateTime(2026, 1, 1), SubscriptionCycle.weekly);
        expect(sub.calculateNextBillingDate(), DateTime(2026, 1, 8));
      });

      test('biweekly: adds 14 days', () {
        final sub = subWithDate(DateTime(2026, 1, 1), SubscriptionCycle.biweekly);
        expect(sub.calculateNextBillingDate(), DateTime(2026, 1, 15));
      });

      test('monthly: normal case', () {
        final sub = subWithDate(DateTime(2026, 3, 15), SubscriptionCycle.monthly);
        expect(sub.calculateNextBillingDate(), DateTime(2026, 4, 15));
      });

      test('monthly: Jan 31 -> Feb 28 (non-leap year)', () {
        final sub = subWithDate(DateTime(2025, 1, 31), SubscriptionCycle.monthly);
        expect(sub.calculateNextBillingDate(), DateTime(2025, 2, 28));
      });

      test('monthly: Jan 31 -> Feb 29 (leap year 2028)', () {
        final sub = subWithDate(DateTime(2028, 1, 31), SubscriptionCycle.monthly);
        expect(sub.calculateNextBillingDate(), DateTime(2028, 2, 29));
      });

      test('quarterly: Jan 31 -> Apr 30', () {
        final sub = subWithDate(DateTime(2026, 1, 31), SubscriptionCycle.quarterly);
        expect(sub.calculateNextBillingDate(), DateTime(2026, 4, 30));
      });

      test('biannual: Mar 15 -> Sep 15', () {
        final sub = subWithDate(DateTime(2026, 3, 15), SubscriptionCycle.biannual);
        expect(sub.calculateNextBillingDate(), DateTime(2026, 9, 15));
      });

      test('yearly: Feb 29 2024 -> Feb 28 2025', () {
        final sub = subWithDate(DateTime(2024, 2, 29), SubscriptionCycle.yearly);
        expect(sub.calculateNextBillingDate(), DateTime(2025, 2, 28));
      });

      test('yearly: normal case', () {
        final sub = subWithDate(DateTime(2026, 6, 15), SubscriptionCycle.yearly);
        expect(sub.calculateNextBillingDate(), DateTime(2027, 6, 15));
      });
    });

    group('computed properties', () {
      test('effectiveAmount returns 0 during active trial', () {
        final sub = TestSub.create(
          isTrial: true,
          trialEndDate: DateTime.now().add(const Duration(days: 5)),
          postTrialAmount: 14.99,
          amount: 9.99,
        );
        expect(sub.effectiveAmount, 0.0);
      });

      test('effectiveAmount returns postTrialAmount after trial', () {
        final sub = TestSub.create(
          isTrial: true,
          trialEndDate: DateTime.now().subtract(const Duration(days: 1)),
          postTrialAmount: 14.99,
          amount: 9.99,
        );
        expect(sub.effectiveAmount, 14.99);
      });

      test('effectiveAmount returns amount when not trial', () {
        final sub = TestSub.create(amount: 9.99);
        expect(sub.effectiveAmount, 9.99);
      });

      test('isPaused is inverse of isActive', () {
        expect(TestSub.create(isActive: true).isPaused, false);
        expect(TestSub.create(isActive: false).isPaused, true);
      });

      test('shouldAutoResume when paused with past resumeDate', () {
        final sub = TestSub.paused(
          resumeDate: DateTime.now().subtract(const Duration(hours: 1)),
        );
        expect(sub.shouldAutoResume, true);
      });

      test('shouldAutoResume is false when paused with future resumeDate', () {
        final sub = TestSub.paused(
          resumeDate: DateTime.now().add(const Duration(days: 7)),
        );
        expect(sub.shouldAutoResume, false);
      });

      test('shouldAutoResume is false when paused with no resumeDate', () {
        final sub = TestSub.paused(resumeDate: null);
        expect(sub.shouldAutoResume, false);
      });

      test('shouldAutoResume is false when active', () {
        final sub = TestSub.create(
          isActive: true,
          resumeDate: DateTime.now().subtract(const Duration(hours: 1)),
        );
        expect(sub.shouldAutoResume, false);
      });

      test('isOverdue when billing date is past', () {
        final sub = TestSub.create(
          nextBillingDate: DateTime.now().subtract(const Duration(days: 2)),
        );
        expect(sub.isOverdue, true);
      });

      test('not overdue when billing date is future', () {
        final sub = TestSub.create(
          nextBillingDate: DateTime.now().add(const Duration(days: 2)),
        );
        expect(sub.isOverdue, false);
      });

      test('monthlyAmount converts correctly for each cycle', () {
        expect(
          TestSub.create(amount: 10, cycle: SubscriptionCycle.weekly).monthlyAmount,
          closeTo(10 * 52 / 12, 0.01),
        );
        expect(
          TestSub.create(amount: 10, cycle: SubscriptionCycle.monthly).monthlyAmount,
          10.0,
        );
        expect(
          TestSub.create(amount: 30, cycle: SubscriptionCycle.quarterly).monthlyAmount,
          10.0,
        );
        expect(
          TestSub.create(amount: 120, cycle: SubscriptionCycle.yearly).monthlyAmount,
          10.0,
        );
      });
    });

    group('copyWith', () {
      test('returns new instance with changed field', () {
        final original = TestSub.create(name: 'Original');
        final copy = original.copyWith(name: 'Changed');
        expect(copy.name, 'Changed');
        expect(original.name, 'Original'); // unchanged
      });

      test('preserves all other fields', () {
        final original = TestSub.create(
          name: 'Netflix',
          amount: 17.99,
          currencyCode: 'EUR',
        );
        final copy = original.copyWith(name: 'Hulu');
        expect(copy.amount, 17.99);
        expect(copy.currencyCode, 'EUR');
        expect(copy.id, original.id);
      });
    });

    group('equality', () {
      test('same ID means equal', () {
        final a = TestSub.create(id: 'same-id', name: 'A');
        final b = TestSub.create(id: 'same-id', name: 'B');
        expect(a, equals(b));
      });

      test('different IDs means not equal', () {
        final a = TestSub.create(id: 'id-1', name: 'Same Name');
        final b = TestSub.create(id: 'id-2', name: 'Same Name');
        expect(a, isNot(equals(b)));
      });
    });
  });
}
