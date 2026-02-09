import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:custom_subs/features/add_subscription/widgets/cancellation_section.dart';
import 'package:custom_subs/core/widgets/form_section_card.dart';

void main() {
  group('CancellationSection', () {
    late TextEditingController cancelUrlController;
    late TextEditingController cancelPhoneController;
    late TextEditingController cancelNotesController;
    late List<String> cancelChecklist;

    setUp(() {
      cancelUrlController = TextEditingController();
      cancelPhoneController = TextEditingController();
      cancelNotesController = TextEditingController();
      cancelChecklist = [];
    });

    tearDown(() {
      cancelUrlController.dispose();
      cancelPhoneController.dispose();
      cancelNotesController.dispose();
    });

    Widget buildWidget() {
      return MaterialApp(
        home: Scaffold(
          body: CancellationSection(
            cancelUrlController: cancelUrlController,
            cancelPhoneController: cancelPhoneController,
            cancelNotesController: cancelNotesController,
            cancelChecklist: cancelChecklist,
            onChecklistChanged: (_) {},
          ),
        ),
      );
    }

    testWidgets('renders with FormSectionCard', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byType(FormSectionCard), findsOneWidget);
      expect(find.text('Cancellation Info'), findsOneWidget);
      expect(find.byIcon(Icons.exit_to_app_outlined), findsOneWidget);
    });

    testWidgets('renders all text fields', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      // Expand section
      await tester.tap(find.text('Cancellation Info'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, 'Cancellation URL'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Cancellation Phone'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Cancellation Notes'), findsOneWidget);
    });

    testWidgets('text fields update controllers', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      // Expand section
      await tester.tap(find.text('Cancellation Info'));
      await tester.pumpAndSettle();

      // Enter URL
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Cancellation URL'),
        'https://example.com/cancel',
      );
      expect(cancelUrlController.text, 'https://example.com/cancel');

      // Enter phone
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Cancellation Phone'),
        '+1 555 123 4567',
      );
      expect(cancelPhoneController.text, '+1 555 123 4567');

      // Enter notes
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Cancellation Notes'),
        'Call customer service',
      );
      expect(cancelNotesController.text, 'Call customer service');
    });

    testWidgets('add step button exists', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      // Expand section
      await tester.tap(find.text('Cancellation Info'));
      await tester.pumpAndSettle();

      // Verify "Add Step" button exists
      expect(find.text('Add Step'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('empty checklist renders without steps', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      // Expand section
      await tester.tap(find.text('Cancellation Info'));
      await tester.pumpAndSettle();

      // Should not find any step labels
      expect(find.textContaining('Step '), findsNothing);
      // Should still have "Add Step" button
      expect(find.text('Add Step'), findsOneWidget);
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

    testWidgets('multiple checklist items render correctly', (WidgetTester tester) async {
      cancelChecklist = ['First step', 'Second step', 'Third step'];

      await tester.pumpWidget(buildWidget());

      // Expand section
      await tester.tap(find.text('Cancellation Info'));
      await tester.pumpAndSettle();

      // Should find all step labels
      expect(find.text('Step 1'), findsOneWidget);
      expect(find.text('Step 2'), findsOneWidget);
      expect(find.text('Step 3'), findsOneWidget);

      // Should find all step values
      expect(find.widgetWithText(TextFormField, 'Step 1'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Step 2'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Step 3'), findsOneWidget);

      // Should find delete buttons
      expect(find.byIcon(Icons.delete), findsNWidgets(3));
    });
  });
}
