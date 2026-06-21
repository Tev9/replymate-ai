import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  Future<List<String>> generateReplies({
    required String message,
    required String tone,
    required String length,
    required String writingStyle,
    required String platform,
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
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return List<String>.from(data['replies']);
      }

      return ['Failed to generate replies'];
    } catch (e) {
      return ['Error: $e'];
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
}