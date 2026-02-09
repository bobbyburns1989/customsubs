import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:custom_subs/features/add_subscription/widgets/trial_section.dart';
import 'package:custom_subs/core/widgets/form_section_card.dart';

void main() {
  group('TrialSection', () {
    late bool isTrial;
    late DateTime? trialEndDate;
    late double? postTrialAmount;
    double? lastAmountChanged;

    setUp(() {
      isTrial = false;
      trialEndDate = null;
      postTrialAmount = null;
      lastAmountChanged = null;
    });

    Widget buildWidget() {
      return MaterialApp(
        home: Scaffold(
          body: TrialSection(
            isTrial: isTrial,
            trialEndDate: trialEndDate,
            postTrialAmount: postTrialAmount,
            onTrialChanged: (_) {},
            onTrialEndDateChanged: (_) {},
            onPostTrialAmountChanged: (value) => lastAmountChanged = value,
            onSetTrialEndDate: () {},
          ),
        ),
      );
    }

    testWidgets('renders with FormSectionCard', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byType(FormSectionCard), findsOneWidget);
      expect(find.text('Free Trial'), findsOneWidget);
      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    });

    testWidgets('fields only visible when isTrial is true', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      // Expand section
      await tester.tap(find.text('Free Trial'));
      await tester.pumpAndSettle();

      // When isTrial is false, trial fields should not be visible
      expect(find.text('Set Trial End Date'), findsNothing);
      expect(find.widgetWithText(TextFormField, 'Amount after trial'), findsNothing);
    });

    testWidgets('fields visible when isTrial is true', (WidgetTester tester) async {
      isTrial = true;

      await tester.pumpWidget(buildWidget());

      // Expand section
      await tester.tap(find.text('Free Trial'));
      await tester.pumpAndSettle();

      // When isTrial is true, should show set button (no date yet)
      expect(find.text('Set Trial End Date'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Amount after trial'), findsOneWidget);
    });

    testWidgets('post-trial amount field calls onPostTrialAmountChanged', (WidgetTester tester) async{
      isTrial = true;

      await tester.pumpWidget(buildWidget());

      // Expand section
      await tester.tap(find.text('Free Trial'));
      await tester.pumpAndSettle();

      // Find and enter amount
      final amountField = find.widgetWithText(TextFormField, 'Amount after trial');
      await tester.enterText(amountField, '9.99');
      await tester.pump();

      expect(lastAmountChanged, 9.99);
    });

    testWidgets('post-trial amount handles invalid input', (WidgetTester tester) async {
      isTrial = true;

      await tester.pumpWidget(buildWidget());

      // Expand section
      await tester.tap(find.text('Free Trial'));
      await tester.pumpAndSettle();

      // Enter invalid amount
      final amountField = find.widgetWithText(TextFormField, 'Amount after trial');
      await tester.enterText(amountField, 'abc');
      await tester.pump();

      expect(lastAmountChanged, isNull);
    });

    testWidgets('section is collapsible', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      final formSectionCard = tester.widget<FormSectionCard>(
        find.byType(FormSectionCard),
      );

      expect(formSectionCard.isCollapsible, isTrue);
    });

    testWidgets('section starts collapsed', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      final formSectionCard = tester.widget<FormSectionCard>(
        find.byType(FormSectionCard),
      );

      expect(formSectionCard.initiallyExpanded, isFalse);
    });

    testWidgets('displays existing post-trial amount', (WidgetTester tester) async {
      isTrial = true;
      postTrialAmount = 15.99;

      await tester.pumpWidget(buildWidget());

      // Expand section
      await tester.tap(find.text('Free Trial'));
      await tester.pumpAndSettle();

      // Find the amount field and verify it shows existing value
      final amountField = find.widgetWithText(TextFormField, 'Amount after trial');
      final textFormField = tester.widget<TextFormField>(amountField);

      expect(textFormField.initialValue, '15.99');
    });
  });
}
