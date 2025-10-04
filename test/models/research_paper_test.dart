import 'package:flutter_test/flutter_test.dart';
import 'package:astrolens/models/research_paper.dart';

void main() {
  group('ResearchPaper', () {
    test('should create ResearchPaper from API JSON', () {
      // Arrange
      final json = {
        'title': 'Dark Matter Detection in Galaxy Clusters',
        'link': 'https://example.com/paper1',
        'abstract':
            'This paper discusses novel methods for detecting dark matter...',
        'introduction':
            'Dark matter remains one of the most significant challenges...',
        'materials_methods': 'We used X-ray observations from Chandra...',
        'results':
            'Our analysis revealed significant dark matter concentrations...',
        'discussion':
            'These findings support the current dark matter models...',
        'simplified_ai_version':
            'Scientists studied dark matter in space using special telescopes...',
      };

      // Act
      final paper = ResearchPaper.fromApiJson(json);

      // Assert
      expect(paper.title, equals('Dark Matter Detection in Galaxy Clusters'));
      expect(paper.link, equals('https://example.com/paper1'));
      expect(
        paper.abstract,
        equals(
          'This paper discusses novel methods for detecting dark matter...',
        ),
      );
      expect(
        paper.introduction,
        equals('Dark matter remains one of the most significant challenges...'),
      );
      expect(
        paper.materialsMethods,
        equals('We used X-ray observations from Chandra...'),
      );
      expect(
        paper.results,
        equals(
          'Our analysis revealed significant dark matter concentrations...',
        ),
      );
      expect(
        paper.discussion,
        equals('These findings support the current dark matter models...'),
      );
      expect(
        paper.simplifiedAiVersion,
        equals(
          'Scientists studied dark matter in space using special telescopes...',
        ),
      );
    });

    test('should create ResearchPaper from legacy JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'title': 'Exoplanet Atmospheric Composition',
        'link': 'https://example.com/paper2',
        'summary':
            'Analysis of atmospheric composition in distant exoplanets...',
        'keywords': ['exoplanets', 'atmosphere', 'spectroscopy'],
      };

      // Act
      final paper = ResearchPaper.fromJson(json);

      // Assert
      expect(paper.id, equals(1));
      expect(paper.title, equals('Exoplanet Atmospheric Composition'));
      expect(paper.link, equals('https://example.com/paper2'));
      expect(
        paper.abstract,
        equals('Analysis of atmospheric composition in distant exoplanets...'),
      );
      expect(
        paper.summary,
        equals('Analysis of atmospheric composition in distant exoplanets...'),
      );
      expect(
        paper.keywords,
        equals(['exoplanets', 'atmosphere', 'spectroscopy']),
      );
    });

    test('should convert ResearchPaper to JSON', () {
      // Arrange
      final paper = ResearchPaper(
        id: 2,
        title: 'Black Hole Event Horizons',
        link: 'https://example.com/paper3',
        abstract: 'Study of event horizon dynamics...',
        introduction: 'Black holes are among the most fascinating...',
        materialsMethods: 'We analyzed data from Event Horizon Telescope...',
        results: 'The observations confirmed theoretical predictions...',
        discussion:
            'Our findings provide new insights into black hole physics...',
        simplifiedAiVersion:
            'Scientists took pictures of black holes using special telescopes...',
        keywords: ['black holes', 'event horizon', 'general relativity'],
      );

      // Act
      final json = paper.toJson();

      // Assert
      expect(json['id'], equals(2));
      expect(json['title'], equals('Black Hole Event Horizons'));
      expect(json['link'], equals('https://example.com/paper3'));
      expect(json['abstract'], equals('Study of event horizon dynamics...'));
      expect(
        json['introduction'],
        equals('Black holes are among the most fascinating...'),
      );
      expect(
        json['materials_methods'],
        equals('We analyzed data from Event Horizon Telescope...'),
      );
      expect(
        json['results'],
        equals('The observations confirmed theoretical predictions...'),
      );
      expect(
        json['discussion'],
        equals('Our findings provide new insights into black hole physics...'),
      );
      expect(
        json['simplified_ai_version'],
        equals(
          'Scientists took pictures of black holes using special telescopes...',
        ),
      );
      expect(
        json['keywords'],
        equals(['black holes', 'event horizon', 'general relativity']),
      );
    });

    test('should handle round-trip JSON conversion', () {
      // Arrange
      final originalPaper = ResearchPaper(
        title: 'Gravitational Waves Detection',
        link: 'https://example.com/paper4',
        abstract:
            'Detection of gravitational waves from neutron star mergers...',
        introduction: 'Gravitational waves provide a new window...',
        materialsMethods: 'LIGO interferometers were used to detect...',
        results: 'We detected multiple gravitational wave events...',
        discussion: 'These detections confirm Einstein\'s predictions...',
        simplifiedAiVersion:
            'Scientists heard space ripples from crashing stars...',
      );

      // Act
      final json = originalPaper.toJson();
      final recreatedPaper = ResearchPaper.fromApiJson(json);

      // Assert
      expect(recreatedPaper.title, equals(originalPaper.title));
      expect(recreatedPaper.link, equals(originalPaper.link));
      expect(recreatedPaper.abstract, equals(originalPaper.abstract));
      expect(recreatedPaper.introduction, equals(originalPaper.introduction));
      expect(
        recreatedPaper.materialsMethods,
        equals(originalPaper.materialsMethods),
      );
      expect(recreatedPaper.results, equals(originalPaper.results));
      expect(recreatedPaper.discussion, equals(originalPaper.discussion));
      expect(
        recreatedPaper.simplifiedAiVersion,
        equals(originalPaper.simplifiedAiVersion),
      );
    });

    test('should handle equality comparison', () {
      // Arrange
      final paper1 = ResearchPaper(
        title: 'Test Paper',
        link: 'https://example.com',
        abstract: 'Test abstract',
        introduction: 'Test introduction',
        materialsMethods: 'Test methods',
        results: 'Test results',
        discussion: 'Test discussion',
        simplifiedAiVersion: 'Test AI summary',
      );

      final paper2 = ResearchPaper(
        title: 'Test Paper',
        link: 'https://example.com',
        abstract: 'Test abstract',
        introduction: 'Test introduction',
        materialsMethods: 'Test methods',
        results: 'Test results',
        discussion: 'Test discussion',
        simplifiedAiVersion: 'Test AI summary',
      );

      final paper3 = ResearchPaper(
        title: 'Different Paper',
        link: 'https://example.com',
        abstract: 'Test abstract',
        introduction: 'Test introduction',
        materialsMethods: 'Test methods',
        results: 'Test results',
        discussion: 'Test discussion',
        simplifiedAiVersion: 'Test AI summary',
      );

      // Assert
      expect(paper1, equals(paper2));
      expect(paper1, isNot(equals(paper3)));
    });

    test('should generate consistent hash codes', () {
      // Arrange
      final paper1 = ResearchPaper(
        title: 'Test Paper',
        link: 'https://example.com',
        abstract: 'Test abstract',
        introduction: 'Test introduction',
        materialsMethods: 'Test methods',
        results: 'Test results',
        discussion: 'Test discussion',
        simplifiedAiVersion: 'Test AI summary',
      );

      final paper2 = ResearchPaper(
        title: 'Test Paper',
        link: 'https://example.com',
        abstract: 'Test abstract',
        introduction: 'Test introduction',
        materialsMethods: 'Test methods',
        results: 'Test results',
        discussion: 'Test discussion',
        simplifiedAiVersion: 'Test AI summary',
      );

      // Assert
      expect(paper1.hashCode, equals(paper2.hashCode));
    });

    test('should build full article correctly', () {
      // Arrange
      final paper = ResearchPaper(
        title: 'Test Paper',
        link: 'https://example.com',
        abstract: 'Test abstract content',
        introduction: 'Test introduction content',
        materialsMethods: 'Test methods content',
        results: 'Test results content',
        discussion: 'Test discussion content',
        simplifiedAiVersion: 'Test AI summary',
      );

      // Act
      final fullArticle = paper.fullArticle;

      // Assert
      expect(fullArticle, contains('Abstract:\nTest abstract content'));
      expect(fullArticle, contains('Introduction:\nTest introduction content'));
      expect(
        fullArticle,
        contains('Materials and Methods:\nTest methods content'),
      );
      expect(fullArticle, contains('Results:\nTest results content'));
      expect(fullArticle, contains('Discussion:\nTest discussion content'));
    });

    test('should handle empty sections in full article', () {
      // Arrange
      final paper = ResearchPaper(
        title: 'Test Paper',
        link: 'https://example.com',
        abstract: 'Test abstract content',
        introduction: '',
        materialsMethods: '',
        results: 'Test results content',
        discussion: '',
        simplifiedAiVersion: 'Test AI summary',
      );

      // Act
      final fullArticle = paper.fullArticle;

      // Assert
      expect(fullArticle, contains('Abstract:\nTest abstract content'));
      expect(fullArticle, contains('Results:\nTest results content'));
      expect(fullArticle, isNot(contains('Introduction:')));
      expect(fullArticle, isNot(contains('Materials and Methods:')));
      expect(fullArticle, isNot(contains('Discussion:')));
    });
  });
}
