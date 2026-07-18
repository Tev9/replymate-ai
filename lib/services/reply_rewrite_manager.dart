import '../services/ai_service.dart';

class ReplyRewriteManager {
  final AiService aiService;

  ReplyRewriteManager({
    required this.aiService,
  });

  Future<String> rewrite({
    required String reply,
    required String instruction,
    required String platform,
    required String writingStyle,
  }) async {
    final rewrittenReply = await aiService.rewriteReply(
      reply: reply,
      instruction: instruction,
      platform: platform,
      writingStyle: writingStyle,
    );

    return rewrittenReply;
  }
}