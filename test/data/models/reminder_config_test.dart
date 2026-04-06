import 'package:flutter_test/flutter_test.dart';
import 'package:custom_subs/data/models/reminder_config.dart';

void main() {
  group('ReminderConfig', () {
    group('defaults', () {
      test('has correct default values', () {
        final config = ReminderConfig();
        expect(config.firstReminderDays, 7);
        expect(config.secondReminderDays, 1);
        expect(config.remindOnBillingDay, true);
        expect(config.reminderHour, 9);
        expect(config.reminderMinute, 0);
      });

      test('defaultConfig returns same as constructor', () {
        final a = ReminderConfig();
        final b = ReminderConfig.defaultConfig();
        expect(a, equals(b));
      });
    });

    group('toJson / fromJson roundtrip', () {
      test('preserves all fields', () {
        final config = ReminderConfig(
          firstReminderDays: 3,
          secondReminderDays: 2,
          remindOnBillingDay: false,
          reminderHour: 14,
          reminderMinute: 30,
        );
        final json = config.toJson();
        final restored = ReminderConfig.fromJson(json);
        expect(restored, equals(config));
      });

      test('preserves default config', () {
        final config = ReminderConfig();
        final json = config.toJson();
        final restored = ReminderConfig.fromJson(json);
        expect(restored, equals(config));
      });
    });

    group('fromJson with missing keys', () {
      test('missing firstReminderDays defaults to 7', () {
        final config = ReminderConfig.fromJson({});
        expect(config.firstReminderDays, 7);
      });

      test('missing secondReminderDays defaults to 1', () {
        final config = ReminderConfig.fromJson({});
        expect(config.secondReminderDays, 1);
      });

      test('missing remindOnBillingDay defaults to true', () {
        final config = ReminderConfig.fromJson({});
        expect(config.remindOnBillingDay, true);
      });

      test('missing reminderHour defaults to 9', () {
        final config = ReminderConfig.fromJson({});
        expect(config.reminderHour, 9);
      });

      test('missing reminderMinute defaults to 0', () {
        final config = ReminderConfig.fromJson({});
        expect(config.reminderMinute, 0);
      });
    });

    group('copyWith', () {
      test('changes only specified field', () {
        final original = ReminderConfig();
        final copy = original.copyWith(firstReminderDays: 14);
        expect(copy.firstReminderDays, 14);
        expect(copy.secondReminderDays, 1);
        expect(copy.reminderHour, 9);
      });
    });

    group('equality', () {
      test('equal when all fields match', () {
        final a = ReminderConfig(firstReminderDays: 3, reminderHour: 10);
        final b = ReminderConfig(firstReminderDays: 3, reminderHour: 10);
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when any field differs', () {
        final a = ReminderConfig(firstReminderDays: 3);
        final b = ReminderConfig(firstReminderDays: 5);
        expect(a, isNot(equals(b)));
      });
    });
  });
}
