import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  Future<Map<String, dynamic>> generateReplies({
    required String message,
    required String tone,
    required String length,
    required String writingStyle,
    required String platform,
    required String relationshipType,
    required int aiConfidence,
    required int messagesLearned,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3001/generate-replies'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': message,
          'tone': tone,
          'length': length,
          'writingStyle': writingStyle,
          'platform': platform,
          'relationshipType': relationshipType,
          'aiConfidence': aiConfidence,
          'messagesLearned': messagesLearned,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data;
      }

      return {
        'replies': ['Failed to generate replies'],
        'bestReply': -1,
        'reason': '',
      };
    } catch (e) {
      return {
        'replies': ['Error: $e'],
        'bestReply': -1,
        'reason': '',
      };
    }
  }

  Future<String> rewriteReply({
    required String reply,
    required String instruction,
    required String platform,
    required String writingStyle,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3001/rewrite-reply'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'reply': reply,
          'instruction': instruction,
          'platform': platform,
          'writingStyle': writingStyle,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'];
      }

      return 'Failed to rewrite reply';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<Map<String, dynamic>> analyzeConversation({
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3001/analyze-conversation'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        'type': 'Unknown',
        'mood': 'Unknown',
        'advice': 'No advice available',
      };
    } catch (e) {
      return {
        'type': 'Error',
        'mood': 'Error',
        'advice': e.toString(),
      };
    }
  }
}
