import 'ai_service.dart';

class ReplyGenerationResult {
  final String conversationType;
  final String conversationMood;
  final String conversationAdvice;
  final List<String> replies;
  final List<int> scores;
  final int bestReplyIndex;
  final String bestReplyReason;

  ReplyGenerationResult({
    required this.conversationType,
    required this.conversationMood,
    required this.conversationAdvice,
    required this.replies,
    required this.scores,
    required this.bestReplyIndex,
    required this.bestReplyReason,
  });
}

class ReplyGenerationManager {
  final AiService aiService;

  ReplyGenerationManager({
    required this.aiService,
  });

  Future<ReplyGenerationResult> generate({
    required String message,
    required String tone,
    required String length,
    required String writingStyle,
    required String platform,
    required String relationshipType,
    required int aiConfidence,
    required int messagesLearned,
    required String greeting,
    required String closing,
    required List<String> favoriteWords,
    required List<String> favoriteEmojis,
    required String sentenceStyle,
    required int averageWordsPerMessage,
    required double emojiUsageRate,
    required double questionRate,
    required double exclamationRate,
  }) async {
    final analysis = await aiService.analyzeConversation(
      message: message,
    );

    final replyData = await aiService.generateReplies(
      message: message,
      tone: tone,
      length: length,
      writingStyle: writingStyle,
      platform: platform,
      relationshipType: relationshipType,
      aiConfidence: aiConfidence,
      messagesLearned: messagesLearned,
      greeting: greeting,
      closing: closing,
      favoriteWords: favoriteWords,
      favoriteEmojis: favoriteEmojis,
      sentenceStyle: sentenceStyle,
      averageWordsPerMessage: averageWordsPerMessage,
      emojiUsageRate: emojiUsageRate,
      questionRate: questionRate,
      exclamationRate: exclamationRate,
    );

    return ReplyGenerationResult(
      conversationType: analysis['type']?.toString() ?? '',
      conversationMood: analysis['mood']?.toString() ?? '',
      conversationAdvice: analysis['advice']?.toString() ?? '',
      replies: List<String>.from(
        replyData['replies'] ?? [],
      ),
      scores: List<int>.from(
        replyData['scores'] ?? [],
      ),
      bestReplyIndex:
          replyData['bestReply'] is int ? replyData['bestReply'] as int : -1,
      bestReplyReason: replyData['reason']?.toString() ?? '',
    );
  }
}
