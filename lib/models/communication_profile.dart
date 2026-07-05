class CommunicationProfile {
  final String greeting;
  final String closing;
  final List<String> favoriteWords;
  final List<String> favoriteEmojis;
  final String sentenceStyle;

  CommunicationProfile({
    required this.greeting,
    required this.closing,
    required this.favoriteWords,
    required this.favoriteEmojis,
    required this.sentenceStyle,
  });

  Map<String, dynamic> toJson() {
    return {
      'greeting': greeting,
      'closing': closing,
      'favoriteWords': favoriteWords,
      'favoriteEmojis': favoriteEmojis,
      'sentenceStyle': sentenceStyle,
    };
  }

  factory CommunicationProfile.fromJson(Map<String, dynamic> json) {
    return CommunicationProfile(
      greeting: json['greeting'] ?? 'Not learned yet',
      closing: json['closing'] ?? 'Not learned yet',
      favoriteWords: List<String>.from(json['favoriteWords'] ?? []),
      favoriteEmojis: List<String>.from(json['favoriteEmojis'] ?? []),
      sentenceStyle: json['sentenceStyle'] ?? 'Not learned yet',
    );
  }
}