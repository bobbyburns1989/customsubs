import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:custom_subs/data/models/subscription.dart';
import 'package:custom_subs/data/repositories/subscription_repository.dart';
import 'package:custom_subs/data/services/notification_service.dart';
import 'package:custom_subs/data/services/analytics_service.dart';
import 'package:custom_subs/core/providers/settings_provider.dart';
import 'package:custom_subs/core/utils/currency_utils.dart';
import 'package:custom_subs/features/home/home_controller.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_subscription_factory.dart';

void main() {
  late MockSubscriptionRepository mockRepo;
  late MockNotificationService mockNotificationService;
  late MockAnalyticsService mockAnalyticsService;
  late ProviderContainer container;

  setUpAll(() async {
    // Register fallback values for mocktail matchers (must be in setUpAll)
    registerFallbackValue(TestSub.create(id: 'fallback'));

    // Load exchange rates for calculateMonthlyTotal tests.
    // Needs ServicesBinding for rootBundle access.
    TestWidgetsFlutterBinding.ensureInitialized();
    await CurrencyUtils.loadExchangeRates();
  });

  setUp(() {
    TestSub.resetCounter();
    mockRepo = MockSubscriptionRepository();
    mockNotificationService = MockNotificationService();
    mockAnalyticsService = MockAnalyticsService();

    // Default stubs
    when(() => mockRepo.getAll()).thenReturn([]);
    when(() => mockAnalyticsService.capture(any(), any())).thenReturn(null);

    // Stub notification service methods
    when(() => mockNotificationService.cancelNotificationsForSubscription(any()))
        .thenAnswer((_) async {});
    when(() => mockNotificationService.scheduleNotificationsForSubscription(any()))
        .thenAnswer((_) async {});
  });

  tearDown(() {
    container.dispose();
  });

  /// Creates a ProviderContainer and waits for the HomeController to load.
  /// Sets the controller state to [subs] for filtering tests.
  Future<HomeController> createController(List<Subscription> subs) async {
    when(() => mockRepo.getAll()).thenReturn(subs);

    container = ProviderContainer(
      overrides: [
        subscriptionRepositoryProvider.overrideWith((_) async => mockRepo),
        notificationServiceProvider.overrideWith((_) async => mockNotificationService),
        analyticsServiceProvider.overrideWith((_) => mockAnalyticsService),
        primaryCurrencyProvider.overrideWith((_) => 'USD'),
      ],
    );

    // Wait for the async build() to complete
    await container.read(homeControllerProvider.future);

    return container.read(homeControllerProvider.notifier);
  }

  // ─── getUpcomingSubscriptions ─────────────────────────────────

  group('getUpcomingSubscriptions', () {
    test('returns active subs within 30-day window', () async {
      final controller = await createController([
        TestSub.billingInDays(5, id: 'in-5'),
        TestSub.billingInDays(15, id: 'in-15'),
        TestSub.billingInDays(29, id: 'in-29'),
        TestSub.billingInDays(35, id: 'in-35'), // outside window
      ]);

      final upcoming = controller.getUpcomingSubscriptions();
      expect(upcoming, hasLength(3));
      expect(upcoming.map((s) => s.id), containsAll(['in-5', 'in-15', 'in-29']));
    });

    test('excludes paused subscriptions', () async {
      final controller = await createController([
        TestSub.billingInDays(5, id: 'active'),
        TestSub.paused(id: 'paused'),
      ]);

      final upcoming = controller.getUpcomingSubscriptions();
      expect(upcoming, hasLength(1));
      expect(upcoming.first.id, 'active');
    });

    test('includes subs billing today (todayStart boundary)', () async {
      final controller = await createController([
        TestSub.billingInDays(0, id: 'today'),
      ]);

      final upcoming = controller.getUpcomingSubscriptions();
      expect(upcoming, hasLength(1));
      expect(upcoming.first.id, 'today');
    });

    test('excludes subs at exact cutoff (exclusive upper bound)', () async {
      // days=30 means cutoff = todayStart + 30 days. Sub billing at day 30 is excluded.
      final controller = await createController([
        TestSub.billingInDays(30, id: 'at-cutoff'),
      ]);

      final upcoming = controller.getUpcomingSubscriptions();
      expect(upcoming, isEmpty);
    });

    test('sorts unpaid before paid', () async {
      final controller = await createController([
        TestSub.paid(id: 'paid', nextBillingDate: _todayPlus(5)),
        TestSub.billingInDays(10, id: 'unpaid'),
      ]);

      final upcoming = controller.getUpcomingSubscriptions();
      expect(upcoming, hasLength(2));
      expect(upcoming[0].id, 'unpaid');
      expect(upcoming[1].id, 'paid');
    });

    test('returns empty list when no state data', () async {
      final controller = await createController([]);
      expect(controller.getUpcomingSubscriptions(), isEmpty);
    });
  });

  // ─── getLaterSubscriptions ────────────────────────────────────

  group('getLaterSubscriptions', () {
    test('returns active subs in 31-90 day window', () async {
      final controller = await createController([
        TestSub.billingInDays(40, id: 'in-40'),
        TestSub.billingInDays(60, id: 'in-60'),
        TestSub.billingInDays(89, id: 'in-89'),
        TestSub.billingInDays(95, id: 'in-95'), // outside
      ]);

      final later = controller.getLaterSubscriptions();
      expect(later, hasLength(3));
    });

    test('no overlap with upcoming (boundary at day 31)', () async {
      // Day 30 should be in upcoming (with days=31), day 31 in later
      final controller = await createController([
        TestSub.billingInDays(30, id: 'day-30'),
        TestSub.billingInDays(31, id: 'day-31'),
      ]);

      final upcoming = controller.getUpcomingSubscriptions(days: 31);
      final later = controller.getLaterSubscriptions();

      // No sub should appear in both
      final upcomingIds = upcoming.map((s) => s.id).toSet();
      final laterIds = later.map((s) => s.id).toSet();
      expect(upcomingIds.intersection(laterIds), isEmpty);
    });

    test('excludes paused subs', () async {
      final controller = await createController([
        TestSub.billingInDays(50, id: 'active'),
        TestSub.paused(id: 'paused'),
      ]);

      final later = controller.getLaterSubscriptions();
      expect(later, hasLength(1));
      expect(later.first.id, 'active');
    });
  });

  // ─── getPausedSubscriptions ───────────────────────────────────

  group('getPausedSubscriptions', () {
    test('returns paused subs sorted by pausedDate descending', () async {
      final controller = await createController([
        TestSub.paused(
          id: 'paused-old',
          pausedDate: DateTime.now().subtract(const Duration(days: 10)),
        ),
        TestSub.paused(
          id: 'paused-new',
          pausedDate: DateTime.now().subtract(const Duration(days: 1)),
        ),
        TestSub.create(id: 'active'),
      ]);

      final paused = controller.getPausedSubscriptions();
      expect(paused, hasLength(2));
      // Most recently paused first
      expect(paused[0].id, 'paused-new');
      expect(paused[1].id, 'paused-old');
    });

    test('handles null pausedDates in sort', () async {
      final controller = await createController([
        TestSub.create(id: 'no-date', isActive: false), // pausedDate null
        TestSub.paused(
          id: 'has-date',
          pausedDate: DateTime.now(),
        ),
      ]);

      final paused = controller.getPausedSubscriptions();
      expect(paused, hasLength(2));
      // Sub with date sorts before null
      expect(paused[0].id, 'has-date');
      expect(paused[1].id, 'no-date');
    });
  });

  // ─── markAsPaid ───────────────────────────────────────────────

  group('markAsPaid', () {
    test('optimistically updates state without going through loading', () async {
      when(() => mockRepo.markAsPaid(any(), any())).thenAnswer((_) async {});

      final controller = await createController([
        TestSub.billingInDays(5, id: 'sub-1', isPaid: false),
      ]);

      // Track all state transitions
      final states = <AsyncValue<List<Subscription>>>[];
      container.listen(homeControllerProvider, (prev, next) {
        states.add(next);
      });

      await controller.markAsPaid('sub-1', true);

      // No AsyncLoading state should appear — only AsyncData
      expect(states.every((s) => s is AsyncData), isTrue);
      expect(states, isNotEmpty);
    });

    test('updated isPaid is reflected in state value', () async {
      when(() => mockRepo.markAsPaid(any(), any())).thenAnswer((_) async {});

      final controller = await createController([
        TestSub.billingInDays(5, id: 'sub-1', isPaid: false),
      ]);

      await controller.markAsPaid('sub-1', true);

      final subs = container.read(homeControllerProvider).value!;
      expect(subs.first.isPaid, isTrue);
    });

    test('cancels notifications when marking as paid', () async {
      when(() => mockRepo.markAsPaid(any(), any())).thenAnswer((_) async {});

      final controller = await createController([
        TestSub.billingInDays(5, id: 'sub-1'),
      ]);

      await controller.markAsPaid('sub-1', true);

      verify(() => mockNotificationService.cancelNotificationsForSubscription('sub-1')).called(1);
    });

    test('reschedules notifications when un-marking as paid', () async {
      when(() => mockRepo.markAsPaid(any(), any())).thenAnswer((_) async {});

      final controller = await createController([
        TestSub.paid(id: 'sub-1', nextBillingDate: _todayPlus(5)),
      ]);

      await controller.markAsPaid('sub-1', false);

      verify(() => mockNotificationService.scheduleNotificationsForSubscription(any())).called(1);
    });
  });

  // ─── calculateMonthlyTotal ────────────────────────────────────

  group('calculateMonthlyTotal', () {
    test('sums active subs (same currency, no conversion needed)', () async {
      final controller = await createController([
        TestSub.create(amount: 10.00, currencyCode: 'USD'),
        TestSub.create(amount: 20.00, currencyCode: 'USD'),
      ]);

      // Both subs are USD, primary currency is USD — no conversion
      final total = controller.calculateMonthlyTotal();
      expect(total, closeTo(30.0, 0.01));
    });

    test('excludes paused subs from total', () async {
      final controller = await createController([
        TestSub.create(amount: 10.00, currencyCode: 'USD'),
        TestSub.paused(), // should be excluded
      ]);

      final total = controller.calculateMonthlyTotal();
      expect(total, closeTo(10.0, 0.01));
    });
  });

  // ─── deleteSubscription ───────────────────────────────────────

  group('deleteSubscription', () {
    test('calls repository.delete and then refresh', () async {
      when(() => mockRepo.delete(any())).thenAnswer((_) async {});

      final controller = await createController([
        TestSub.create(id: 'sub-1'),
      ]);

      await controller.deleteSubscription('sub-1');

      verify(() => mockRepo.delete('sub-1')).called(1);
      // refresh() calls getAll() again
      verify(() => mockRepo.getAll()).called(greaterThanOrEqualTo(2));
    });
  });

  // ─── pauseSubscription ────────────────────────────────────────

  group('pauseSubscription', () {
    test('calls repository, cancels notifications, and refreshes', () async {
      when(() => mockRepo.pauseSubscription(any(), resumeDate: any(named: 'resumeDate')))
          .thenAnswer((_) async {});

      final controller = await createController([
        TestSub.create(id: 'sub-1'),
      ]);

      await controller.pauseSubscription('sub-1');

      verify(() => mockRepo.pauseSubscription('sub-1', resumeDate: null)).called(1);
      verify(() => mockNotificationService.cancelNotificationsForSubscription('sub-1')).called(1);
      // refresh was called
      verify(() => mockRepo.getAll()).called(greaterThanOrEqualTo(2));
    });
  });

  // ─── resumeSubscription ───────────────────────────────────────

  group('resumeSubscription', () {
    test('calls repository, reschedules notifications, and refreshes', () async {
      when(() => mockRepo.resumeSubscription(any())).thenAnswer((_) async {});
      final resumedSub = TestSub.create(id: 'sub-1');
      when(() => mockRepo.getById('sub-1')).thenReturn(resumedSub);

      final controller = await createController([
        TestSub.paused(id: 'sub-1'),
      ]);

      await controller.resumeSubscription('sub-1');

      verify(() => mockRepo.resumeSubscription('sub-1')).called(1);
      verify(() => mockNotificationService.scheduleNotificationsForSubscription(any())).called(1);
      verify(() => mockRepo.getAll()).called(greaterThanOrEqualTo(2));
    });
  });

  // ─── getActiveCount / getPausedCount ──────────────────────────

  group('counts', () {
    test('getActiveCount returns count of active subs', () async {
      final controller = await createController([
        TestSub.create(id: 'a1'),
        TestSub.create(id: 'a2'),
        TestSub.paused(id: 'p1'),
      ]);

      expect(controller.getActiveCount(), 2);
    });

    test('getPausedCount returns count of paused subs', () async {
      final controller = await createController([
        TestSub.create(id: 'a1'),
        TestSub.paused(id: 'p1'),
        TestSub.paused(id: 'p2'),
      ]);

      expect(controller.getPausedCount(), 2);
    });
  });
}

/// Helper: returns a DateTime that is [days] days from start of today.
DateTime _todayPlus(int days) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day).add(Duration(days: days));
}
