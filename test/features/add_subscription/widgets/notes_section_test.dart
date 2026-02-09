import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:custom_subs/features/add_subscription/widgets/notes_section.dart';
import 'package:custom_subs/core/widgets/form_section_card.dart';

void main() {
  group('NotesSection', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders with controller', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotesSection(
              notesController: controller,
            ),
          ),
        ),
      );

      // Find the FormSectionCard
      expect(find.byType(FormSectionCard), findsOneWidget);

      // Verify title and icon
      expect(find.text('Notes'), findsOneWidget);
      expect(find.byIcon(Icons.note_outlined), findsOneWidget);

      // Expand the section by tapping on it
      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();

      // Now find the text field
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('text input updates controller', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotesSection(
              notesController: controller,
            ),
          ),
        ),
      );

      // Expand the section
      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();

      // Find the text field
      final textField = find.byType(TextFormField);
      expect(textField, findsOneWidget);

      // Enter text
      await tester.enterText(textField, 'Test notes');
      await tester.pump();

      // Verify controller was updated
      expect(controller.text, 'Test notes');
    });

    testWidgets('multiline text works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotesSection(
              notesController: controller,
            ),
          ),
        ),
      );

      // Expand the section
      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();

      // Enter multiline text
      const multilineText = 'Line 1\nLine 2\nLine 3';
      await tester.enterText(find.byType(TextFormField), multilineText);
      await tester.pump();

      // Verify controller contains all lines
      expect(controller.text, multilineText);
    });

    testWidgets('displays hint text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotesSection(
              notesController: controller,
            ),
          ),
        ),
      );

      // Expand the section
      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();

      // Verify hint text is present
      expect(find.text('Add any additional notes...'), findsOneWidget);
    });

    testWidgets('displays label text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotesSection(
              notesController: controller,
            ),
          ),
        ),
      );

      // Expand the section
      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();

      // Tap to focus the field (shows label)
      await tester.tap(find.byType(TextFormField));
      await tester.pump();

      // Verify label text is present
      expect(find.text('General Notes'), findsOneWidget);
    });

    testWidgets('section is collapsible', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotesSection(
              notesController: controller,
            ),
          ),
        ),
      );

      // Find the FormSectionCard
      final formSectionCard = tester.widget<FormSectionCard>(
        find.byType(FormSectionCard),
      );

      // Verify it is collapsible
      expect(formSectionCard.isCollapsible, isTrue);
    });

    testWidgets('section starts collapsed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotesSection(
              notesController: controller,
            ),
          ),
        ),
      );

      // Find the FormSectionCard
      final formSectionCard = tester.widget<FormSectionCard>(
        find.byType(FormSectionCard),
      );

      // Verify it starts collapsed (initiallyExpanded: false)
      expect(formSectionCard.initiallyExpanded, isFalse);
    });
  });
}
