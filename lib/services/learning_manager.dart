import '../models/communication_profile.dart';
import '../models/communication_statistics.dart';
import '../models/learning_event.dart';
import '../services/style_learning_service.dart';
import '../services/communication_analyzer.dart';
import '../services/communication_statistics_service.dart';
import '../services/communication_profile_builder.dart';
import '../services/communication_profile_service.dart';
import '../models/conversation_memory.dart';
import '../models/learning_history.dart';
import '../services/memory_service.dart';
import '../services/learning_history_service.dart';

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
  final MemoryService memoryService;
  final LearningHistoryService learningHistoryService;

  LearningManager({
    required this.styleLearningService,
    required this.communicationAnalyzer,
    required this.communicationStatisticsService,
    required this.communicationProfileBuilder,
    required this.communicationProfileService,
    required this.memoryService,
    required this.learningHistoryService,
  });

  int increaseConfidence({
    required int currentConfidence,
    required LearningEvent event,
  }) {
    int increase = 0;

    switch (event) {
      case LearningEvent.newContact:
        increase = 5;
        break;
      case LearningEvent.copiedReply:
        increase = 3;
        break;
      case LearningEvent.rewrittenReply:
        increase = 7;
        break;
      case LearningEvent.manualWritingSample:
        increase = 10;
        break;
      case LearningEvent.directSend:
        increase = 15;
        break;
    }

    final newConfidence = currentConfidence + increase;

    return newConfidence > 100 ? 100 : newConfidence;
  }

  Future<void> addLearningHistory({
    required String contactName,
    required String title,
    required String description,
  }) async {
    await learningHistoryService.addHistory(
      contactName,
      LearningHistory(
        title: title,
        description: description,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<ConversationMemory> saveMemory({
    required String contactName,
    required String displayName,
    required String writingStyle,
    required String preferredTone,
    required String relationshipType,
    required String preferredPlatform,
    required String preferredReplyLength,
    required int messagesLearned,
    required int currentConfidence,
    required LearningEvent event,
  }) async {
    final memory = ConversationMemory(
      contactName: contactName,
      displayName: displayName,
      writingStyle: writingStyle,
      favoriteWords: [],
      preferredTone: preferredTone,
      relationshipType: relationshipType,
      preferredPlatform: preferredPlatform,
      preferredReplyLength: preferredReplyLength,
      messagesLearned: messagesLearned,
      aiConfidence: increaseConfidence(
        currentConfidence: currentConfidence,
        event: event,
      ),
      lastUpdated: DateTime.now(),
    );

    await memoryService.saveMemory(memory);

    return memory;
  }

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
