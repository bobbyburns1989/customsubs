import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:custom_subs/data/models/subscription.dart';
import 'package:custom_subs/data/models/subscription_cycle.dart';
import 'package:custom_subs/data/models/subscription_category.dart';
import 'package:custom_subs/data/models/reminder_config.dart';
import 'package:custom_subs/data/repositories/subscription_repository.dart';

import '../../helpers/test_subscription_factory.dart';

// --- Fake in-memory Box ---
// Simulates a Hive Box<Subscription> using an in-memory map.
// This avoids real Hive init / type adapter registration in unit tests.
class FakeBox extends Fake implements Box<Subscription> {
  final Map<dynamic, Subscription> _store = {};
  int _autoKey = 0;

  @override
  bool get isOpen => true;

  @override
  Iterable<Subscription> get values => _store.values;

  @override
  Iterable<dynamic> get keys => _store.keys;

  @override
  Subscription? get(dynamic key, {Subscription? defaultValue}) =>
      _store[key] ?? defaultValue;

  @override
  Future<int> add(Subscription value) async {
    final key = _autoKey++;
    _store[key] = value;
    return key;
  }

  @override
  Future<void> put(dynamic key, Subscription value) async {
    _store[key] = value;
  }

  @override
  Future<void> delete(dynamic key) async {
    _store.remove(key);
  }

  @override
  Future<int> clear() async {
    final count = _store.length;
    _store.clear();
    return count;
  }

  /// Helper: seed the box with subscriptions for test setup.
  void seed(List<Subscription> subs) {
    _store.clear();
    _autoKey = 0;
    for (final sub in subs) {
      _store[_autoKey++] = sub;
    }
  }
}

void main() {
  late FakeBox fakeBox;
  late SubscriptionRepository repo;

  setUp(() {
    TestSub.resetCounter();
    fakeBox = FakeBox();
    // Inject the fake box — skips Hive.openBox entirely
    repo = SubscriptionRepository(box: fakeBox);
  });

  // ─── CRUD basics ──────────────────────────────────────────────

  group('CRUD basics', () {
    test('getAll returns all subscriptions from box', () {
      final subs = [
        TestSub.create(name: 'Netflix'),
        TestSub.create(name: 'Spotify'),
      ];
      fakeBox.seed(subs);

      expect(repo.getAll(), hasLength(2));
    });

    test('getAll returns empty list when box is empty', () {
      expect(repo.getAll(), isEmpty);
    });

    test('getAllActive returns only active subscriptions', () {
      fakeBox.seed([
        TestSub.create(name: 'Active', isActive: true),
        TestSub.paused(name: 'Paused'),
        TestSub.create(name: 'Active2', isActive: true),
      ]);

      final active = repo.getAllActive();
      expect(active, hasLength(2));
      expect(active.every((s) => s.isActive), isTrue);
    });

    test('getAllPaused returns only paused subscriptions', () {
      fakeBox.seed([
        TestSub.create(name: 'Active', isActive: true),
        TestSub.paused(name: 'Paused1'),
        TestSub.paused(name: 'Paused2'),
      ]);

      final paused = repo.getAllPaused();
      expect(paused, hasLength(2));
      expect(paused.every((s) => !s.isActive), isTrue);
    });

    test('getById returns subscription when found', () {
      fakeBox.seed([
        TestSub.create(id: 'abc-123', name: 'Netflix'),
      ]);

      final result = repo.getById('abc-123');
      expect(result, isNotNull);
      expect(result!.name, 'Netflix');
    });

    test('getById returns null when not found', () {
      fakeBox.seed([TestSub.create(id: 'abc-123')]);
      expect(repo.getById('nonexistent'), isNull);
    });

    test('upsert adds new subscription when ID does not exist', () async {
      final sub = TestSub.create(id: 'new-sub', name: 'NewService');
      await repo.upsert(sub);

      expect(fakeBox.values, hasLength(1));
      expect(fakeBox.values.first.name, 'NewService');
    });

    test('upsert updates existing subscription when ID matches', () async {
      final original = TestSub.create(id: 'sub-1', name: 'Old Name');
      fakeBox.seed([original]);

      final updated = TestSub.create(id: 'sub-1', name: 'New Name');
      await repo.upsert(updated);

      // Should still have 1 item, not 2
      expect(fakeBox.values, hasLength(1));
      expect(fakeBox.values.first.name, 'New Name');
    });

    test('delete removes subscription by ID', () async {
      fakeBox.seed([
        TestSub.create(id: 'keep-me', name: 'Keep'),
        TestSub.create(id: 'delete-me', name: 'Delete'),
      ]);

      await repo.delete('delete-me');
      expect(fakeBox.values, hasLength(1));
      expect(fakeBox.values.first.name, 'Keep');
    });

    test('delete does nothing when ID not found', () async {
      fakeBox.seed([TestSub.create(id: 'existing')]);
      await repo.delete('nonexistent');
      expect(fakeBox.values, hasLength(1));
    });

    test('deleteAll clears the box', () async {
      fakeBox.seed([TestSub.create(), TestSub.create(), TestSub.create()]);
      await repo.deleteAll();
      expect(fakeBox.values, isEmpty);
    });
  });

  // ─── advanceOverdueBillingDates ────────────────────────────────

  group('advanceOverdueBillingDates', () {
    test('advances monthly sub billing yesterday to next month', () async {
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 1));

      fakeBox.seed([
        TestSub.create(
          id: 'monthly-sub',
          cycle: SubscriptionCycle.monthly,
          nextBillingDate: yesterday,
        ),
      ]);

      final updated = await repo.advanceOverdueBillingDates();

      expect(updated, hasLength(1));
      // New billing date should be in the future (at or after today)
      final today = DateTime(now.year, now.month, now.day);
      expect(updated.first.nextBillingDate.isAfter(today) ||
          updated.first.nextBillingDate.isAtSameMomentAs(today), isTrue);
    });

    test('advances sub that missed multiple cycles to correct future date', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      // 95 days ago — a monthly sub should advance ~3 times
      final longAgo = today.subtract(const Duration(days: 95));

      fakeBox.seed([
        TestSub.create(
          id: 'overdue-sub',
          cycle: SubscriptionCycle.monthly,
          nextBillingDate: longAgo,
        ),
      ]);

      final updated = await repo.advanceOverdueBillingDates();

      expect(updated, hasLength(1));
      // Should be advanced past today
      expect(
        updated.first.nextBillingDate.isAfter(today) ||
            updated.first.nextBillingDate.isAtSameMomentAs(today),
        isTrue,
      );
    });

    test('resets isPaid to false on advance', () async {
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 1));

      fakeBox.seed([
        TestSub.create(
          id: 'paid-sub',
          cycle: SubscriptionCycle.monthly,
          nextBillingDate: yesterday,
          isPaid: true,
        ),
      ]);

      final updated = await repo.advanceOverdueBillingDates();

      expect(updated, hasLength(1));
      expect(updated.first.isPaid, isFalse);
    });

    test('skips paused subscriptions (billing dates freeze)', () async {
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 1));

      fakeBox.seed([
        TestSub.paused(
          id: 'paused-overdue',
          nextBillingDate: yesterday,
        ),
      ]);

      final updated = await repo.advanceOverdueBillingDates();

      expect(updated, isEmpty);
      // Billing date should be unchanged
      expect(repo.getById('paused-overdue')!.nextBillingDate, yesterday);
    });

    test('does NOT advance sub billing today (calendar-day boundary)', () async {
      final now = DateTime.now();
      final todayMidnight = DateTime(now.year, now.month, now.day);

      fakeBox.seed([
        TestSub.create(
          id: 'today-sub',
          cycle: SubscriptionCycle.monthly,
          nextBillingDate: todayMidnight,
        ),
      ]);

      final updated = await repo.advanceOverdueBillingDates();

      expect(updated, isEmpty);
      expect(repo.getById('today-sub')!.nextBillingDate, todayMidnight);
    });

    test('does NOT advance sub billing tomorrow', () async {
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day)
          .add(const Duration(days: 1));

      fakeBox.seed([
        TestSub.create(
          id: 'tomorrow-sub',
          cycle: SubscriptionCycle.monthly,
          nextBillingDate: tomorrow,
        ),
      ]);

      final updated = await repo.advanceOverdueBillingDates();

      expect(updated, isEmpty);
    });

    test('handles weekly cycle advancement correctly', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      // 10 days ago — weekly sub should advance at least once
      final tenDaysAgo = today.subtract(const Duration(days: 10));

      fakeBox.seed([
        TestSub.create(
          id: 'weekly-sub',
          cycle: SubscriptionCycle.weekly,
          nextBillingDate: tenDaysAgo,
        ),
      ]);

      final updated = await repo.advanceOverdueBillingDates();

      expect(updated, hasLength(1));
      // Weekly sub 10 days ago: advances by 7 to 3 days ago (still past),
      // then by 7 again to 4 days from now (future). Should be at or after today.
      expect(
        updated.first.nextBillingDate.isAfter(today) ||
            updated.first.nextBillingDate.isAtSameMomentAs(today),
        isTrue,
      );
    });

    test('handles yearly cycle advancement correctly', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      // 400 days ago — yearly sub should advance once
      final longAgo = today.subtract(const Duration(days: 400));

      fakeBox.seed([
        TestSub.create(
          id: 'yearly-sub',
          cycle: SubscriptionCycle.yearly,
          nextBillingDate: longAgo,
        ),
      ]);

      final updated = await repo.advanceOverdueBillingDates();

      expect(updated, hasLength(1));
      expect(
        updated.first.nextBillingDate.isAfter(today) ||
            updated.first.nextBillingDate.isAtSameMomentAs(today),
        isTrue,
      );
    });
  });

  // ─── markAsPaid ───────────────────────────────────────────────

  group('markAsPaid', () {
    test('sets isPaid to true and records lastMarkedPaidDate', () async {
      fakeBox.seed([TestSub.create(id: 'sub-1', isPaid: false)]);

      await repo.markAsPaid('sub-1', true);

      final result = repo.getById('sub-1')!;
      expect(result.isPaid, isTrue);
      expect(result.lastMarkedPaidDate, isNotNull);
    });

    test('sets isPaid to false when un-marking', () async {
      fakeBox.seed([
        TestSub.create(
          id: 'sub-1',
          isPaid: true,
          lastMarkedPaidDate: DateTime.now(),
        ),
      ]);

      await repo.markAsPaid('sub-1', false);

      final result = repo.getById('sub-1')!;
      expect(result.isPaid, isFalse);
      // NOTE: lastMarkedPaidDate is NOT cleared because copyWith uses ??
      // (passing null keeps the old value). This is a known limitation of
      // the standard Dart copyWith pattern for nullable fields.
      // The field resets when billing date advances (isPaid → false via
      // advanceOverdueBillingDates, which doesn't copy lastMarkedPaidDate).
    });

    test('does nothing when subscription ID not found', () async {
      fakeBox.seed([TestSub.create(id: 'existing')]);

      // Should not throw
      await repo.markAsPaid('nonexistent', true);

      // Original sub unchanged
      expect(repo.getById('existing')!.isPaid, isFalse);
    });
  });

  // ─── Pause / Resume ──────────────────────────────────────────

  group('Pause / Resume', () {
    test('pauseSubscription sets isActive=false, pausedDate, increments pauseCount', () async {
      fakeBox.seed([
        TestSub.create(id: 'sub-1', isActive: true, pauseCount: 0),
      ]);

      await repo.pauseSubscription('sub-1');

      final result = repo.getById('sub-1')!;
      expect(result.isActive, isFalse);
      expect(result.pausedDate, isNotNull);
      expect(result.pauseCount, 1);
    });

    test('pauseSubscription stores resumeDate when provided', () async {
      final resumeDate = DateTime.now().add(const Duration(days: 14));
      fakeBox.seed([TestSub.create(id: 'sub-1')]);

      await repo.pauseSubscription('sub-1', resumeDate: resumeDate);

      final result = repo.getById('sub-1')!;
      expect(result.resumeDate, resumeDate);
    });

    test('resumeSubscription sets isActive=true, clears pausedDate and resumeDate', () async {
      fakeBox.seed([
        TestSub.paused(
          id: 'sub-1',
          pausedDate: DateTime.now().subtract(const Duration(days: 5)),
          resumeDate: DateTime.now().add(const Duration(days: 5)),
          pauseCount: 2,
        ),
      ]);

      await repo.resumeSubscription('sub-1');

      final result = repo.getById('sub-1')!;
      expect(result.isActive, isTrue);
      expect(result.pausedDate, isNull);
      expect(result.resumeDate, isNull);
      // pauseCount should be preserved
      expect(result.pauseCount, 2);
    });

    test('getSubscriptionsToAutoResume returns only subs with past resumeDate', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      final futureDate = DateTime.now().add(const Duration(days: 7));

      fakeBox.seed([
        TestSub.paused(id: 'should-resume', resumeDate: pastDate),
        TestSub.paused(id: 'not-yet', resumeDate: futureDate),
        TestSub.paused(id: 'manual-only'), // no resumeDate
        TestSub.create(id: 'active-sub'),  // active, not paused
      ]);

      final toResume = repo.getSubscriptionsToAutoResume();
      expect(toResume, hasLength(1));
      expect(toResume.first.id, 'should-resume');
    });

    test('autoResumeSubscriptions resumes eligible and returns them', () async {
      final pastDate = DateTime.now().subtract(const Duration(days: 1));

      fakeBox.seed([
        TestSub.paused(id: 'resume-me', resumeDate: pastDate),
        TestSub.paused(id: 'not-yet', resumeDate: DateTime.now().add(const Duration(days: 7))),
      ]);

      final resumed = await repo.autoResumeSubscriptions();

      expect(resumed, hasLength(1));
      expect(resumed.first.id, 'resume-me');
      expect(resumed.first.isActive, isTrue);

      // The other sub should still be paused
      expect(repo.getById('not-yet')!.isActive, isFalse);
    });
  });

  // ─── Filtering ────────────────────────────────────────────────

  group('Filtering', () {
    test('getUpcoming returns sorted active subs within day range', () {
      fakeBox.seed([
        TestSub.billingInDays(5, id: 'in-5', name: 'Five'),
        TestSub.billingInDays(1, id: 'in-1', name: 'One'),
        TestSub.billingInDays(15, id: 'in-15', name: 'Fifteen'),
        TestSub.billingInDays(35, id: 'in-35', name: 'ThirtyFive'), // outside 30 day range
      ]);

      final upcoming = repo.getUpcoming(30);

      expect(upcoming, hasLength(3));
      // Should be sorted by billing date ascending
      expect(upcoming[0].id, 'in-1');
      expect(upcoming[1].id, 'in-5');
      expect(upcoming[2].id, 'in-15');
    });

    test('getTrialsEndingSoon returns trials within range', () {
      fakeBox.seed([
        TestSub.trial(id: 'trial-soon', daysUntilEnd: 3),
        TestSub.trial(id: 'trial-later', daysUntilEnd: 20),
        TestSub.create(id: 'not-trial'), // not a trial
      ]);

      final trials = repo.getTrialsEndingSoon(7);

      expect(trials, hasLength(1));
      expect(trials.first.id, 'trial-soon');
    });

    test('getUpcoming returns empty for no matches', () {
      fakeBox.seed([
        TestSub.billingInDays(60, id: 'far-away'),
        TestSub.paused(id: 'paused'),
      ]);

      expect(repo.getUpcoming(30), isEmpty);
    });
  });

  // ─── Aggregation ──────────────────────────────────────────────

  group('Aggregation', () {
    test('calculateMonthlyTotal sums active subs effectiveMonthlyAmount', () {
      fakeBox.seed([
        TestSub.create(amount: 10.00, cycle: SubscriptionCycle.monthly),
        TestSub.create(amount: 20.00, cycle: SubscriptionCycle.monthly),
        TestSub.paused(), // should be excluded
      ]);

      // Two active monthly subs: 10 + 20 = 30
      expect(repo.calculateMonthlyTotal(), closeTo(30.0, 0.01));
    });

    test('calculateMonthlyTotal filters by currencyCode when provided', () {
      fakeBox.seed([
        TestSub.create(amount: 10.00, currencyCode: 'USD'),
        TestSub.create(amount: 20.00, currencyCode: 'EUR'),
        TestSub.create(amount: 5.00, currencyCode: 'USD'),
      ]);

      expect(repo.calculateMonthlyTotal(currencyCode: 'USD'), closeTo(15.0, 0.01));
    });

    test('getSpendingByCategory returns correct category map', () {
      fakeBox.seed([
        TestSub.create(amount: 15.99, category: SubscriptionCategory.entertainment),
        TestSub.create(amount: 9.99, category: SubscriptionCategory.entertainment),
        TestSub.create(amount: 12.00, category: SubscriptionCategory.fitness),
      ]);

      final spending = repo.getSpendingByCategory();

      expect(spending[SubscriptionCategory.entertainment], closeTo(25.98, 0.01));
      expect(spending[SubscriptionCategory.fitness], closeTo(12.0, 0.01));
      expect(spending.containsKey(SubscriptionCategory.gaming), isFalse);
    });
  });

  // ─── updateChecklistItem ──────────────────────────────────────

  group('updateChecklistItem', () {
    test('updates checklist completion at correct index', () async {
      fakeBox.seed([
        TestSub.create(
          id: 'sub-1',
          name: 'WithChecklist',
        ),
      ]);

      // The default factory doesn't set cancelChecklist/checklistCompleted,
      // so create one manually with checklist data
      final sub = Subscription(
        id: 'sub-cl',
        name: 'Checklist Sub',
        amount: 9.99,
        currencyCode: 'USD',
        cycle: SubscriptionCycle.monthly,
        nextBillingDate: DateTime.now().add(const Duration(days: 7)),
        startDate: DateTime.now(),
        category: SubscriptionCategory.entertainment,
        colorValue: 0xFF000000,
        reminders: ReminderConfig(),
        cancelChecklist: ['Step 1', 'Step 2', 'Step 3'],
        checklistCompleted: [false, false, false],
      );
      fakeBox.seed([sub]);

      await repo.updateChecklistItem('sub-cl', 1, true);

      final result = repo.getById('sub-cl')!;
      expect(result.checklistCompleted[0], isFalse);
      expect(result.checklistCompleted[1], isTrue);
      expect(result.checklistCompleted[2], isFalse);
    });
  });
}
