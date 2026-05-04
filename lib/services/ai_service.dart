import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  final String _apiKey = 'BURAYA_GEMINI_API_KEY';

  Future<String> generateQuestion(String topic) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=$_apiKey',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text":
                    "Konu: $topic. 4 şıklı, açıklamalı bir test sorusu üret. JSON formatında dön: question, options, correctAnswer, explanation"
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("API Hatası: ${response.body}");
    }

    final data = jsonDecode(response.body);

    // Gemini cevabı buradan gelir
    final text =
        data['candidates'][0]['content']['parts'][0]['text'];

    return text;
  }
}
