import '../models/learning_history.dart';
import '../services/cloud_storage_service.dart';
import '../services/learning_history_service.dart';
import '../services/pending_sync_service.dart';

import 'learning_history_repository.dart';

class HybridLearningHistoryRepository implements LearningHistoryRepository {
  final LearningHistoryService _localService;
  final CloudStorageService _cloudService;
  final PendingSyncService _pendingSyncService;

  HybridLearningHistoryRepository({
    LearningHistoryService? localService,
    CloudStorageService? cloudService,
    PendingSyncService? pendingSyncService,
  })  : _localService = localService ?? LearningHistoryService(),
        _cloudService = cloudService ?? CloudStorageService(),
        _pendingSyncService = pendingSyncService ?? PendingSyncService();

  String _normalizeContactName(String contactName) {
    return contactName.trim().toLowerCase();
  }

  @override
  Future<List<LearningHistory>> loadHistory(
    String contactName,
  ) async {
    final normalizedContactName = _normalizeContactName(contactName);

    final localHistory = await _localService.loadHistory(
      normalizedContactName,
    );

    if (localHistory.isNotEmpty) {
      return localHistory;
    }

    try {
      final cloudHistoryData = await _cloudService.loadSubcollectionDocuments(
        collection: 'learningHistories',
        documentId: normalizedContactName,
        subcollection: 'events',
      );

      final cloudHistory =
          cloudHistoryData.map(LearningHistory.fromJson).toList();

      for (final item in cloudHistory.reversed) {
        await _localService.addHistory(
          normalizedContactName,
          item,
        );
      }

      return cloudHistory;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addHistory(
    String contactName,
    LearningHistory history,
  ) async {
    final normalizedContactName = _normalizeContactName(contactName);

    await _localService.addHistory(
      normalizedContactName,
      history,
    );

    try {
      await _cloudService.saveSubcollectionDocument(
        collection: 'learningHistories',
        documentId: normalizedContactName,
        subcollection: 'events',
        subdocumentId: history.id,
        data: history.toJson(),
      );
    } catch (_) {
      await _pendingSyncService.addOperation(
        collection: 'learningHistories',
        documentId: normalizedContactName,
        subcollection: 'events',
        subdocumentId: history.id,
        data: history.toJson(),
      );
    }
  }
}
