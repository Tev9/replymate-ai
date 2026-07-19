import '../models/learning_history.dart';

abstract class LearningHistoryRepository {
  Future<List<LearningHistory>> loadHistory(
    String contactName,
  );

  Future<void> addHistory(
    String contactName,
    LearningHistory history,
  );
}