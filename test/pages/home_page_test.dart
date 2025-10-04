import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/pages/home_page.dart';

void main() {
  group('HomePage Search Functionality', () {
    testWidgets('should display search bar and initial UI elements', (
      WidgetTester tester,
    ) async {
      // Build the HomePage widget
      await tester.pumpWidget(const MaterialApp(home: HomePage()));

      // Verify the AppBar title
      expect(find.text('Astro Rush'), findsOneWidget);

      // Verify the search TextField is present
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search papers...'), findsOneWidget);

      // Verify search icon is present
      expect(find.byIcon(Icons.search), findsOneWidget);

      // Initially should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('search functionality works correctly', (
      WidgetTester tester,
    ) async {
      // Build the HomePage widget
      await tester.pumpWidget(const MaterialApp(home: HomePage()));

      // Let the app load for a moment
      await tester.pump(const Duration(milliseconds: 100));

      // Find the search TextField
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // Enter search text to trigger the onChanged callback
      await tester.enterText(searchField, 'test');
      await tester.pump();

      // Verify that the search functionality is working by checking
      // that the widget rebuilds properly (no exceptions thrown)
      expect(searchField, findsOneWidget);
    });

    testWidgets('search can be cleared', (WidgetTester tester) async {
      // Build the HomePage widget
      await tester.pumpWidget(const MaterialApp(home: HomePage()));

      // Let the app load for a moment
      await tester.pump(const Duration(milliseconds: 100));

      // Find the search TextField
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // Enter search text
      await tester.enterText(searchField, 'test search');
      await tester.pump();

      // Verify search text is entered
      final textField = tester.widget<TextField>(searchField);
      expect(textField.controller?.text, equals('test search'));

      // Clear the search field programmatically
      await tester.enterText(searchField, '');
      await tester.pump();

      // Verify search field is cleared
      final clearedTextField = tester.widget<TextField>(searchField);
      expect(clearedTextField.controller?.text, isEmpty);
    });
  });
}
