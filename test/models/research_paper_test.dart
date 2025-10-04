import 'package:flutter_test/flutter_test.dart';
import '../../lib/models/research_paper.dart';

void main() {
  group('ResearchPaper', () {
    test('should create ResearchPaper from JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'title': 'Dark Matter Detection in Galaxy Clusters',
        'link': 'https://example.com/paper1',
        'summary':
            'This paper discusses novel methods for detecting dark matter...',
        'keywords': ['dark matter', 'galaxy clusters', 'astrophysics'],
      };

      // Act
      final paper = ResearchPaper.fromJson(json);

      // Assert
      expect(paper.id, equals(1));
      expect(paper.title, equals('Dark Matter Detection in Galaxy Clusters'));
      expect(paper.link, equals('https://example.com/paper1'));
      expect(
        paper.summary,
        equals(
          'This paper discusses novel methods for detecting dark matter...',
        ),
      );
      expect(
        paper.keywords,
        equals(['dark matter', 'galaxy clusters', 'astrophysics']),
      );
    });

    test('should convert ResearchPaper to JSON', () {
      // Arrange
      final paper = ResearchPaper(
        id: 2,
        title: 'Exoplanet Atmospheric Composition',
        link: 'https://example.com/paper2',
        summary: 'Analysis of atmospheric composition in distant exoplanets...',
        keywords: ['exoplanets', 'atmosphere', 'spectroscopy'],
      );

      // Act
      final json = paper.toJson();

      // Assert
      expect(json['id'], equals(2));
      expect(json['title'], equals('Exoplanet Atmospheric Composition'));
      expect(json['link'], equals('https://example.com/paper2'));
      expect(
        json['summary'],
        equals('Analysis of atmospheric composition in distant exoplanets...'),
      );
      expect(
        json['keywords'],
        equals(['exoplanets', 'atmosphere', 'spectroscopy']),
      );
    });

    test('should handle round-trip JSON conversion', () {
      // Arrange
      final originalPaper = ResearchPaper(
        id: 3,
        title: 'Black Hole Event Horizons',
        link: 'https://example.com/paper3',
        summary:
            'Study of event horizon dynamics in supermassive black holes...',
        keywords: ['black holes', 'event horizon', 'general relativity'],
      );

      // Act
      final json = originalPaper.toJson();
      final recreatedPaper = ResearchPaper.fromJson(json);

      // Assert
      expect(recreatedPaper.id, equals(originalPaper.id));
      expect(recreatedPaper.title, equals(originalPaper.title));
      expect(recreatedPaper.link, equals(originalPaper.link));
      expect(recreatedPaper.summary, equals(originalPaper.summary));
      expect(recreatedPaper.keywords, equals(originalPaper.keywords));
    });

    test('should handle equality comparison', () {
      // Arrange
      final paper1 = ResearchPaper(
        id: 1,
        title: 'Test Paper',
        link: 'https://example.com',
        summary: 'Test summary',
        keywords: ['test', 'paper'],
      );

      final paper2 = ResearchPaper(
        id: 1,
        title: 'Test Paper',
        link: 'https://example.com',
        summary: 'Test summary',
        keywords: ['test', 'paper'],
      );

      final paper3 = ResearchPaper(
        id: 2,
        title: 'Different Paper',
        link: 'https://example.com',
        summary: 'Test summary',
        keywords: ['test', 'paper'],
      );

      // Assert
      expect(paper1, equals(paper2));
      expect(paper1, isNot(equals(paper3)));
    });

    test('should generate consistent hash codes', () {
      // Arrange
      final paper1 = ResearchPaper(
        id: 1,
        title: 'Test Paper',
        link: 'https://example.com',
        summary: 'Test summary',
        keywords: ['test', 'paper'],
      );

      final paper2 = ResearchPaper(
        id: 1,
        title: 'Test Paper',
        link: 'https://example.com',
        summary: 'Test summary',
        keywords: ['test', 'paper'],
      );

      // Assert
      expect(paper1.hashCode, equals(paper2.hashCode));
    });
  });
}
