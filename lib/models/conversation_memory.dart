class ConversationMemory {
  final String contactName;
  final String displayName;
  final String writingStyle;
  final List<String> favoriteWords;
  final String preferredTone;
  final String relationshipType;

  final String preferredPlatform;
  final String preferredReplyLength;
  final int messagesLearned;
  final int aiConfidence;


  final DateTime lastUpdated;

  ConversationMemory({
    required this.contactName,
    required this.displayName,
    required this.writingStyle,
    required this.favoriteWords,
    required this.preferredTone,
    required this.relationshipType,
    required this.preferredPlatform,
    required this.preferredReplyLength,
    required this.messagesLearned,
    required this.aiConfidence,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'contactName': contactName,
      'displayName': displayName,
      'writingStyle': writingStyle,
      'favoriteWords': favoriteWords,
      'preferredTone': preferredTone,
      'relationshipType': relationshipType,
      'preferredPlatform': preferredPlatform,
      'preferredReplyLength': preferredReplyLength,
      'messagesLearned': messagesLearned,
      'aiConfidence': aiConfidence,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory ConversationMemory.fromJson(Map<String, dynamic> json) {
    return ConversationMemory(
      contactName: json['contactName'],
      displayName: json['displayName'] ?? json['contactName'],
      writingStyle: json['writingStyle'],
      favoriteWords: List<String>.from(json['favoriteWords']),
      preferredTone: json['preferredTone'],
      relationshipType: json['relationshipType'] ?? 'General',
      preferredPlatform: json['preferredPlatform'] ?? 'WhatsApp',

      preferredReplyLength: json['preferredReplyLength'] ?? 'Medium',

      messagesLearned: json['messagesLearned'] ?? 0,
      aiConfidence: json['aiConfidence'] ?? 0,    
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}