import '../models/communication_profile.dart';
import '../models/communication_statistics.dart';

abstract class CommunicationStatisticsRepository {
  Future<CommunicationStatistics> loadStatistics(
    String contactName,
  );

  Future<void> saveStatistics(
    String contactName,
    CommunicationStatistics statistics,
  );

  Future<CommunicationStatistics> updateStatistics({
    required String contactName,
    required CommunicationProfile profile,
    required String text,
  });
}