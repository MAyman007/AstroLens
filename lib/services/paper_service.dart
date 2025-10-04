import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
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

  /// Fetches paper data from the API with detailed sections
  /// Returns a ResearchPaper with abstract, introduction, materials_methods, results, discussion, and simplified_ai_version
  static Future<ResearchPaper> fetchPaperFromApi(String paperUrl) async {
    try {
      // Construct the API URL with proper query parameter (use HTTP as requested)
      final apiUrl = Uri.parse(
        'https://astrolens.mohamedayman.org/summarize-get',
      ).replace(queryParameters: {'url': paperUrl});

      print('DEBUG: Calling API with URL: $apiUrl');

      // Make the HTTP request with headers and extended timeout
      final client = http.Client();
      try {
        final response = await client
            .get(
              apiUrl,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'User-Agent': 'AstroLens-Flutter/1.0',
              },
            )
            .timeout(
              const Duration(
                seconds: 60,
              ), // Allow up to 60 seconds for API response
            );

        print('DEBUG: API Response Status: ${response.statusCode}');
        print('DEBUG: API Response Body: ${response.body}');

        if (response.statusCode == 200) {
          // Parse the JSON response
          final Map<String, dynamic> jsonData = jsonDecode(response.body);

          // Create ResearchPaper from API response
          return ResearchPaper.fromApiJson(jsonData);
        } else {
          throw Exception(
            'Failed to fetch paper data: ${response.statusCode} - ${response.body}',
          );
        }
      } finally {
        client.close();
      }
    } catch (e) {
      print('DEBUG: Error in fetchPaperFromApi: $e');
      throw Exception('Error fetching paper from API: $e');
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
