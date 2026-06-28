class ConversationMemory {
  final String contactName;
  final String writingStyle;
  final List<String> favoriteWords;
  final String preferredTone;
  final String relationshipType;
  final DateTime lastUpdated;

  ConversationMemory({
    required this.contactName,
    required this.writingStyle,
    required this.favoriteWords,
    required this.preferredTone,
    required this.relationshipType,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'contactName': contactName,
      'writingStyle': writingStyle,
      'favoriteWords': favoriteWords,
      'preferredTone': preferredTone,
      'relationshipType': relationshipType,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory ConversationMemory.fromJson(Map<String, dynamic> json) {
    return ConversationMemory(
      contactName: json['contactName'],
      writingStyle: json['writingStyle'],
      favoriteWords: List<String>.from(json['favoriteWords']),
      preferredTone: json['preferredTone'],
      relationshipType: json['relationshipType'] ?? 'General',
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}