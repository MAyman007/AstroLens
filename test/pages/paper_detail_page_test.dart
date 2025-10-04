import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrolens/pages/paper_detail_page.dart';
import 'package:astrolens/models/research_paper.dart';

void main() {
  group('PaperDetailPage', () {
    late ResearchPaper testPaper;

    setUp(() {
      testPaper = ResearchPaper(
        id: 1,
        title: 'Test Paper Title',
        link: 'https://example.com/paper',
        abstract: 'This is a test abstract for the research paper.',
        introduction: 'This is the introduction section.',
        materialsMethods: 'This is the materials and methods section.',
        results: 'This is the results section.',
        discussion: 'This is the discussion section.',
        simplifiedAiVersion: 'This is a simplified AI-generated summary.',
        keywords: ['test', 'paper', 'research'],
      );
    });

    testWidgets('should display paper title', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(home: PaperDetailPage(paper: testPaper)),
      );

      // Act
      await tester.pump();

      // Assert
      expect(find.text('Test Paper Title'), findsOneWidget);
    });

    testWidgets('should display app bar with correct title', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(home: PaperDetailPage(paper: testPaper)),
      );

      // Act
      await tester.pump();

      // Assert
      expect(find.text('Paper Details'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display AI summary by default', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(home: PaperDetailPage(paper: testPaper)),
      );

      // Act
      await tester.pump();

      // Assert
      expect(
        find.text('This is a simplified AI-generated summary.'),
        findsOneWidget,
      );
    });

    testWidgets('should display loading indicator when fetching API data', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(home: PaperDetailPage(paper: testPaper)),
      );

      // Act - Don't wait for the async operation to complete
      // This should show the loading indicator immediately

      // Assert - The app bar loading indicator should be present
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
    });
    testWidgets('should handle loading state properly', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(home: PaperDetailPage(paper: testPaper)),
      );

      // Act - Initial state should show the paper data
      await tester.pump();

      // Assert - Paper title should be visible
      expect(find.text('Test Paper Title'), findsOneWidget);

      // The API call will start in the background, but we're testing
      // that the basic UI loads correctly with the provided paper data
    });

    testWidgets('should display keywords when available', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(home: PaperDetailPage(paper: testPaper)),
      );

      // Act
      await tester.pump();

      // Assert
      expect(find.text('Keywords'), findsOneWidget);
      expect(find.text('test'), findsOneWidget);
      expect(find.text('paper'), findsOneWidget);
      expect(find.text('research'), findsOneWidget);
    });

    testWidgets('should display Read Original Paper button', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(home: PaperDetailPage(paper: testPaper)),
      );

      // Act
      await tester.pump();

      // Assert
      expect(find.text('Read Original Paper'), findsOneWidget);
      expect(find.byIcon(Icons.open_in_new), findsOneWidget);
    });

    testWidgets('should display paper source URL', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(home: PaperDetailPage(paper: testPaper)),
      );

      // Act
      await tester.pump();

      // Assert
      expect(find.text('Source:'), findsOneWidget);
      expect(find.text('https://example.com/paper'), findsOneWidget);
    });

    testWidgets('should handle paper without keywords', (
      WidgetTester tester,
    ) async {
      // Arrange
      final paperWithoutKeywords = ResearchPaper(
        id: 2,
        title: 'Paper Without Keywords',
        link: 'https://example.com/paper2',
        abstract: 'Test abstract',
        introduction: 'Test introduction',
        materialsMethods: 'Test methods',
        results: 'Test results',
        discussion: 'Test discussion',
        simplifiedAiVersion: 'Test AI summary',
        keywords: [],
      );

      await tester.pumpWidget(
        MaterialApp(home: PaperDetailPage(paper: paperWithoutKeywords)),
      );

      // Act
      await tester.pump();

      // Assert
      expect(find.text('Paper Without Keywords'), findsOneWidget);
      expect(find.text('Keywords'), findsNothing);
    });

    testWidgets('should handle paper with minimal data', (
      WidgetTester tester,
    ) async {
      // Arrange
      final minimalPaper = ResearchPaper(
        title: 'Minimal Paper',
        link: 'https://example.com/minimal',
        abstract: 'Minimal abstract',
        introduction: '',
        materialsMethods: '',
        results: '',
        discussion: '',
        simplifiedAiVersion: 'Minimal AI summary',
      );

      await tester.pumpWidget(
        MaterialApp(home: PaperDetailPage(paper: minimalPaper)),
      );

      // Act
      await tester.pump();

      // Assert
      expect(find.text('Minimal Paper'), findsOneWidget);
      expect(find.text('Minimal AI summary'), findsOneWidget);
    });
  });
}
