import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static const String _apiKey = '';

  static Future<List<String>> generatePlan({
    required String target,
    required String duration,
    required String level,
    required String description,
  }) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-flash-latest', 
        apiKey: _apiKey,
      );

      // සති ගණන අනුව දින ගණන ගණනය කිරීම
      int totalDays = int.parse(duration) * 7;

      final prompt = """
        Create a concise learning plan for: $target.
        Timeframe: $duration weeks ($totalDays days).
        Experience level: $level.
        Context: $description.

        Strict Rules:
        1. Return exactly $totalDays tasks.
        2. Return ONLY the tasks separated by commas.
        3. Do not include numbers, bullet points, or JSON formatting.
        """;

      final response = await model.generateContent([Content.text(prompt)]);
      String text = response.text ?? "";

      if (text.isNotEmpty) {
        // කොමාවෙන් වෙන් කරලා ලිස්ට් එකක් හදාගැනීම (JSON Decode අවශ්‍ය නැත)
        return text.split(',').map((task) => task.trim()).where((task) => task.isNotEmpty).toList();
      }
      
      return [];

    } catch (e) {
      print("AI Service Error: $e");
      return [];
    }
  }
}