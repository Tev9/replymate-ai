import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/communication_profile.dart';
import '../models/communication_statistics.dart';

class CommunicationStatisticsService {
  String _key(String contactName) {
    return 'communication_statistics_$contactName';
  }

  Future<CommunicationStatistics> loadStatistics(
    String contactName,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key(contactName));

    if (data == null) {
      return CommunicationStatistics(
        greetings: {},
        closings: {},
        favoriteWords: {},
        favoriteEmojis: {},
        sentenceStyles: {},
      );
    }

    return CommunicationStatistics.fromJson(
      jsonDecode(data),
    );
  }

  Future<void> saveStatistics(
    String contactName,
    CommunicationStatistics statistics,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _key(contactName),
      jsonEncode(statistics.toJson()),
    );
  }

  Future<CommunicationStatistics> updateStatistics({
    required String contactName,
    required CommunicationProfile profile,
    required String text,
  }) async {
    final current = await loadStatistics(contactName);

    final greetings = Map<String, int>.from(
      current.greetings,
    );
    final closings = Map<String, int>.from(
      current.closings,
    );
    final favoriteWords = Map<String, int>.from(
      current.favoriteWords,
    );
    final favoriteEmojis = Map<String, int>.from(
      current.favoriteEmojis,
    );
    final sentenceStyles = Map<String, int>.from(
      current.sentenceStyles,
    );

    if (profile.greeting != 'Not detected') {
      greetings[profile.greeting] =
          (greetings[profile.greeting] ?? 0) + 1;
    }

    if (profile.closing != 'Not detected') {
      closings[profile.closing] =
          (closings[profile.closing] ?? 0) + 1;
    }

    for (final word in profile.favoriteWords) {
      favoriteWords[word] = (favoriteWords[word] ?? 0) + 1;
    }

    for (final emoji in profile.favoriteEmojis) {
      favoriteEmojis[emoji] =
          (favoriteEmojis[emoji] ?? 0) + 1;
    }

    sentenceStyles[profile.sentenceStyle] =
        (sentenceStyles[profile.sentenceStyle] ?? 0) + 1;

    final messages = _extractMessages(text);

    var newTotalWords = 0;
    var newMessagesWithEmojis = 0;
    var newQuestionMessages = 0;
    var newExclamationMessages = 0;

    for (final message in messages) {
      newTotalWords += _countWords(message);

      if (_emojiRegex.hasMatch(message)) {
        newMessagesWithEmojis++;
      }

      if (message.contains('?')) {
        newQuestionMessages++;
      }

      if (message.contains('!')) {
        newExclamationMessages++;
      }
    }

    final updated = CommunicationStatistics(
      greetings: greetings,
      closings: closings,
      favoriteWords: favoriteWords,
      favoriteEmojis: favoriteEmojis,
      sentenceStyles: sentenceStyles,
      totalMessages: current.totalMessages + messages.length,
      totalWords: current.totalWords + newTotalWords,
      messagesWithEmojis:
          current.messagesWithEmojis + newMessagesWithEmojis,
      questionMessages:
          current.questionMessages + newQuestionMessages,
      exclamationMessages:
          current.exclamationMessages + newExclamationMessages,
    );

    await saveStatistics(contactName, updated);

    return updated;
  }

  List<String> _extractMessages(String text) {
    return text
        .split(RegExp(r'\r?\n'))
        .map((message) => message.trim())
        .where((message) => message.isNotEmpty)
        .toList();
  }

  int _countWords(String text) {
    final trimmedText = text.trim();

    if (trimmedText.isEmpty) {
      return 0;
    }

    return trimmedText
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
  }

  static final RegExp _emojiRegex = RegExp(
    r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]',
    unicode: true,
  );
}