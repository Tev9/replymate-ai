import 'package:flutter/material.dart';
import '../models/learning_history.dart';

class LearningTimelineCard extends StatelessWidget {
  final List<LearningHistory> history;

  const LearningTimelineCard({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.blueGrey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📈 AI Learning Timeline',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ...history.take(5).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  '),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(item.description),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}