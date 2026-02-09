import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:custom_subs/features/add_subscription/widgets/subscription_details_section.dart';
import 'package:custom_subs/data/models/subscription_cycle.dart';
import 'package:custom_subs/data/models/subscription_category.dart';
import 'package:custom_subs/core/widgets/form_section_card.dart';

void main() {
  group('SubscriptionDetailsSection', () {
    late TextEditingController nameController;
    late TextEditingController amountController;
    late String currencyCode;
    late SubscriptionCycle cycle;
    late DateTime nextBillingDate;
    late SubscriptionCategory category;

    setUp(() {
      nameController = TextEditingController();
      amountController = TextEditingController();
      currencyCode = 'USD';
      cycle = SubscriptionCycle.monthly;
      nextBillingDate = DateTime(2024, 3, 1);
      category = SubscriptionCategory.entertainment;
    });

    tearDown(() {
      nameController.dispose();
      amountController.dispose();
    });

    Widget buildWidget() {
      return MaterialApp(
        home: Scaffold(
          body: SubscriptionDetailsSection(
            nameController: nameController,
            amountController: amountController,
            currencyCode: currencyCode,
            cycle: cycle,
            nextBillingDate: nextBillingDate,
            category: category,
            onCurrencyChanged: (_) {},
            onCycleChanged: (_) {},
            onNextBillingDateChanged: (_) {},
            onCategoryChanged: (_) {},
          ),
        ),
      );
    }

    testWidgets('renders all fields', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      // Verify FormSectionCard
      expect(find.byType(FormSectionCard), findsOneWidget);
      expect(find.text('Subscription Details'), findsOneWidget);

      // Verify name field
      expect(find.widgetWithText(TextFormField, 'Name *'), findsOneWidget);

      // Verify amount field
      expect(find.widgetWithText(TextFormField, 'Amount *'), findsOneWidget);

      // Verify currency dropdown
      expect(find.widgetWithText(DropdownButtonFormField<String>, 'Currency'), findsOneWidget);

      // Verify cycle dropdown
      expect(find.widgetWithText(DropdownButtonFormField<SubscriptionCycle>, 'Billing Cycle *'), findsOneWidget);

      // Verify category dropdown
      expect(find.widgetWithText(DropdownButtonFormField<SubscriptionCategory>, 'Category *'), findsOneWidget);
    });

    testWidgets('name validation works for empty name', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      final nameField = find.widgetWithText(TextFormField, 'Name *');
      final textFormField = tester.widget<TextFormField>(nameField);

      // Test empty string
      expect(textFormField.validator!(''), 'Please enter a name');
      expect(textFormField.validator!('   '), 'Please enter a name');
    });

    testWidgets('name validation works for valid name', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      final nameField = find.widgetWithText(TextFormField, 'Name *');
      final textFormField = tester.widget<TextFormField>(nameField);

      // Test valid name
      expect(textFormField.validator!('Netflix'), isNull);
    });

    testWidgets('amount validation rejects empty', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      final amountField = find.widgetWithText(TextFormField, 'Amount *');
      final textFormField = tester.widget<TextFormField>(amountField);

      expect(textFormField.validator!(''), 'Required');
      expect(textFormField.validator!('   '), 'Required');
    });

    testWidgets('amount validation rejects negative and zero', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      final amountField = find.widgetWithText(TextFormField, 'Amount *');
      final textFormField = tester.widget<TextFormField>(amountField);

      expect(textFormField.validator!('-5.99'), 'Invalid amount');
      expect(textFormField.validator!('0'), 'Invalid amount');
      expect(textFormField.validator!('0.00'), 'Invalid amount');
    });

    testWidgets('amount validation rejects non-numeric', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      final amountField = find.widgetWithText(TextFormField, 'Amount *');
      final textFormField = tester.widget<TextFormField>(amountField);

      expect(textFormField.validator!('abc'), 'Invalid amount');
    });

    testWidgets('amount validation accepts valid amounts', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      final amountField = find.widgetWithText(TextFormField, 'Amount *');
      final textFormField = tester.widget<TextFormField>(amountField);

      expect(textFormField.validator!('15.99'), isNull);
      expect(textFormField.validator!('10'), isNull);
      expect(textFormField.validator!('0.01'), isNull);
    });

    testWidgets('section is not collapsible', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      final formSectionCard = tester.widget<FormSectionCard>(
        find.byType(FormSectionCard),
      );

      expect(formSectionCard.isCollapsible, isFalse);
    });
  });
}
