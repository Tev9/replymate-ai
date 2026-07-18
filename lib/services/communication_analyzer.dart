import '../models/communication_profile.dart';

class CommunicationAnalyzer {
  CommunicationProfile analyze(String text) {
    final messages = _extractMessages(text);

    return CommunicationProfile(
      greeting: _detectGreeting(text),
      closing: _detectClosing(text),
      favoriteWords: _favoriteWords(text),
      favoriteEmojis: _favoriteEmojis(text),
      sentenceStyle: _sentenceStyle(text),
      averageWordsPerMessage: _averageWordsPerMessage(messages),
      emojiUsageRate: _emojiUsageRate(messages),
      questionRate: _questionRate(messages),
      exclamationRate: _exclamationRate(messages),
    );
  }

  String _detectGreeting(String text) {
    final lower = text.trim().toLowerCase();

    const greetings = [
      'good morning',
      'good afternoon',
      'good evening',
      'hello',
      'hey',
      'hi',
    ];

    for (final greeting in greetings) {
      if (lower.startsWith(greeting)) {
        return greeting;
      }
    }

    return 'Not detected';
  }

  String _detectClosing(String text) {
    final lower = text.trim().toLowerCase();

    const closings = [
      'kind regards',
      'best regards',
      'thank you',
      'love you',
      'thanks',
      'cheers',
      'love',
    ];

    for (final closing in closings) {
      if (lower.contains(closing)) {
        return closing;
      }
    }

    return 'Not detected';
  }

  List<String> _favoriteWords(String text) {
    final words = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'));

    final counts = <String, int>{};

    const ignored = {
      'the',
      'a',
      'an',
      'is',
      'are',
      'to',
      'of',
      'and',
      'in',
      'on',
      'for',
      'it',
      'i',
      'you',
      'me',
      'my',
      'your',
      'we',
      'our',
    };

    for (final word in words) {
      if (word.length < 3) continue;
      if (ignored.contains(word)) continue;

      counts[word] = (counts[word] ?? 0) + 1;
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) {
        final frequencyComparison = b.value.compareTo(a.value);

        if (frequencyComparison != 0) {
          return frequencyComparison;
        }

        return a.key.compareTo(b.key);
      });

    return sorted.take(5).map((entry) => entry.key).toList();
  }

  List<String> _favoriteEmojis(String text) {
    final matches = _emojiRegex.allMatches(text);
    final counts = <String, int>{};

    for (final match in matches) {
      final emoji = match.group(0);

      if (emoji == null || emoji.isEmpty) continue;

      counts[emoji] = (counts[emoji] ?? 0) + 1;
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(5).map((entry) => entry.key).toList();
  }

  String _sentenceStyle(String text) {
    final wordCount = _countWords(text);

    if (wordCount < 10) {
      return 'Short';
    }

    if (wordCount < 25) {
      return 'Medium';
    }

    return 'Long';
  }

  List<String> _extractMessages(String text) {
    final messages = text
        .split(RegExp(r'\r?\n'))
        .map((message) => message.trim())
        .where((message) => message.isNotEmpty)
        .toList();

    if (messages.isEmpty && text.trim().isNotEmpty) {
      return [text.trim()];
    }

    return messages;
  }

  int _averageWordsPerMessage(List<String> messages) {
    if (messages.isEmpty) {
      return 0;
    }

    final totalWords = messages.fold<int>(
      0,
      (total, message) => total + _countWords(message),
    );

    return (totalWords / messages.length).round();
  }

  double _emojiUsageRate(List<String> messages) {
    if (messages.isEmpty) {
      return 0;
    }

    final messagesWithEmojis = messages.where((message) {
      return _emojiRegex.hasMatch(message);
    }).length;

    return messagesWithEmojis / messages.length;
  }

  double _questionRate(List<String> messages) {
    if (messages.isEmpty) {
      return 0;
    }

    final questions = messages.where((message) {
      return message.contains('?');
    }).length;

    return questions / messages.length;
  }

  double _exclamationRate(List<String> messages) {
    if (messages.isEmpty) {
      return 0;
    }

    final exclamations = messages.where((message) {
      return message.contains('!');
    }).length;

    return exclamations / messages.length;
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