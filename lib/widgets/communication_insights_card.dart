import 'package:flutter/material.dart';
import '../models/communication_profile.dart';

class CommunicationInsightsCard extends StatelessWidget {
  final CommunicationProfile profile;

  const CommunicationInsightsCard({
    super.key,
    required this.profile,
  });

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
              '💬 Communication Insights',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Text('👋 Greeting: ${profile.greeting}'),

            const SizedBox(height: 8),

            Text('🙏 Closing: ${profile.closing}'),

            const SizedBox(height: 8),

            Text(
              '😊 Favorite Emojis: '
              '${profile.favoriteEmojis.isEmpty ? "None learned yet" : profile.favoriteEmojis.join(" ")}',
            ),

            const SizedBox(height: 8),

            Text(
              '📝 Favorite Words: '
              '${profile.favoriteWords.isEmpty ? "None learned yet" : profile.favoriteWords.join(", ")}',
            ),

            const SizedBox(height: 8),

            Text('📏 Sentence Style: ${profile.sentenceStyle}'),
          ],
        ),
      ),
    );
  }
}