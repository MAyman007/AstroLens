import 'package:flutter_test/flutter_test.dart';
import 'package:astrolens/services/paper_service.dart';
import 'package:astrolens/models/research_paper.dart';

void main() {
  group('PaperService', () {
    testWidgets('should load papers from assets/papers.json', (
      WidgetTester tester,
    ) async {
      // Act
      final List<ResearchPaper> papers = await PaperService.loadPapers();

      // Assert
      expect(papers, isNotEmpty);
      expect(
        papers.length,
        equals(5),
      ); // Based on the current papers.json content

      // Check first paper
      final firstPaper = papers.first;
      expect(firstPaper.id, equals(1));
      expect(
        firstPaper.title,
        equals('Mice in Bion-M 1 space mission: training and selection'),
      );
      expect(
        firstPaper.link,
        equals('https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4136787/'),
      );
      expect(firstPaper.summary, contains('Mice were carefully trained'));
      expect(firstPaper.keywords, contains('mice'));
      expect(firstPaper.keywords, contains('space mission'));

      // Check that all papers have valid data
      for (final paper in papers) {
        expect(paper.id, isPositive);
        expect(paper.title, isNotEmpty);
        expect(paper.link, isNotEmpty);
        expect(paper.summary, isNotEmpty);
        expect(paper.keywords, isNotEmpty);
      }
    });

    testWidgets(
      'should load papers using alternative getPapersFromAssets method',
      (WidgetTester tester) async {
        // Act
        final List<ResearchPaper> papers =
            await PaperService.getPapersFromAssets();

        // Assert
        expect(papers, isNotEmpty);
        expect(papers.length, equals(5));
      },
    );

    testWidgets('should load papers using standalone loadPapers function', (
      WidgetTester tester,
    ) async {
      // Act
      final List<ResearchPaper> papers = await loadPapers();

      // Assert
      expect(papers, isNotEmpty);
      expect(papers.length, equals(5));

      // Verify specific paper content
      final microgravityPaper = papers.firstWhere(
        (paper) =>
            paper.title.contains('Microgravity induces pelvic bone loss'),
      );
      expect(microgravityPaper.id, equals(2));
      expect(microgravityPaper.keywords, contains('microgravity'));
      expect(microgravityPaper.keywords, contains('bone loss'));
    });

    testWidgets('should handle all papers correctly', (
      WidgetTester tester,
    ) async {
      // Act
      final List<ResearchPaper> papers = await PaperService.loadPapers();

      // Assert - Check all expected papers are loaded
      final expectedTitles = [
        'Mice in Bion-M 1 space mission: training and selection',
        'Microgravity induces pelvic bone loss through osteoclastic activity, osteocytic osteolysis, and osteoblastic cell cycle inhibition by CDKN1a/p21',
        'Stem Cell Health and Tissue Regeneration in Microgravity',
        'Microgravity Reduces the Differentiation and Regenerative Potential of Embryonic Stem Cells',
        'Microgravity validation of a novel system for RNA isolation and multiplex quantitative real time PCR analysis of gene expression on the International Space Station',
      ];

      expect(papers.length, equals(expectedTitles.length));

      for (final expectedTitle in expectedTitles) {
        expect(
          papers.any((paper) => paper.title == expectedTitle),
          isTrue,
          reason: 'Expected to find paper with title: $expectedTitle',
        );
      }

      // Verify all papers have unique IDs
      final ids = papers.map((paper) => paper.id).toSet();
      expect(
        ids.length,
        equals(papers.length),
        reason: 'All papers should have unique IDs',
      );

      // Verify all papers have HTTPS links
      for (final paper in papers) {
        expect(
          paper.link,
          startsWith('https://'),
          reason: 'All links should be HTTPS',
        );
      }
    });
  });
}
