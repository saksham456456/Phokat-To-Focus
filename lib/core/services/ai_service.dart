import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class AIService {
  // NOTE: For a real production app, this key should be stored securely on a backend server
  // and accessed via a Cloud Function, not hardcoded in the client app.
  static const String _openAiKey = 'YOUR_OPENAI_API_KEY_HERE';
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  Future<String> getCoachingAdvice(List<Task> tasks, UserStats stats, String userMessage) async {
    if (_openAiKey == 'YOUR_OPENAI_API_KEY_HERE') {
      await Future.delayed(const Duration(seconds: 1));
      return "I'm in offline mode right now since my API key isn't configured, but keep up the great work! You've got a ${stats.streak}-day streak!";
    }

    final pendingTasks = tasks.where((t) => !t.isCompleted).map((t) => t.subject).join(', ');

    final systemPrompt = """
      You are an AI Study Coach for a highly disciplined student.
      Their current streak is ${stats.streak} days.
      They have ${tasks.length} tasks today, and still need to complete: $pendingTasks.
      Keep your responses short, motivational, and actionable (under 3 sentences).
    """;

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userMessage}
          ],
          'max_tokens': 100,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return "I'm having trouble connecting right now, but stay focused!";
      }
    } catch (e) {
      return "Error reaching the coaching servers. Try again later.";
    }
  }
}
