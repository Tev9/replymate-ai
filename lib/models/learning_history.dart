import 'package:uuid/uuid.dart';

class LearningHistory {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;

  LearningHistory({
    String? id,
    required this.title,
    required this.description,
    required this.timestamp,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory LearningHistory.fromJson(Map<String, dynamic> json) {
    return LearningHistory(
      id: json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
