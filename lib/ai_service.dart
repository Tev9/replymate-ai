import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  Future<List<String>> generateReplies({
    required String message,
    required String tone,
    required String length,
    required String writingStyle,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    return [
      'AI reply 1 for "$message"',
      'AI reply 2 in $tone tone',
      'AI reply 3 with $length length',
    ];
  }
}