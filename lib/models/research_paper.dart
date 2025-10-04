class ResearchPaper {
  final int id;
  final String title;
  final String link;
  final String summary;
  final List<String> keywords;

  ResearchPaper({
    required this.id,
    required this.title,
    required this.link,
    required this.summary,
    required this.keywords,
  });

  // Factory constructor to create ResearchPaper from JSON
  factory ResearchPaper.fromJson(Map<String, dynamic> json) {
    return ResearchPaper(
      id: json['id'] as int,
      title: json['title'] as String,
      link: json['link'] as String,
      summary: json['summary'] as String,
      keywords: List<String>.from(json['keywords'] as List),
    );
  }

  // Method to convert ResearchPaper to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'link': link,
      'summary': summary,
      'keywords': keywords,
    };
  }

  // Optional: Override toString for better debugging
  @override
  String toString() {
    return 'ResearchPaper(id: $id, title: $title, link: $link, summary: $summary, keywords: $keywords)';
  }

  // Optional: Override equality operator and hashCode
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ResearchPaper) return false;

    if (keywords.length != other.keywords.length) return false;
    for (int i = 0; i < keywords.length; i++) {
      if (keywords[i] != other.keywords[i]) return false;
    }

    return id == other.id &&
        title == other.title &&
        link == other.link &&
        summary == other.summary;
  }

  @override
  int get hashCode {
    int keywordsHash = 0;
    for (String keyword in keywords) {
      keywordsHash ^= keyword.hashCode;
    }

    return id.hashCode ^
        title.hashCode ^
        link.hashCode ^
        summary.hashCode ^
        keywordsHash;
  }
}
