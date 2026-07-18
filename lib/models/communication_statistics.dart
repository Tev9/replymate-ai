class CommunicationStatistics {
  final Map<String, int> greetings;
  final Map<String, int> closings;
  final Map<String, int> favoriteWords;
  final Map<String, int> favoriteEmojis;
  final Map<String, int> sentenceStyles;

  final int totalMessages;
  final int totalWords;
  final int messagesWithEmojis;
  final int questionMessages;
  final int exclamationMessages;

  CommunicationStatistics({
    required this.greetings,
    required this.closings,
    required this.favoriteWords,
    required this.favoriteEmojis,
    required this.sentenceStyles,
    this.totalMessages = 0,
    this.totalWords = 0,
    this.messagesWithEmojis = 0,
    this.questionMessages = 0,
    this.exclamationMessages = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'greetings': greetings,
      'closings': closings,
      'favoriteWords': favoriteWords,
      'favoriteEmojis': favoriteEmojis,
      'sentenceStyles': sentenceStyles,
      'totalMessages': totalMessages,
      'totalWords': totalWords,
      'messagesWithEmojis': messagesWithEmojis,
      'questionMessages': questionMessages,
      'exclamationMessages': exclamationMessages,
    };
  }

  factory CommunicationStatistics.fromJson(
    Map<String, dynamic> json,
  ) {
    return CommunicationStatistics(
      greetings: Map<String, int>.from(
        json['greetings'] ?? {},
      ),
      closings: Map<String, int>.from(
        json['closings'] ?? {},
      ),
      favoriteWords: Map<String, int>.from(
        json['favoriteWords'] ?? {},
      ),
      favoriteEmojis: Map<String, int>.from(
        json['favoriteEmojis'] ?? {},
      ),
      sentenceStyles: Map<String, int>.from(
        json['sentenceStyles'] ?? {},
      ),
      totalMessages:
          (json['totalMessages'] as num?)?.toInt() ?? 0,
      totalWords:
          (json['totalWords'] as num?)?.toInt() ?? 0,
      messagesWithEmojis:
          (json['messagesWithEmojis'] as num?)?.toInt() ?? 0,
      questionMessages:
          (json['questionMessages'] as num?)?.toInt() ?? 0,
      exclamationMessages:
          (json['exclamationMessages'] as num?)?.toInt() ?? 0,
    );
  }
}