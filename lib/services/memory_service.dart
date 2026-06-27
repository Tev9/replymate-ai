import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/conversation_memory.dart';

class MemoryService {
  Future<void> saveMemory(ConversationMemory memory) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'memory_${memory.contactName}',
      jsonEncode(memory.toJson()),
    );
  }

  Future<ConversationMemory?> loadMemory(String contactName) async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString('memory_$contactName');

    if (data == null) {
      return null;
    }

    return ConversationMemory.fromJson(jsonDecode(data));
  }
}