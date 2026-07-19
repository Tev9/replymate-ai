import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/conversation_memory.dart';

class MemoryService {
  String _key(String contactName) {
    final normalizedContactName =
        contactName.trim().toLowerCase();

    return 'memory_$normalizedContactName';
  }

  Future<void> saveMemory(
    ConversationMemory memory,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _key(memory.contactName),
      jsonEncode(memory.toJson()),
    );
  }

  Future<ConversationMemory?> loadMemory(
    String contactName,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(
      _key(contactName),
    );

    if (data == null) {
      return null;
    }

    return ConversationMemory.fromJson(
      jsonDecode(data) as Map<String, dynamic>,
    );
  }
}