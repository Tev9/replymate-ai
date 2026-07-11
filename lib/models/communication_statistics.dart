class CommunicationStatistics {
  final Map<String, int> greetings;
  final Map<String, int> closings;
  final Map<String, int> favoriteWords;
  final Map<String, int> favoriteEmojis;
  final Map<String, int> sentenceStyles;

  CommunicationStatistics({
    required this.greetings,
    required this.closings,
    required this.favoriteWords,
    required this.favoriteEmojis,
    required this.sentenceStyles,
  });

  Map<String, dynamic> toJson() {
    return {
      'greetings': greetings,
      'closings': closings,
      'favoriteWords': favoriteWords,
      'favoriteEmojis': favoriteEmojis,
      'sentenceStyles': sentenceStyles,
    };
  }

  factory CommunicationStatistics.fromJson(
      Map<String, dynamic> json) {
    return CommunicationStatistics(
      greetings:
          Map<String, int>.from(json['greetings'] ?? {}),
      closings:
          Map<String, int>.from(json['closings'] ?? {}),
      favoriteWords:
          Map<String, int>.from(json['favoriteWords'] ?? {}),
      favoriteEmojis:
          Map<String, int>.from(json['favoriteEmojis'] ?? {}),
      sentenceStyles:
          Map<String, int>.from(json['sentenceStyles'] ?? {}),
    );
  }
}