import '../models/conversation_memory.dart';

abstract class MemoryRepository {
  Future<void> saveMemory(
    ConversationMemory memory,
  );

  Future<ConversationMemory?> loadMemory(
    String contactName,
  );
}