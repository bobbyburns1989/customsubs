import 'package:flutter_test/flutter_test.dart';
import 'package:custom_subs/features/add_subscription/models/subscription_form_state.dart';
import 'package:custom_subs/data/models/subscription.dart';
import 'package:custom_subs/data/models/subscription_cycle.dart';
import 'package:custom_subs/data/models/subscription_category.dart';
import 'package:custom_subs/data/models/reminder_config.dart';
import 'package:custom_subs/data/services/template_service.dart';

void main() {
  group('SubscriptionFormState', () {
    late SubscriptionFormState formState;

    setUp(() {
      formState = SubscriptionFormState();
    });

    tearDown(() {
      formState.dispose();
    });

    group('Initialization', () {
      test('controllers are initialized properly', () {
        expect(formState.nameController.text, isEmpty);
        expect(formState.amountController.text, isEmpty);
        expect(formState.cancelUrlController.text, isEmpty);
        expect(formState.cancelPhoneController.text, isEmpty);
        expect(formState.cancelNotesController.text, isEmpty);
        expect(formState.notesController.text, isEmpty);
        expect(formState.searchController.text, isEmpty);
      });
    });

    group('loadFromSubscription', () {
      test('populates all controllers from subscription', () {
        final subscription = Subscription(
          id: 'test-id',
          name: 'Netflix',
          amount: 15.99,
          currencyCode: 'USD',
          cycle: SubscriptionCycle.monthly,
          nextBillingDate: DateTime(2024, 3, 1),
          startDate: DateTime(2024, 1, 1),
          category: SubscriptionCategory.entertainment,
          colorValue: 0xFFE50914,
          reminders: ReminderConfig(),
          cancelUrl: 'https://netflix.com/cancel',
          cancelPhone: '+1-555-0100',
          cancelNotes: 'Call customer service',
          notes: 'Shared account',
        );

        formState.loadFromSubscription(subscription);

        expect(formState.nameController.text, 'Netflix');
        expect(formState.amountController.text, '15.99');
        expect(formState.cancelUrlController.text, 'https://netflix.com/cancel');
        expect(formState.cancelPhoneController.text, '+1-555-0100');
        expect(formState.cancelNotesController.text, 'Call customer service');
        expect(formState.notesController.text, 'Shared account');
      });

      test('handles null optional fields with empty strings', () {
        final subscription = Subscription(
          id: 'test-id',
          name: 'Spotify',
          amount: 9.99,
          currencyCode: 'USD',
          cycle: SubscriptionCycle.monthly,
          nextBillingDate: DateTime(2024, 3, 1),
          startDate: DateTime(2024, 1, 1),
          category: SubscriptionCategory.entertainment,
          colorValue: 0xFF1DB954,
          reminders: ReminderConfig(),
          cancelUrl: null,
          cancelPhone: null,
          cancelNotes: null,
          notes: null,
        );

        formState.loadFromSubscription(subscription);

        expect(formState.nameController.text, 'Spotify');
        expect(formState.amountController.text, '9.99');
        expect(formState.cancelUrlController.text, isEmpty);
        expect(formState.cancelPhoneController.text, isEmpty);
        expect(formState.cancelNotesController.text, isEmpty);
        expect(formState.notesController.text, isEmpty);
      });
    });

    group('loadFromTemplate', () {
      test('populates controllers from template', () {
        final template = SubscriptionTemplate(
          id: 'netflix',
          name: 'Netflix',
          defaultAmount: 15.49,
          defaultCurrency: 'USD',
          defaultCycle: SubscriptionCycle.monthly,
          category: SubscriptionCategory.entertainment,
          color: 0xFFE50914,
          cancelUrl: 'https://www.netflix.com/cancelplan',
        );

        formState.loadFromTemplate(template);

        expect(formState.nameController.text, 'Netflix');
        expect(formState.amountController.text, '15.49');
        expect(formState.cancelUrlController.text, 'https://www.netflix.com/cancelplan');
      });

      test('handles template without cancelUrl', () {
        final template = SubscriptionTemplate(
          id: 'custom',
          name: 'Custom Service',
          defaultAmount: 10.0,
          defaultCurrency: 'USD',
          defaultCycle: SubscriptionCycle.monthly,
          category: SubscriptionCategory.other,
          color: 0xFF000000,
          cancelUrl: null,
        );

        formState.loadFromTemplate(template);

        expect(formState.nameController.text, 'Custom Service');
        expect(formState.amountController.text, '10.0');
        expect(formState.cancelUrlController.text, isEmpty);
      });
    });

    group('validate', () {
      test('returns false for empty name', () {
        formState.nameController.text = '';
        formState.amountController.text = '15.99';

        expect(formState.validate(), isFalse);
      });

      test('returns false for whitespace-only name', () {
        formState.nameController.text = '   ';
        formState.amountController.text = '15.99';

        expect(formState.validate(), isFalse);
      });

      test('returns false for empty amount', () {
        formState.nameController.text = 'Netflix';
        formState.amountController.text = '';

        expect(formState.validate(), isFalse);
      });

      test('returns false for negative amount', () {
        formState.nameController.text = 'Netflix';
        formState.amountController.text = '-5.99';

        expect(formState.validate(), isFalse);
      });

      test('returns false for zero amount', () {
        formState.nameController.text = 'Netflix';
        formState.amountController.text = '0';

        expect(formState.validate(), isFalse);
      });

      test('returns false for non-numeric amount', () {
        formState.nameController.text = 'Netflix';
        formState.amountController.text = 'abc';

        expect(formState.validate(), isFalse);
      });

      test('returns true for valid name and amount', () {
        formState.nameController.text = 'Netflix';
        formState.amountController.text = '15.99';

        expect(formState.validate(), isTrue);
      });

      test('returns true for valid name with surrounding whitespace', () {
        formState.nameController.text = '  Netflix  ';
        formState.amountController.text = '15.99';

        expect(formState.validate(), isTrue);
      });

      test('returns true for amount with surrounding whitespace', () {
        formState.nameController.text = 'Netflix';
        formState.amountController.text = '  15.99  ';

        expect(formState.validate(), isTrue);
      });

      test('returns true for decimal amount', () {
        formState.nameController.text = 'Netflix';
        formState.amountController.text = '9.99';

        expect(formState.validate(), isTrue);
      });

      test('returns true for whole number amount', () {
        formState.nameController.text = 'Netflix';
        formState.amountController.text = '10';

        expect(formState.validate(), isTrue);
      });
    });

    group('toFormData', () {
      test('returns correct data structure with all fields', () {
        formState.nameController.text = 'Netflix';
        formState.amountController.text = '15.99';
        formState.cancelUrlController.text = 'https://netflix.com/cancel';
        formState.cancelPhoneController.text = '+1-555-0100';
        formState.cancelNotesController.text = 'Call customer service';
        formState.notesController.text = 'Shared account';

        final data = formState.toFormData();

        expect(data.name, 'Netflix');
        expect(data.amount, 15.99);
        expect(data.cancelUrl, 'https://netflix.com/cancel');
        expect(data.cancelPhone, '+1-555-0100');
        expect(data.cancelNotes, 'Call customer service');
        expect(data.notes, 'Shared account');
      });

      test('trims whitespace from all fields', () {
        formState.nameController.text = '  Netflix  ';
        formState.amountController.text = '  15.99  ';
        formState.cancelUrlController.text = '  https://netflix.com/cancel  ';

        final data = formState.toFormData();

        expect(data.name, 'Netflix');
        expect(data.amount, 15.99);
        expect(data.cancelUrl, 'https://netflix.com/cancel');
      });

      test('converts empty strings to null for optional fields', () {
        formState.nameController.text = 'Netflix';
        formState.amountController.text = '15.99';
        formState.cancelUrlController.text = '';
        formState.cancelPhoneController.text = '';
        formState.cancelNotesController.text = '';
        formState.notesController.text = '';

        final data = formState.toFormData();

        expect(data.name, 'Netflix');
        expect(data.amount, 15.99);
        expect(data.cancelUrl, isNull);
        expect(data.cancelPhone, isNull);
        expect(data.cancelNotes, isNull);
        expect(data.notes, isNull);
      });

      test('converts whitespace-only strings to null for optional fields', () {
        formState.nameController.text = 'Netflix';
        formState.amountController.text = '15.99';
        formState.cancelUrlController.text = '   ';
        formState.cancelPhoneController.text = '   ';

        final data = formState.toFormData();

        expect(data.cancelUrl, isNull);
        expect(data.cancelPhone, isNull);
      });

      test('returns 0.0 for invalid amount', () {
        formState.nameController.text = 'Netflix';
        formState.amountController.text = 'invalid';

        final data = formState.toFormData();

        expect(data.amount, 0.0);
      });
    });

    group('clear', () {
      test('clears all controllers', () {
        formState.nameController.text = 'Netflix';
        formState.amountController.text = '15.99';
        formState.cancelUrlController.text = 'https://netflix.com/cancel';
        formState.cancelPhoneController.text = '+1-555-0100';
        formState.cancelNotesController.text = 'Call customer service';
        formState.notesController.text = 'Shared account';
        formState.searchController.text = 'netflix';

        formState.clear();

        expect(formState.nameController.text, isEmpty);
        expect(formState.amountController.text, isEmpty);
        expect(formState.cancelUrlController.text, isEmpty);
        expect(formState.cancelPhoneController.text, isEmpty);
        expect(formState.cancelNotesController.text, isEmpty);
        expect(formState.notesController.text, isEmpty);
        expect(formState.searchController.text, isEmpty);
      });
    });

    group('dispose', () {
      test('disposes all controllers without error', () {
        final testFormState = SubscriptionFormState();

        // Should not throw
        expect(() => testFormState.dispose(), returnsNormally);
      });

      test('controllers cannot be used after dispose', () {
        final testFormState = SubscriptionFormState();
        testFormState.dispose();

        // Accessing disposed controller should throw
        expect(
          () => testFormState.nameController.text = 'test',
          throwsFlutterError,
        );
      });
    });

    group('SubscriptionFormData', () {
      test('creates instance with required fields', () {
        const data = SubscriptionFormData(
          name: 'Netflix',
          amount: 15.99,
        );

        expect(data.name, 'Netflix');
        expect(data.amount, 15.99);
        expect(data.cancelUrl, isNull);
        expect(data.cancelPhone, isNull);
        expect(data.cancelNotes, isNull);
        expect(data.notes, isNull);
      });

      test('creates instance with all fields', () {
        const data = SubscriptionFormData(
          name: 'Netflix',
          amount: 15.99,
          cancelUrl: 'https://netflix.com/cancel',
          cancelPhone: '+1-555-0100',
          cancelNotes: 'Call customer service',
          notes: 'Shared account',
        );

        expect(data.name, 'Netflix');
        expect(data.amount, 15.99);
        expect(data.cancelUrl, 'https://netflix.com/cancel');
        expect(data.cancelPhone, '+1-555-0100');
        expect(data.cancelNotes, 'Call customer service');
        expect(data.notes, 'Shared account');
      });
    });
  });
}
