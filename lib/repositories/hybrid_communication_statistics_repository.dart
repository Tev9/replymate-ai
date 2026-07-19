import '../models/communication_profile.dart';
import '../models/communication_statistics.dart';
import '../services/cloud_storage_service.dart';
import '../services/communication_statistics_service.dart';

import 'communication_statistics_repository.dart';

class HybridCommunicationStatisticsRepository
    implements CommunicationStatisticsRepository {
  final CommunicationStatisticsService _localService;
  final CloudStorageService _cloudService;

  HybridCommunicationStatisticsRepository({
    CommunicationStatisticsService? localService,
    CloudStorageService? cloudService,
  })  : _localService =
            localService ??
            CommunicationStatisticsService(),
        _cloudService =
            cloudService ??
            CloudStorageService();

  String _normalizeContactName(
    String contactName,
  ) {
    return contactName.trim().toLowerCase();
  }

  @override
  Future<CommunicationStatistics> loadStatistics(
    String contactName,
  ) async {
    final normalizedContactName =
        _normalizeContactName(contactName);

    final localStatistics =
        await _localService.loadStatistics(
      normalizedContactName,
    );

    final hasLocalData =
        localStatistics.totalMessages > 0 ||
        localStatistics.greetings.isNotEmpty ||
        localStatistics.closings.isNotEmpty ||
        localStatistics.favoriteWords.isNotEmpty ||
        localStatistics.favoriteEmojis.isNotEmpty ||
        localStatistics.sentenceStyles.isNotEmpty;

    if (hasLocalData) {
      return localStatistics;
    }

    try {
      final cloudData =
          await _cloudService.loadDocument(
        collection: 'communicationStatistics',
        documentId: normalizedContactName,
      );

      if (cloudData == null) {
        return localStatistics;
      }

      final cloudStatistics =
          CommunicationStatistics.fromJson(
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
    final normalizedContactName =
        _normalizeContactName(contactName);

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
      // Local save succeeded.
      // Cloud retry handling will be added later.
    }
  }

  @override
  Future<CommunicationStatistics> updateStatistics({
    required String contactName,
    required CommunicationProfile profile,
    required String text,
  }) async {
    final normalizedContactName =
        _normalizeContactName(contactName);

    final updated =
        await _localService.updateStatistics(
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
      // Local update succeeded.
      // Cloud retry handling will be added later.
    }

    return updated;
  }
}