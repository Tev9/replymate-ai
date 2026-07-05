import '../models/communication_profile.dart';

class CommunicationAnalyzer {
  CommunicationProfile analyze(String text) {
    final greeting = _detectGreeting(text);
    final closing = _detectClosing(text);

    return CommunicationProfile(
      greeting: greeting,
      closing: closing,
      favoriteWords: _favoriteWords(text),
      favoriteEmojis: _favoriteEmojis(text),
      sentenceStyle: _sentenceStyle(text),
    );
  }

  String _detectGreeting(String text) {
    final lower = text.toLowerCase();

    const greetings = [
      'hi',
      'hello',
      'hey',
      'good morning',
      'good afternoon',
      'good evening',
    ];

    for (final greeting in greetings) {
      if (lower.startsWith(greeting)) {
        return greeting;
      }
    }

    return 'Not detected';
  }

  String _detectClosing(String text) {
    final lower = text.toLowerCase();

    const closings = [
      'thanks',
      'thank you',
      'cheers',
      'kind regards',
      'best regards',
      'love',
      'love you',
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
        .split(' ');

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
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(5).map((e) => e.key).toList();
  }

  List<String> _favoriteEmojis(String text) {
    final emojiRegex = RegExp(
      r'[\u{1F300}-\u{1FAFF}]',
      unicode: true,
    );

    return emojiRegex
        .allMatches(text)
        .map((e) => e.group(0)!)
        .toSet()
        .toList();
  }

  String _sentenceStyle(String text) {
    final words = text.trim().split(RegExp(r'\s+'));

    if (words.length < 10) {
      return 'Short';
    }

    if (words.length < 25) {
      return 'Medium';
    }

    return 'Long';
  }
}