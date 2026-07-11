import '../models/communication_profile.dart';
import '../models/communication_statistics.dart';
import '../models/learning_event.dart';
import '../services/style_learning_service.dart';
import '../services/communication_analyzer.dart';
import '../services/communication_statistics_service.dart';
import '../services/communication_profile_builder.dart';
import '../services/communication_profile_service.dart';

class LearningResult {
  final CommunicationProfile profile;
  final CommunicationStatistics statistics;
  final String writingStyle;

  LearningResult({
    required this.profile,
    required this.statistics,
    required this.writingStyle,
  });
}

class LearningManager {
  final StyleLearningService styleLearningService;
  final CommunicationAnalyzer communicationAnalyzer;
  final CommunicationStatisticsService communicationStatisticsService;
  final CommunicationProfileBuilder communicationProfileBuilder;
  final CommunicationProfileService communicationProfileService;

  LearningManager({
    required this.styleLearningService,
    required this.communicationAnalyzer,
    required this.communicationStatisticsService,
    required this.communicationProfileBuilder,
    required this.communicationProfileService,
  });

  Future<LearningResult> learn({
    required String contactName,
    required String reply,
    required LearningEvent event,
  }) async {
    final writingStyle = styleLearningService.learnWritingStyle(reply);

    final analyzedProfile = communicationAnalyzer.analyze(reply);

    final updatedStatistics =
        await communicationStatisticsService.updateStatistics(
      contactName: contactName,
      profile: analyzedProfile,
    );

    final cumulativeProfile =
        communicationProfileBuilder.build(updatedStatistics);

    await communicationProfileService.saveProfile(
      contactName,
      cumulativeProfile,
    );

    return LearningResult(
      profile: cumulativeProfile,
      statistics: updatedStatistics,
      writingStyle: writingStyle,
    );
  }
}
