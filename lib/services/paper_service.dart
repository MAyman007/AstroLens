import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/research_paper.dart';

class PaperService {
  /// Loads research papers from the assets/papers.json file
  /// Returns a List<ResearchPaper> parsed from the JSON data
  static Future<List<ResearchPaper>> loadPapers() async {
    try {
      // Load the JSON string from assets
      final String jsonString = await rootBundle.loadString(
        'assets/papers.json',
      );

      // Decode the JSON string into a dynamic object
      final dynamic jsonData = jsonDecode(jsonString);

      // Ensure the JSON data is a List
      if (jsonData is! List) {
        throw Exception('Expected JSON to contain a list of papers');
      }

      // Convert each JSON object to a ResearchPaper instance
      final List<ResearchPaper> papers = jsonData
          .map(
            (jsonPaper) =>
                ResearchPaper.fromJson(jsonPaper as Map<String, dynamic>),
          )
          .toList();

      return papers;
    } catch (e) {
      throw Exception('Failed to load papers: $e');
    }
  }

  /// Alternative static function if you prefer not to use a class
  /// This function can be called directly without instantiating the class
  static Future<List<ResearchPaper>> getPapersFromAssets() async {
    return await loadPapers();
  }
}

/// Standalone function for loading papers (alternative approach)
/// This can be used if you prefer a simple function over a class method
Future<List<ResearchPaper>> loadPapers() async {
  try {
    // Load the JSON string from assets
    final String jsonString = await rootBundle.loadString('assets/papers.json');

    // Decode the JSON string into a dynamic object
    final dynamic jsonData = jsonDecode(jsonString);

    // Ensure the JSON data is a List
    if (jsonData is! List) {
      throw Exception('Expected JSON to contain a list of papers');
    }

    // Convert each JSON object to a ResearchPaper instance
    final List<ResearchPaper> papers = jsonData
        .map(
          (jsonPaper) =>
              ResearchPaper.fromJson(jsonPaper as Map<String, dynamic>),
        )
        .toList();

    return papers;
  } catch (e) {
    throw Exception('Failed to load papers: $e');
  }
}
