import '../models/communication_profile.dart';
import '../models/communication_statistics.dart';
import '../services/cloud_storage_service.dart';
import '../services/communication_statistics_service.dart';
import '../services/pending_sync_service.dart';

import 'communication_statistics_repository.dart';

class HybridCommunicationStatisticsRepository
    implements CommunicationStatisticsRepository {
  final CommunicationStatisticsService _localService;
  final CloudStorageService _cloudService;
  final PendingSyncService _pendingSyncService;

  HybridCommunicationStatisticsRepository({
    CommunicationStatisticsService? localService,
    CloudStorageService? cloudService,
    PendingSyncService? pendingSyncService,
  })  : _localService = localService ?? CommunicationStatisticsService(),
        _cloudService = cloudService ?? CloudStorageService(),
        _pendingSyncService = pendingSyncService ?? PendingSyncService();

  String _normalizeContactName(
    String contactName,
  ) {
    return contactName.trim().toLowerCase();
  }

  @override
  Future<CommunicationStatistics> loadStatistics(
    String contactName,
  ) async {
    final normalizedContactName = _normalizeContactName(contactName);

    final localStatistics = await _localService.loadStatistics(
      normalizedContactName,
    );

    final hasLocalData = localStatistics.totalMessages > 0 ||
        localStatistics.greetings.isNotEmpty ||
        localStatistics.closings.isNotEmpty ||
        localStatistics.favoriteWords.isNotEmpty ||
        localStatistics.favoriteEmojis.isNotEmpty ||
        localStatistics.sentenceStyles.isNotEmpty;

    if (hasLocalData) {
      return localStatistics;
    }

    try {
      final cloudData = await _cloudService.loadDocument(
        collection: 'communicationStatistics',
        documentId: normalizedContactName,
      );

      if (cloudData == null) {
        return localStatistics;
      }

      final cloudStatistics = CommunicationStatistics.fromJson(
        cloudData,
      );

      await _localService.saveStatistics(
        normalizedContactName,
        cloudStatistics,
      );

      return cloudStatistics;
    } catch (_) {
      return localStatistics;
    }
  }

  @override
  Future<void> saveStatistics(
    String contactName,
    CommunicationStatistics statistics,
  ) async {
    final normalizedContactName = _normalizeContactName(contactName);

    await _localService.saveStatistics(
      normalizedContactName,
      statistics,
    );

    try {
      await _cloudService.saveDocument(
        collection: 'communicationStatistics',
        documentId: normalizedContactName,
        data: statistics.toJson(),
      );
    } catch (_) {
      await _pendingSyncService.addOperation(
        collection: 'communicationStatistics',
        documentId: normalizedContactName,
        data: statistics.toJson(),
      );
    }
  }

  @override
  Future<CommunicationStatistics> updateStatistics({
    required String contactName,
    required CommunicationProfile profile,
    required String text,
  }) async {
    final normalizedContactName = _normalizeContactName(contactName);

    final updated = await _localService.updateStatistics(
      contactName: normalizedContactName,
      profile: profile,
      text: text,
    );

    try {
      await _cloudService.saveDocument(
        collection: 'communicationStatistics',
        documentId: normalizedContactName,
        data: updated.toJson(),
      );
    } catch (_) {
      await _pendingSyncService.addOperation(
        collection: 'communicationStatistics',
        documentId: normalizedContactName,
        data: updated.toJson(),
      );
    }

    return updated;
  }
}
