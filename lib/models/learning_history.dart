class LearningHistory {
  final String title;
  final String description;
  final DateTime timestamp;

  LearningHistory({
    required this.title,
    required this.description,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory LearningHistory.fromJson(Map<String, dynamic> json) {
    return LearningHistory(
      title: json['title'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}