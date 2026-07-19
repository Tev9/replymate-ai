import '../models/conversation_memory.dart';
import '../services/cloud_storage_service.dart';
import '../services/memory_service.dart';
import 'memory_repository.dart';

class HybridMemoryRepository implements MemoryRepository {
  final MemoryService _localService;
  final CloudStorageService _cloudService;

  HybridMemoryRepository({
    MemoryService? localService,
    CloudStorageService? cloudService,
  })  : _localService = localService ?? MemoryService(),
        _cloudService = cloudService ?? CloudStorageService();

  String _normalizeContactName(String contactName) {
    return contactName.trim().toLowerCase();
  }

  @override
  Future<ConversationMemory?> loadMemory(
    String contactName,
  ) async {
    final normalizedContactName =
        _normalizeContactName(contactName);

    final localMemory =
        await _localService.loadMemory(
      normalizedContactName,
    );

    if (localMemory != null) {
      return localMemory;
    }

    try {
      final cloudData =
          await _cloudService.loadDocument(
        collection: 'conversationMemories',
        documentId: normalizedContactName,
      );

      if (cloudData == null) {
        return null;
      }

      final cloudMemory =
          ConversationMemory.fromJson(cloudData);

      await _localService.saveMemory(cloudMemory);

      return cloudMemory;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveMemory(
    ConversationMemory memory,
  ) async {
    final normalizedContactName =
        _normalizeContactName(memory.contactName);

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

    await _localService.saveMemory(normalizedMemory);

    try {
      await _cloudService.saveDocument(
        collection: 'conversationMemories',
        documentId: normalizedContactName,
        data: normalizedMemory.toJson(),
      );
    } catch (_) {
      // The local save succeeded.
      // Retry handling will be added later.
    }
  }
}