// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:astrolens/main.dart';

void main() {
  testWidgets('HomePage loads and displays app bar', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AstroLensApp());

    // Verify that the app bar shows the correct title.
    expect(find.text('Astro Rush'), findsOneWidget);

    // Verify that the search bar is present.
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Search papers...'), findsOneWidget);

    // Verify that there's a search icon.
    expect(find.byIcon(Icons.search), findsOneWidget);
  });

  testWidgets('HomePage shows loading indicator initially', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AstroLensApp());

    // Initially should show loading indicator.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
