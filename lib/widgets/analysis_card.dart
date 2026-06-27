import 'package:flutter/material.dart';

class AnalysisCard extends StatelessWidget {
  final String type;
  final String mood;
  final String advice;

  const AnalysisCard({
    super.key,
    required this.type,
    required this.mood,
    required this.advice,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🧠 Conversation Analysis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text('Type: $type'),
            const SizedBox(height: 8),
            Text('Mood: $mood'),
            const SizedBox(height: 8),
            Text('Advice: $advice'),
          ],
        ),
      ),
    );
  }
}