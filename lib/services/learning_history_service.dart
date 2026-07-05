import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/learning_history.dart';

class LearningHistoryService {
  String _key(String contactName) {
    return 'learning_history_$contactName';
  }

  Future<List<LearningHistory>> loadHistory(String contactName) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key(contactName));

    if (data == null) {
      return [];
    }

    final List decoded = jsonDecode(data);

    return decoded
        .map((item) => LearningHistory.fromJson(item))
        .toList();
  }

  Future<void> addHistory(
    String contactName,
    LearningHistory history,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final historyList = await loadHistory(contactName);
    historyList.insert(0, history);

    final encoded = jsonEncode(
      historyList.map((item) => item.toJson()).toList(),
    );

    await prefs.setString(_key(contactName), encoded);
  }
}