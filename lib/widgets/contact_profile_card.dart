import 'package:flutter/material.dart';
import '../models/conversation_memory.dart';

class ContactProfileCard extends StatelessWidget {
  final ConversationMemory memory;

  const ContactProfileCard({
    super.key,
    required this.memory,
  });

  Color getConfidenceColor() {
    if (memory.aiConfidence >= 90) return Colors.green;
    if (memory.aiConfidence >= 75) return Colors.lightGreen;
    if (memory.aiConfidence >= 50) return Colors.amber;
    if (memory.aiConfidence >= 25) return Colors.orange;

    return Colors.red;
  }

  String getLearningStage() {
    if (memory.aiConfidence >= 90) return '🧠 Expert';
    if (memory.aiConfidence >= 75) return '🚀 Advanced';
    if (memory.aiConfidence >= 50) return '📚 Learning';
    if (memory.aiConfidence >= 25) return '🌱 Beginner';

    return '👋 Just Started';
  }

  String getAiDescription() {
    if (memory.aiConfidence >= 90) {
      return 'ReplyMate knows your communication style extremely well.';
    }

    if (memory.aiConfidence >= 75) {
      return 'ReplyMate has built a strong understanding of this contact.';
    }

    if (memory.aiConfidence >= 50) {
      return 'ReplyMate is learning your communication style.';
    }

    if (memory.aiConfidence >= 25) {
      return 'ReplyMate has started learning this contact.';
    }

    return 'ReplyMate is just beginning to learn this contact.';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '👤 Contact Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text('Name: ${memory.displayName}'),
            Text('Relationship: ${memory.relationshipType}'),
            Text('Tone: ${memory.preferredTone}'),
            Text('Platform: ${memory.preferredPlatform}'),
            Text('Reply Length: ${memory.preferredReplyLength}'),
            Text('Messages Learned: ${memory.messagesLearned}'),
            const SizedBox(height: 12),
            const Text(
              '🧠 AI Learning Status',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: memory.aiConfidence / 100,
                color: getConfidenceColor(),
                backgroundColor: Colors.grey.shade800,
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Confidence: ${memory.aiConfidence}%',
              style: TextStyle(
                color: getConfidenceColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('Learning Stage: ${getLearningStage()}'),
            const SizedBox(height: 6),
            Text(
              getAiDescription(),
              style: const TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Writing Style:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(memory.writingStyle),
          ],
        ),
      ),
    );
  }
}
