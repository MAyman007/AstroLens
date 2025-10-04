class ResearchPaper {
  final int? id; // Make id optional for API responses
  final String title;
  final String link;
  final String abstract;
  final String introduction;
  final String materialsMethods;
  final String results;
  final String discussion;
  final String simplifiedAiVersion;
  final List<String> keywords; // Keep for backward compatibility

  ResearchPaper({
    this.id,
    required this.title,
    required this.link,
    required this.abstract,
    required this.introduction,
    required this.materialsMethods,
    required this.results,
    required this.discussion,
    required this.simplifiedAiVersion,
    this.keywords = const [],
  });

  // Factory constructor to create ResearchPaper from API JSON response
  factory ResearchPaper.fromApiJson(Map<String, dynamic> json) {
    return ResearchPaper(
      title: json['title'] as String? ?? '',
      link: json['link'] as String? ?? '',
      abstract: json['abstract'] as String? ?? '',
      introduction: json['introduction'] as String? ?? '',
      materialsMethods: json['materials_methods'] as String? ?? '',
      results: json['results'] as String? ?? '',
      discussion: json['discussion'] as String? ?? '',
      simplifiedAiVersion: json['simplified_ai_version'] as String? ?? '',
    );
  }

  // Factory constructor to create ResearchPaper from legacy JSON (with id)
  factory ResearchPaper.fromJson(Map<String, dynamic> json) {
    return ResearchPaper(
      id: json['id'] as int?,
      title: json['title'] as String? ?? '',
      link: json['link'] as String? ?? '',
      abstract:
          json['summary'] as String? ??
          '', // Map summary to abstract for backward compatibility
      introduction: '',
      materialsMethods: '',
      results: '',
      discussion: '',
      simplifiedAiVersion: json['summary'] as String? ?? '',
      keywords: json['keywords'] != null
          ? List<String>.from(json['keywords'] as List)
          : [],
    );
  }

  // Get summary for backward compatibility
  String get summary => simplifiedAiVersion;

  // Get full article text combining all sections
  String get fullArticle {
    final sections = <String>[];

    if (abstract.isNotEmpty) {
      sections.add('Abstract:\n$abstract');
    }
    if (introduction.isNotEmpty) {
      sections.add('Introduction:\n$introduction');
    }
    if (materialsMethods.isNotEmpty) {
      sections.add('Materials and Methods:\n$materialsMethods');
    }
    if (results.isNotEmpty) {
      sections.add('Results:\n$results');
    }
    if (discussion.isNotEmpty) {
      sections.add('Discussion:\n$discussion');
    }

    return sections.join('\n\n');
  }

  // Method to convert ResearchPaper to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'link': link,
      'abstract': abstract,
      'introduction': introduction,
      'materials_methods': materialsMethods,
      'results': results,
      'discussion': discussion,
      'simplified_ai_version': simplifiedAiVersion,
      'keywords': keywords,
    };
  }

  // Optional: Override toString for better debugging
  @override
  String toString() {
    return 'ResearchPaper(id: $id, title: $title, link: $link, abstract: ${abstract.length} chars, simplifiedAiVersion: ${simplifiedAiVersion.length} chars)';
  }

  // Optional: Override equality operator and hashCode
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ResearchPaper) return false;

    return id == other.id &&
        title == other.title &&
        link == other.link &&
        abstract == other.abstract &&
        introduction == other.introduction &&
        materialsMethods == other.materialsMethods &&
        results == other.results &&
        discussion == other.discussion &&
        simplifiedAiVersion == other.simplifiedAiVersion;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        link.hashCode ^
        abstract.hashCode ^
        introduction.hashCode ^
        materialsMethods.hashCode ^
        results.hashCode ^
        discussion.hashCode ^
        simplifiedAiVersion.hashCode;
  }
}
