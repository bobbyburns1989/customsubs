import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_subs/app/app.dart';

void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(
      const ProviderScope(
        child: CustomSubsApp(),
      ),
    );

    // Wait for async operations
    await tester.pumpAndSettle();

    // Verify app loaded successfully
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
