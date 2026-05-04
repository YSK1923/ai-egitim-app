import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/question_model.dart';
import '../models/student_model.dart';

class AIService extends ChangeNotifier {
  // ⚠️ BURAYA YENİ API ANAHTARINIZI YAZIN
  // https://aistudio.google.com/app/apikey adresinden alabilirsiniz
  static const String _apiKey = 'AIzaSyD-2yAmVEnF_HAT4FOLT7ntNuWx_L8cNJ';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  bool _isLoading = false;
  String _currentExplanation = '';
  String _errorMessage = '';
  int _attemptCount = 0;

  bool get isLoading => _isLoading;
  String get currentExplanation => _currentExplanation;
  String get errorMessage => _errorMessage;

  Future<Question?> generateQuestion({
    required String topic,
    required String subtopic,
    required int difficulty,
    required StudentModel student,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final mastery = student.topicMastery[topic] ?? 0.0;
    final prompt = '''
Sen bir Türk eğitim sistemi uzmanısın. Aşağıdaki kriterlere göre bir soru üret:

Konu: $topic
Alt konu: $subtopic
Zorluk: $difficulty/5
Öğrenci hakimiyet seviyesi: ${(mastery * 100).toInt()}%
Başarı oranı: ${(student.successRate * 100).toInt()}%

Aşağıdaki JSON formatında yanıt ver (başka hiçbir şey yazma):
{
  "id": "q_${DateTime.now().millisecondsSinceEpoch}",
  "topic": "$topic",
  "subtopic": "$subtopic",
  "text": "Soru metni buraya",
  "options": ["A seçeneği", "B seçeneği", "C seçeneği", "D seçeneği"],
  "correctIndex": 0,
  "explanation": "Detaylı açıklama",
  "difficulty": $difficulty,
  "examProbability": 0.75,
  "emoji": "🔢",
  "storyContext": "Hikaye bağlamı"
}
''';

    try {
      final response = await _callAPI(prompt);
      if (response != null) {
        final cleaned = response.replaceAll('```json', '').replaceAll('```', '').trim();
        final json = jsonDecode(cleaned);
        _isLoading = false;
        notifyListeners();
        return Question.fromJson(json);
      } else {
        _errorMessage = 'Soru üretilemedi. API yanıt vermedi.';
      }
    } catch (e) {
      debugPrint('Soru üretme hatası: $e');
      _errorMessage = 'Soru üretilirken hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<AIResponse?> analyzeWrongAnswer({
    required Question question,
    required String userAnswer,
    required StudentModel student,
    required int attemptNumber,
  }) async {
    _isLoading = true;
    _attemptCount = attemptNumber;
    _errorMessage = '';
    notifyListeners();

    final explanationStyle = attemptNumber == 1
        ? 'standart'
        : attemptNumber == 2
            ? 'görsel ve analoji ile'
            : 'çok basit adım adım';

    final prompt = '''
Bir öğrenci soruya yanlış cevap verdi. ${attemptNumber}. denemesi bu.

SORU: ${question.text}
SEÇENEKLER: ${question.options.join(', ')}
DOĞRU CEVAP: ${question.correctAnswer}
ÖĞRENCİNİN CEVABI: $userAnswer
KONU: ${question.topic} - ${question.subtopic}

Açıklama stili: $explanationStyle

Aşağıdaki JSON formatında yanıt ver:
{
  "explanation": "Ana açıklama",
  "alternativeExplanation": "Farklı açıklama",
  "storyMode": "Hikaye modunda açıklama",
  "encouragement": "Motive edici mesaj",
  "hints": ["İpucu 1", "İpucu 2", "İpucu 3"],
  "suggestedXP": 5
}
''';

    try {
      final response = await _callAPI(prompt);
      if (response != null) {
        final cleaned = response.replaceAll('```json', '').replaceAll('```', '').trim();
        final json = jsonDecode(cleaned);
        _currentExplanation = json['explanation'] ?? '';
        notifyListeners();
        _isLoading = false;
        notifyListeners();
        return AIResponse.fromJson(json);
      } else {
        _errorMessage = 'Açıklama alınamadı. API yanıt vermedi.';
      }
    } catch (e) {
      debugPrint('Cevap analiz hatası: $e');
      _errorMessage = 'Analiz sırasında hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<Map<String, double>> calculateExamProbabilities({
    required String topic,
    required List<String> subtopics,
  }) async {
    final prompt = '''
Türkiye sınavları (LGS, YKS) için bu konuların çıkma ihtimallerini ver:
Konu: $topic, Alt konular: ${subtopics.join(', ')}
JSON formatında (0.0-1.0 arası): { ${subtopics.map((s) => '"$s": 0.75').join(', ')} }
''';

    try {
      final response = await _callAPI(prompt);
      if (response != null) {
        final cleaned = response.replaceAll('```json', '').replaceAll('```', '').trim();
        final json = jsonDecode(cleaned) as Map<String, dynamic>;
        return json.map((k, v) => MapEntry(k, (v as num).toDouble()));
      }
    } catch (e) {
      debugPrint('Olasılık hesaplama hatası: $e');
    }
    return {for (var s in subtopics) s: 0.5};
  }

  Future<String> generateLearningInsight(StudentModel student) async {
    final prompt = '''
Öğrenci: ${student.name}, Seviye: ${student.level}, 
Başarı: ${(student.successRate * 100).toInt()}%, Seri: ${student.streak} gün.
Kısa (2-3 cümle), motive edici, emoji'li, Türkçe değerlendirme yap.
''';
    try {
      final result = await _callAPI(prompt);
      return result ?? '🌟 Bugün harika bir gün, hadi başlayalım!';
    } catch (e) {
      return '🌟 Bugün harika bir gün, hadi başlayalım!';
    }
  }

  Future<String> generateStoryIntro(String topic) async {
    final prompt = '"$topic" konusu için RPG tarzı, 3 cümle, emoji\'li, Türkçe hikaye girişi yaz.';
    try {
      return await _callAPI(prompt) ?? '🎮 Yeni bir macera başlıyor!';
    } catch (e) {
      return '🎮 Yeni bir macera başlıyor!';
    }
  }

  Future<String?> _callAPI(String prompt) async {
    // API anahtarı kontrol et
    if (_apiKey == 'BURAYA_API_ANAHTARINIZI_YAZIN' || _apiKey.isEmpty) {
      debugPrint('⚠️ API anahtarı ayarlanmamış!');
      _errorMessage = 'API anahtarı eksik. Lütfen ai_service.dart dosyasını güncelleyin.';
      notifyListeners();
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'maxOutputTokens': 1024,
            'temperature': 0.7,
          },
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('API isteği zaman aşımına uğradı (30 saniye)');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['candidates'][0]['content']['parts'][0]['text'] as String?;
      } else if (response.statusCode == 400) {
        debugPrint('API 400 hatası - Geçersiz istek: ${response.body}');
        _errorMessage = 'API isteği geçersiz. Lütfen tekrar deneyin.';
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        debugPrint('API 401/403 hatası - Geçersiz anahtar: ${response.body}');
        _errorMessage = '❌ API anahtarı geçersiz veya süresi dolmuş!\n'
            'https://aistudio.google.com/app/apikey adresinden yeni anahtar alın.';
      } else if (response.statusCode == 429) {
        debugPrint('API 429 hatası - Rate limit: ${response.body}');
        _errorMessage = 'Çok fazla istek gönderildi. Lütfen biraz bekleyin.';
      } else {
        debugPrint('API hatası: ${response.statusCode} - ${response.body}');
        _errorMessage = 'Sunucu hatası (${response.statusCode}). Lütfen tekrar deneyin.';
      }
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('HTTP hatası: $e');
      _errorMessage = 'Bağlantı hatası: $e';
      notifyListeners();
      return null;
    }
  }
}
