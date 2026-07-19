import '../models/communication_profile.dart';
import '../models/communication_statistics.dart';
import '../models/learning_event.dart';
import '../services/style_learning_service.dart';
import '../services/communication_analyzer.dart';
import '../services/communication_profile_builder.dart';
import '../repositories/communication_profile_repository.dart';
import '../models/conversation_memory.dart';
import '../models/learning_history.dart';
import '../repositories/memory_repository.dart';
import '../repositories/learning_history_repository.dart';
import '../repositories/communication_statistics_repository.dart';

class LearningResult {
  final CommunicationProfile profile;
  final CommunicationStatistics statistics;
  final String writingStyle;
  final ConversationMemory? memory;
  final List<LearningHistory> history;

  LearningResult({
    required this.profile,
    required this.statistics,
    required this.writingStyle,
    this.memory,
    this.history = const [],
  });
}

class LearningManager {
  final StyleLearningService styleLearningService;
  final CommunicationAnalyzer communicationAnalyzer;
  final CommunicationStatisticsRepository communicationStatisticsRepository;
  final CommunicationProfileBuilder communicationProfileBuilder;
  final CommunicationProfileRepository communicationProfileRepository;
  final MemoryRepository memoryRepository;
  final LearningHistoryRepository learningHistoryRepository;

  LearningManager({
    required this.styleLearningService,
    required this.communicationAnalyzer,
    required this.communicationStatisticsRepository,
    required this.communicationProfileBuilder,
    required this.communicationProfileRepository,
    required this.memoryRepository,
    required this.learningHistoryRepository,
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
    await learningHistoryRepository.addHistory(
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

    await memoryRepository.saveMemory(memory);

    return memory;
  }

  Future<ConversationMemory> saveContact({
    required String contactName,
    required String displayName,
    required String writingStyle,
    required String preferredTone,
    required String relationshipType,
    required String preferredPlatform,
    required String preferredReplyLength,
  }) async {
    final currentMemory = await memoryRepository.loadMemory(contactName);

    final messagesLearned = (currentMemory?.messagesLearned ?? 0) + 1;

    final updatedMemory = await saveMemory(
      contactName: contactName,
      displayName: displayName,
      writingStyle: writingStyle.isEmpty ? 'Not provided yet' : writingStyle,
      preferredTone: preferredTone,
      relationshipType: relationshipType,
      preferredPlatform: preferredPlatform,
      preferredReplyLength: preferredReplyLength,
      messagesLearned: messagesLearned,
      currentConfidence: currentMemory?.aiConfidence ?? 0,
      event: LearningEvent.newContact,
    );

    await addLearningHistory(
      contactName: contactName,
      title: '👤 Contact Saved',
      description: 'ReplyMate saved this contact profile and preferences.',
    );

    return updatedMemory;
  }

  Future<LearningResult?> loadContact(
    String contactName,
  ) async {
    final memory = await memoryRepository.loadMemory(contactName);

    if (memory == null) {
      return null;
    }

    final history = await learningHistoryRepository.loadHistory(contactName);

    final profile =
        await communicationProfileRepository.loadProfile(contactName);

    final statistics = await communicationStatisticsRepository.loadStatistics(
      contactName,
    );

    return LearningResult(
      profile: profile ??
          CommunicationProfile(
            greeting: 'Not learned yet',
            closing: 'Not learned yet',
            favoriteWords: [],
            favoriteEmojis: [],
            sentenceStyle: 'Not learned yet',
          ),
      statistics: statistics,
      writingStyle: memory.writingStyle,
      memory: memory,
      history: history,
    );
  }

  Future<LearningResult> learn({
    required String contactName,
    required String reply,
    required LearningEvent event,
  }) async {
    final writingStyle = styleLearningService.learnWritingStyle(reply);

    final analyzedProfile = communicationAnalyzer.analyze(reply);

    final updatedStatistics =
        await communicationStatisticsRepository.updateStatistics(
      contactName: contactName,
      profile: analyzedProfile,
      text: reply,
    );

    final cumulativeProfile =
        communicationProfileBuilder.build(updatedStatistics);

    await communicationProfileRepository.saveProfile(
      contactName,
      cumulativeProfile,
    );

    return LearningResult(
      profile: cumulativeProfile,
      statistics: updatedStatistics,
      writingStyle: writingStyle,
    );
  }

  Future<LearningResult> learnFromReply({
    required String contactName,
    required String displayName,
    required String reply,
    required String preferredTone,
    required String relationshipType,
    required String preferredPlatform,
    required String preferredReplyLength,
    required LearningEvent event,
  }) async {
    final currentMemory = await memoryRepository.loadMemory(contactName);

    final isFirstLearning =
        currentMemory == null || currentMemory.messagesLearned == 0;

    final messagesLearned = (currentMemory?.messagesLearned ?? 0) + 1;

    final learningResult = await learn(
      contactName: contactName,
      reply: reply,
      event: event,
    );

    final updatedMemory = await saveMemory(
      contactName: contactName,
      displayName: displayName,
      writingStyle: learningResult.writingStyle,
      preferredTone: preferredTone,
      relationshipType: relationshipType,
      preferredPlatform: preferredPlatform,
      preferredReplyLength: preferredReplyLength,
      messagesLearned: messagesLearned,
      currentConfidence: currentMemory?.aiConfidence ?? 0,
      event: event,
    );

    if (isFirstLearning) {
      await addLearningHistory(
        contactName: contactName,
        title: '👤 Contact Created',
        description: 'ReplyMate started learning this contact.',
      );
    }

    String historyTitle;
    String historyDescription;

    switch (event) {
      case LearningEvent.copiedReply:
        historyTitle = '📋 Reply Copied';
        historyDescription = 'ReplyMate learned from a copied reply.';
        break;

      case LearningEvent.rewrittenReply:
        historyTitle = '✏️ Reply Rewritten';
        historyDescription = 'ReplyMate learned from a rewritten reply.';
        break;

      case LearningEvent.manualWritingSample:
        historyTitle = '📝 Writing Sample Added';
        historyDescription = 'ReplyMate learned from a manual writing sample.';
        break;

      case LearningEvent.directSend:
        historyTitle = '📤 Reply Sent';
        historyDescription = 'ReplyMate learned from a directly sent reply.';
        break;

      case LearningEvent.newContact:
        historyTitle = '👤 Contact Updated';
        historyDescription = 'ReplyMate updated this contact profile.';
        break;
    }

    await addLearningHistory(
      contactName: contactName,
      title: historyTitle,
      description: historyDescription,
    );

    final updatedHistory =
        await learningHistoryRepository.loadHistory(contactName);

    return LearningResult(
      profile: learningResult.profile,
      statistics: learningResult.statistics,
      writingStyle: learningResult.writingStyle,
      memory: updatedMemory,
      history: updatedHistory,
    );
  }
}
