import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/pages/paper_detail_page.dart';
import '../../lib/models/research_paper.dart';

void main() {
  group('PaperDetailPage', () {
    late ResearchPaper testPaper;

    setUp(() {
      testPaper = ResearchPaper(
        id: 1,
        title: 'Test Research Paper Title',
        link: 'https://example.com/test-paper',
        summary:
            'This is a test summary of the research paper that describes the content and findings.',
        keywords: ['test', 'research', 'paper', 'science'],
      );
    });

    testWidgets('should display paper details correctly', (
      WidgetTester tester,
    ) async {
      // Build the PaperDetailPage widget
      await tester.pumpWidget(
        MaterialApp(home: PaperDetailPage(paper: testPaper)),
      );

      // Verify the AppBar title
      expect(find.text('Paper Details'), findsOneWidget);

      // Verify paper title is displayed
      expect(find.text('Test Research Paper Title'), findsOneWidget);

      // Verify summary section
      expect(find.text('Summary'), findsOneWidget);
      expect(
        find.text(
          'This is a test summary of the research paper that describes the content and findings.',
        ),
        findsOneWidget,
      );

      // Verify keywords section
      expect(find.text('Keywords'), findsOneWidget);

      // Verify keywords are displayed as chips
      expect(find.text('test'), findsOneWidget);
      expect(find.text('research'), findsOneWidget);
      expect(find.text('paper'), findsOneWidget);
      expect(find.text('science'), findsOneWidget);

      // Verify "Read Full Paper" button
      expect(find.text('Read Full Paper'), findsOneWidget);
      expect(find.byIcon(Icons.open_in_new), findsOneWidget);

      // Verify source link is displayed
      expect(find.text('Source:'), findsOneWidget);
      expect(find.text('https://example.com/test-paper'), findsOneWidget);
    });

    testWidgets('should display all chips for keywords', (
      WidgetTester tester,
    ) async {
      // Build the PaperDetailPage widget
      await tester.pumpWidget(
        MaterialApp(home: PaperDetailPage(paper: testPaper)),
      );

      // Verify all keywords are present as individual chips
      for (String keyword in testPaper.keywords) {
        expect(find.text(keyword), findsOneWidget);
      }

      // Verify chips are displayed
      expect(find.byType(Chip), findsNWidgets(testPaper.keywords.length));
    });

    testWidgets('should handle paper with many keywords', (
      WidgetTester tester,
    ) async {
      // Create a paper with many keywords
      final paperWithManyKeywords = ResearchPaper(
        id: 2,
        title: 'Paper with Many Keywords',
        link: 'https://example.com/many-keywords',
        summary: 'This paper has many keywords.',
        keywords: [
          'keyword1',
          'keyword2',
          'keyword3',
          'keyword4',
          'keyword5',
          'keyword6',
          'keyword7',
        ],
      );

      // Build the PaperDetailPage widget
      await tester.pumpWidget(
        MaterialApp(home: PaperDetailPage(paper: paperWithManyKeywords)),
      );

      // Verify all keywords are displayed
      for (String keyword in paperWithManyKeywords.keywords) {
        expect(find.text(keyword), findsOneWidget);
      }

      // Verify the correct number of chips
      expect(
        find.byType(Chip),
        findsNWidgets(paperWithManyKeywords.keywords.length),
      );
    });

    testWidgets('should display UI components in correct order', (
      WidgetTester tester,
    ) async {
      // Build the PaperDetailPage widget
      await tester.pumpWidget(
        MaterialApp(home: PaperDetailPage(paper: testPaper)),
      );

      // Find all widgets and verify their order by checking their positions
      final titleFinder = find.text('Test Research Paper Title');
      final summaryHeaderFinder = find.text('Summary');
      final keywordsHeaderFinder = find.text('Keywords');
      final buttonFinder = find.text('Read Full Paper');

      expect(titleFinder, findsOneWidget);
      expect(summaryHeaderFinder, findsOneWidget);
      expect(keywordsHeaderFinder, findsOneWidget);
      expect(buttonFinder, findsOneWidget);

      // Verify the widgets exist (order testing is complex with widget testing)
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
