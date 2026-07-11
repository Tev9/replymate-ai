import 'package:flutter/material.dart';
import '../models/communication_statistics.dart';

class CommunicationStatisticsCard extends StatelessWidget {
  final CommunicationStatistics statistics;

  const CommunicationStatisticsCard({
    super.key,
    required this.statistics,
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
              '📊 Communication Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildSection(
              '👋 Greetings',
              statistics.greetings,
            ),

            _buildSection(
              '🙏 Closings',
              statistics.closings,
            ),

            _buildSection(
              '😊 Favorite Emojis',
              statistics.favoriteEmojis,
            ),

            _buildSection(
              '📝 Favorite Words',
              statistics.favoriteWords,
            ),

            _buildSection(
              '📏 Sentence Styles',
              statistics.sentenceStyles,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    Map<String, int> values,
  ) {
    final sorted = values.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          if (sorted.isEmpty)
            const Text('Nothing learned yet')
          else
            ...sorted.take(5).map(
                  (entry) => Text(
                    '${entry.key} × ${entry.value}',
                  ),
                ),
        ],
      ),
    );
  }
}