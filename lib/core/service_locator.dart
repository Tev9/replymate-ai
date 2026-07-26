import 'package:get_it/get_it.dart';

import '../services/ai_service.dart';
import '../services/memory_service.dart';
import '../services/style_learning_service.dart';
import '../services/communication_analyzer.dart';
import '../services/communication_profile_service.dart';
import '../services/communication_statistics_service.dart';
import '../services/communication_profile_builder.dart';
import '../services/learning_history_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/pending_sync_service.dart';
import '../services/connectivity_service.dart';

import '../repositories/hybrid_memory_repository.dart';
import '../repositories/hybrid_learning_history_repository.dart';
import '../repositories/hybrid_communication_profile_repository.dart';
import '../repositories/hybrid_communication_statistics_repository.dart';

import '../services/learning_manager.dart';
import '../services/reply_generation_manager.dart';
import '../services/reply_rewrite_manager.dart';

import '../managers/sync_manager.dart';

final GetIt serviceLocator = GetIt.instance;

void setupServiceLocator() {
  // Core services
  serviceLocator.registerLazySingleton<AiService>(
    AiService.new,
  );

  serviceLocator.registerLazySingleton<MemoryService>(
    MemoryService.new,
  );

  serviceLocator.registerLazySingleton<StyleLearningService>(
    StyleLearningService.new,
  );

  serviceLocator.registerLazySingleton<CommunicationAnalyzer>(
    CommunicationAnalyzer.new,
  );

  serviceLocator.registerLazySingleton<CommunicationProfileService>(
    CommunicationProfileService.new,
  );

  serviceLocator.registerLazySingleton<CommunicationStatisticsService>(
    CommunicationStatisticsService.new,
  );

  serviceLocator.registerLazySingleton<CommunicationProfileBuilder>(
    CommunicationProfileBuilder.new,
  );

  serviceLocator.registerLazySingleton<LearningHistoryService>(
    LearningHistoryService.new,
  );

  serviceLocator.registerLazySingleton<CloudStorageService>(
    CloudStorageService.new,
  );

  serviceLocator.registerLazySingleton<PendingSyncService>(
    PendingSyncService.new,
  );

  serviceLocator.registerLazySingleton<ConnectivityService>(
    ConnectivityService.new,
  );

  // Repositories
  serviceLocator.registerLazySingleton<HybridCommunicationProfileRepository>(
    () => HybridCommunicationProfileRepository(
      localService: serviceLocator<CommunicationProfileService>(),
      cloudService: serviceLocator<CloudStorageService>(),
      pendingSyncService: serviceLocator<PendingSyncService>(),
    ),
  );

  serviceLocator.registerLazySingleton<HybridMemoryRepository>(
    () => HybridMemoryRepository(
      localService: serviceLocator<MemoryService>(),
      cloudService: serviceLocator<CloudStorageService>(),
      pendingSyncService: serviceLocator<PendingSyncService>(),
    ),
  );

  serviceLocator.registerLazySingleton<HybridLearningHistoryRepository>(
    () => HybridLearningHistoryRepository(
      localService: serviceLocator<LearningHistoryService>(),
      cloudService: serviceLocator<CloudStorageService>(),
      pendingSyncService: serviceLocator<PendingSyncService>(),
    ),
  );

  serviceLocator.registerLazySingleton<HybridCommunicationStatisticsRepository>(
    () => HybridCommunicationStatisticsRepository(
      localService: serviceLocator<CommunicationStatisticsService>(),
      cloudService: serviceLocator<CloudStorageService>(),
      pendingSyncService: serviceLocator<PendingSyncService>(),
    ),
  );

  // Managers
  serviceLocator.registerLazySingleton<SyncManager>(
    () => SyncManager(
      pendingSyncService: serviceLocator<PendingSyncService>(),
      cloudStorageService: serviceLocator<CloudStorageService>(),
    ),
  );

  serviceLocator.registerLazySingleton<LearningManager>(
    () => LearningManager(
      styleLearningService: serviceLocator<StyleLearningService>(),
      communicationAnalyzer: serviceLocator<CommunicationAnalyzer>(),
      communicationStatisticsRepository:
          serviceLocator<HybridCommunicationStatisticsRepository>(),
      communicationProfileBuilder:
          serviceLocator<CommunicationProfileBuilder>(),
      communicationProfileRepository:
          serviceLocator<HybridCommunicationProfileRepository>(),
      memoryRepository: serviceLocator<HybridMemoryRepository>(),
      learningHistoryRepository:
          serviceLocator<HybridLearningHistoryRepository>(),
    ),
  );

  serviceLocator.registerLazySingleton<ReplyGenerationManager>(
    () => ReplyGenerationManager(
      aiService: serviceLocator<AiService>(),
    ),
  );

  serviceLocator.registerLazySingleton<ReplyRewriteManager>(
    () => ReplyRewriteManager(
      aiService: serviceLocator<AiService>(),
    ),
  );
}
