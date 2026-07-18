class CommunicationProfile {
  final String greeting;
  final String closing;
  final List<String> favoriteWords;
  final List<String> favoriteEmojis;
  final String sentenceStyle;

  final int averageWordsPerMessage;
  final double emojiUsageRate;
  final double questionRate;
  final double exclamationRate;

  CommunicationProfile({
    required this.greeting,
    required this.closing,
    required this.favoriteWords,
    required this.favoriteEmojis,
    required this.sentenceStyle,
    this.averageWordsPerMessage = 0,
    this.emojiUsageRate = 0,
    this.questionRate = 0,
    this.exclamationRate = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'greeting': greeting,
      'closing': closing,
      'favoriteWords': favoriteWords,
      'favoriteEmojis': favoriteEmojis,
      'sentenceStyle': sentenceStyle,
      'averageWordsPerMessage': averageWordsPerMessage,
      'emojiUsageRate': emojiUsageRate,
      'questionRate': questionRate,
      'exclamationRate': exclamationRate,
    };
  }

  factory CommunicationProfile.fromJson(Map<String, dynamic> json) {
    return CommunicationProfile(
      greeting: json['greeting'] ?? 'Not learned yet',
      closing: json['closing'] ?? 'Not learned yet',
      favoriteWords: List<String>.from(json['favoriteWords'] ?? []),
      favoriteEmojis: List<String>.from(json['favoriteEmojis'] ?? []),
      sentenceStyle: json['sentenceStyle'] ?? 'Not learned yet',
      averageWordsPerMessage:
          (json['averageWordsPerMessage'] as num?)?.toInt() ?? 0,
      emojiUsageRate:
          (json['emojiUsageRate'] as num?)?.toDouble() ?? 0,
      questionRate:
          (json['questionRate'] as num?)?.toDouble() ?? 0,
      exclamationRate:
          (json['exclamationRate'] as num?)?.toDouble() ?? 0,
    );
  }
}