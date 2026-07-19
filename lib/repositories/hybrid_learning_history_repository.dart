import '../models/learning_history.dart';
import '../services/cloud_storage_service.dart';
import '../services/learning_history_service.dart';

import 'learning_history_repository.dart';

class HybridLearningHistoryRepository
    implements LearningHistoryRepository {
  final LearningHistoryService _localService;
  final CloudStorageService _cloudService;

  HybridLearningHistoryRepository({
    LearningHistoryService? localService,
    CloudStorageService? cloudService,
  })  : _localService =
            localService ??
            LearningHistoryService(),
        _cloudService =
            cloudService ??
            CloudStorageService();

  String _normalizeContactName(
    String contactName,
  ) {
    return contactName.trim().toLowerCase();
  }

  @override
  Future<List<LearningHistory>> loadHistory(
    String contactName,
  ) async {
    final normalizedContactName =
        _normalizeContactName(contactName);

    final localHistory =
        await _localService.loadHistory(
      normalizedContactName,
    );

    if (localHistory.isNotEmpty) {
      return localHistory;
    }

    try {
      final cloudData =
          await _cloudService.loadDocument(
        collection: 'learningHistories',
        documentId: normalizedContactName,
      );

      if (cloudData == null) {
        return [];
      }

      final List<dynamic> historyJson =
          cloudData['history'] ?? [];

      final history =
          historyJson
              .map(
                (item) =>
                    LearningHistory.fromJson(
                  item
                      as Map<String, dynamic>,
                ),
              )
              .toList();

      for (final item in history.reversed) {
        await _localService.addHistory(
          normalizedContactName,
          item,
        );
      }

      return history;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addHistory(
    String contactName,
    LearningHistory history,
  ) async {
    final normalizedContactName =
        _normalizeContactName(contactName);

    await _localService.addHistory(
      normalizedContactName,
      history,
    );

    try {
      final historyList =
          await _localService.loadHistory(
        normalizedContactName,
      );

      await _cloudService.saveDocument(
        collection: 'learningHistories',
        documentId: normalizedContactName,
        data: {
          'history':
              historyList
                  .map((e) => e.toJson())
                  .toList(),
        },
      );
    } catch (_) {
      // Local save succeeded.
      // Cloud retry support will come later.
    }
  }
}