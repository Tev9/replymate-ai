import '../models/communication_profile.dart';
import '../models/communication_statistics.dart';

class CommunicationProfileBuilder {
  CommunicationProfile build(
    CommunicationStatistics statistics,
  ) {
    final totalMessages =
        statistics.totalMessages == 0 ? 1 : statistics.totalMessages;

    return CommunicationProfile(
      greeting: _mostFrequent(statistics.greetings),
      closing: _mostFrequent(statistics.closings),
      favoriteWords: _topItems(
        statistics.favoriteWords,
        5,
      ),
      favoriteEmojis: _topItems(
        statistics.favoriteEmojis,
        5,
      ),
      sentenceStyle: _mostFrequent(
        statistics.sentenceStyles,
      ),
      averageWordsPerMessage: (statistics.totalWords / totalMessages).round(),
      emojiUsageRate: statistics.messagesWithEmojis / totalMessages,
      questionRate: statistics.questionMessages / totalMessages,
      exclamationRate: statistics.exclamationMessages / totalMessages,
    );
  }

  String _mostFrequent(
    Map<String, int> values,
  ) {
    if (values.isEmpty) {
      return 'Not learned yet';
    }

    final sorted = values.entries.toList()
      ..sort(
        (a, b) => b.value.compareTo(a.value),
      );

    return sorted.first.key;
  }

  List<String> _topItems(
    Map<String, int> values,
    int limit,
  ) {
    final sorted = values.entries.toList()
      ..sort(
        (a, b) => b.value.compareTo(a.value),
      );

    return sorted.take(limit).map((e) => e.key).toList();
  }
}
