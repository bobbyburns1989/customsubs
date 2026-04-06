import 'package:flutter_test/flutter_test.dart';
import 'package:custom_subs/core/extensions/date_extensions.dart';

void main() {
  group('DateTimeExtensions', () {
    group('addMonths', () {
      test('normal case: Mar 15 + 1 = Apr 15', () {
        final date = DateTime(2026, 3, 15);
        expect(date.addMonths(1), DateTime(2026, 4, 15));
      });

      test('month-end overflow: Jan 31 + 1 = Feb 28 (non-leap)', () {
        final date = DateTime(2025, 1, 31);
        expect(date.addMonths(1), DateTime(2025, 2, 28));
      });

      test('month-end overflow: Jan 31 + 1 = Feb 29 (leap year 2028)', () {
        final date = DateTime(2028, 1, 31);
        expect(date.addMonths(1), DateTime(2028, 2, 29));
      });

      test('Jan 31 + 2 = Mar 31', () {
        final date = DateTime(2026, 1, 31);
        expect(date.addMonths(2), DateTime(2026, 3, 31));
      });

      test('quarterly: Jan 31 + 3 = Apr 30', () {
        final date = DateTime(2026, 1, 31);
        expect(date.addMonths(3), DateTime(2026, 4, 30));
      });

      test('biannual: Mar 15 + 6 = Sep 15', () {
        final date = DateTime(2026, 3, 15);
        expect(date.addMonths(6), DateTime(2026, 9, 15));
      });

      test('yearly: Jun 15 + 12 = Jun 15 next year', () {
        final date = DateTime(2026, 6, 15);
        expect(date.addMonths(12), DateTime(2027, 6, 15));
      });

      test('yearly: Feb 29 leap + 12 = Feb 28 non-leap', () {
        final date = DateTime(2024, 2, 29);
        expect(date.addMonths(12), DateTime(2025, 2, 28));
      });

      test('Dec + 1 = Jan next year', () {
        final date = DateTime(2026, 12, 15);
        expect(date.addMonths(1), DateTime(2027, 1, 15));
      });

      test('preserves time component', () {
        final date = DateTime(2026, 3, 15, 10, 30, 45);
        final result = date.addMonths(1);
        expect(result.hour, 10);
        expect(result.minute, 30);
        expect(result.second, 45);
      });
    });

    group('isToday', () {
      test('today returns true', () {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day, 14, 30);
        expect(today.isToday, true);
      });

      test('yesterday returns false', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(yesterday.isToday, false);
      });

      test('tomorrow returns false', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(tomorrow.isToday, false);
      });
    });

    group('isTomorrow', () {
      test('tomorrow returns true', () {
        final now = DateTime.now();
        final tomorrow = DateTime(now.year, now.month, now.day)
            .add(const Duration(days: 1));
        expect(tomorrow.isTomorrow, true);
      });

      test('today returns false', () {
        expect(DateTime.now().isTomorrow, false);
      });
    });

    group('startOfDay / endOfDay', () {
      test('startOfDay strips time', () {
        final date = DateTime(2026, 3, 15, 14, 30, 45);
        final start = date.startOfDay;
        expect(start, DateTime(2026, 3, 15));
        expect(start.hour, 0);
        expect(start.minute, 0);
      });

      test('endOfDay sets to 23:59:59.999', () {
        final date = DateTime(2026, 3, 15, 8, 0);
        final end = date.endOfDay;
        expect(end.hour, 23);
        expect(end.minute, 59);
        expect(end.second, 59);
        expect(end.millisecond, 999);
      });
    });
  });
}
