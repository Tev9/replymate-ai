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
  }) async {
    final current = await loadStatistics(contactName);

    final greetings = Map<String, int>.from(current.greetings);
    final closings = Map<String, int>.from(current.closings);
    final favoriteWords =
        Map<String, int>.from(current.favoriteWords);
    final favoriteEmojis =
        Map<String, int>.from(current.favoriteEmojis);
    final sentenceStyles =
        Map<String, int>.from(current.sentenceStyles);

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

    final updated = CommunicationStatistics(
      greetings: greetings,
      closings: closings,
      favoriteWords: favoriteWords,
      favoriteEmojis: favoriteEmojis,
      sentenceStyles: sentenceStyles,
    );

    await saveStatistics(contactName, updated);

    return updated;
  }
}