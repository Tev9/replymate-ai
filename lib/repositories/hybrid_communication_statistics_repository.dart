import '../models/communication_profile.dart';
import '../models/communication_statistics.dart';
import '../services/communication_statistics_service.dart';

import 'base/hybrid_repository.dart';
import 'communication_statistics_repository.dart';

class HybridCommunicationStatisticsRepository
    extends HybridRepository<CommunicationStatistics>
    implements CommunicationStatisticsRepository {
  final CommunicationStatisticsService _localService;

  HybridCommunicationStatisticsRepository({
    CommunicationStatisticsService? localService,
    super.cloudService,
    super.pendingSyncService,
  }) : _localService = localService ?? CommunicationStatisticsService();

  @override
  Future<CommunicationStatistics> loadStatistics(
    String contactName,
  ) async {
    final normalizedContactName = normalizeDocumentId(contactName);

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
      final cloudData = await cloudService.loadDocument(
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
  ) {
    return saveDocumentLocalFirst(
      collection: 'communicationStatistics',
      documentId: contactName,
      value: statistics,
      saveLocal: _localService.saveStatistics,
      toJson: (value) => value.toJson(),
    );
  }

  @override
  Future<CommunicationStatistics> updateStatistics({
    required String contactName,
    required CommunicationProfile profile,
    required String text,
  }) async {
    final normalizedContactName = normalizeDocumentId(contactName);

    final updated = await _localService.updateStatistics(
      contactName: normalizedContactName,
      profile: profile,
      text: text,
    );

    await saveCloudDocumentWithFallback(
      collection: 'communicationStatistics',
      documentId: normalizedContactName,
      data: updated.toJson(),
    );

    return updated;
  }
}
