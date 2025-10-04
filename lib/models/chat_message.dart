class ChatMessage {
  final String sender; // "user" or "bot"
  final String text;
  final String? link;
  final DateTime timestamp;

  ChatMessage({
    required this.sender,
    required this.text,
    this.link,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isUser => sender == "user";
  bool get isBot => sender == "bot";
}
