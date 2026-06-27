import 'package:flutter/material.dart';

class RecommendationCard extends StatelessWidget {
  final int bestReplyIndex;
  final String reason;

  const RecommendationCard({
    super.key,
    required this.bestReplyIndex,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.deepPurple.shade700,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⭐ AI Recommended Reply',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Suggestion ${bestReplyIndex + 1}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(reason),
          ],
        ),
      ),
    );
  }
}