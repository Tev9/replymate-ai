import '../models/conversation_memory.dart';
import '../services/memory_service.dart';
import 'base/hybrid_repository.dart';
import 'memory_repository.dart';

class HybridMemoryRepository extends HybridRepository<ConversationMemory>
    implements MemoryRepository {
  final MemoryService _localService;

  HybridMemoryRepository({
    MemoryService? localService,
    super.cloudService,
    super.pendingSyncService,
  }) : _localService = localService ?? MemoryService();

  @override
  Future<ConversationMemory?> loadMemory(
    String contactName,
  ) {
    return loadDocumentLocalFirst(
      collection: 'conversationMemories',
      documentId: contactName,
      loadLocal: (documentId) => _localService.loadMemory(documentId),
      saveLocal: (documentId, value) => _localService.saveMemory(value),
      fromJson: ConversationMemory.fromJson,
    );
  }

  @override
  Future<void> saveMemory(
    ConversationMemory memory,
  ) {
    final normalizedContactName = normalizeDocumentId(
      memory.contactName,
    );

    final normalizedMemory = ConversationMemory(
      contactName: normalizedContactName,
      displayName: memory.displayName,
      writingStyle: memory.writingStyle,
      favoriteWords: memory.favoriteWords,
      preferredTone: memory.preferredTone,
      relationshipType: memory.relationshipType,
      preferredPlatform: memory.preferredPlatform,
      preferredReplyLength: memory.preferredReplyLength,
      messagesLearned: memory.messagesLearned,
      aiConfidence: memory.aiConfidence,
      lastUpdated: memory.lastUpdated,
    );

    return saveDocumentLocalFirst(
      collection: 'conversationMemories',
      documentId: normalizedContactName,
      value: normalizedMemory,
      saveLocal: (documentId, value) => _localService.saveMemory(value),
      toJson: (value) => value.toJson(),
    );
  }
}
