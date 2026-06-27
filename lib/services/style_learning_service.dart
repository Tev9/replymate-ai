class StyleLearningService {
  String learnWritingStyle(String text) {
    final lower = text.toLowerCase();

    final hasEmoji = RegExp(
      r'[\u{1F300}-\u{1FAFF}]',
      unicode: true,
    ).hasMatch(text);

    final isShort = text.length < 80;
    final hasThanks =
        lower.contains('thanks') || lower.contains('thank you');
    final hasPlease = lower.contains('please');

    final traits = <String>[];

    if (hasEmoji) {
      traits.add('Uses emojis');
    }

    if (isShort) {
      traits.add('Prefers short replies');
    } else {
      traits.add('Prefers detailed replies');
    }

    if (hasThanks) {
      traits.add('Polite');
    }

    if (hasPlease) {
      traits.add('Respectful');
    }

    if (traits.isEmpty) {
      traits.add('Neutral writing style');
    }

    return traits.join(', ');
  }
}