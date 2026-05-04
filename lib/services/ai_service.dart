import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/question_model.dart';
import '../models/student_model.dart';

class AIService extends ChangeNotifier {
  // ⚠️ Buraya kendi Anthropic API anahtarınızı ekleyin
  static const String _apiKey = 'YOUR_ANTHROPIC_API_KEY';
  static const String _baseUrl = 'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-opus-4-20250514';

  bool _isLoading = false;
  String _currentExplanation = '';
  int _attemptCount = 0;

  bool get isLoading => _isLoading;
  String get currentExplanation => _currentExplanation;

  // ============================================================
  // MODÜL 1: MÜFREDat MOTORU - Konu bazlı soru üretimi
  // ============================================================
  Future<Question?> generateQuestion({
    required String topic,
    required String subtopic,
    required int difficulty,
    required StudentModel student,
  }) async {
    _isLoading = true;
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
  "storyContext": "Hikaye bağlamı - sanki bir macera oyunundaymış gibi"
}

Önemli kurallar:
- Soru Türkçe olsun (İngilizce için İngilizce)
- 4 seçenek olsun
- correctIndex: doğru cevabın index'i (0-3)
- storyContext: öğrencinin ilgisini çekecek eğlenceli bir bağlam
- examProbability: bu sorunun sınavda çıkma ihtimali
''';

    try {
      final response = await _callAPI(prompt);
      if (response != null) {
        final cleaned = response.replaceAll('```json', '').replaceAll('```', '').trim();
        final json = jsonDecode(cleaned);
        return Question.fromJson(json);
      }
    } catch (e) {
      debugPrint('Soru üretme hatası: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  // ============================================================
  // MODÜL 2: SORU ANALİZ MOTORU - Yanlış cevap analizi
  // ============================================================
  Future<AIResponse?> analyzeWrongAnswer({
    required Question question,
    required String userAnswer,
    required StudentModel student,
    required int attemptNumber,
  }) async {
    _isLoading = true;
    _attemptCount = attemptNumber;
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
HİKAYE BAĞLAMI: ${question.storyContext}

Açıklama stili: $explanationStyle

Aşağıdaki JSON formatında yanıt ver:
{
  "explanation": "Ana açıklama (emoji kullan, $explanationStyle stil)",
  "alternativeExplanation": "Farklı bir açıklama yöntemi - analoji veya günlük hayat örneği",
  "storyMode": "Hikaye modunda açıklama - karakterler ve macera kullanarak",
  "encouragement": "Motive edici ve eğlenceli bir mesaj",
  "hints": ["İpucu 1", "İpucu 2", "İpucu 3"],
  "suggestedXP": 5
}

Kurallar:
- Asla "yanlış yaptın" veya negatif mesaj kullanma
- Her denemede farklı bir açıklama yöntemi kullan
- Emoji ve eğlenceli dil kullan
- Öğrenci asla tıkanamaz, her zaman yeni bir yol sun
''';

    try {
      final response = await _callAPI(prompt);
      if (response != null) {
        final cleaned = response.replaceAll('```json', '').replaceAll('```', '').trim();
        final json = jsonDecode(cleaned);
        _currentExplanation = json['explanation'] ?? '';
        notifyListeners();
        return AIResponse.fromJson(json);
      }
    } catch (e) {
      debugPrint('Cevap analiz hatası: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  // ============================================================
  // MODÜL 5: ÇIKMA İHTİMALİ MOTORU
  // ============================================================
  Future<Map<String, double>> calculateExamProbabilities({
    required String topic,
    required List<String> subtopics,
  }) async {
    final prompt = '''
Türkiye'deki sınavlar için (LGS, YKS, KPSS) aşağıdaki konuların çıkma ihtimallerini hesapla:

Konu: $topic
Alt konular: ${subtopics.join(', ')}

Son 5 yılın sınav verilerini baz alarak her alt konunun çıkma olasılığını 0.0-1.0 arasında ver.

JSON formatında yanıt ver:
{
  ${subtopics.map((s) => '"$s": 0.75').join(',\n  ')}
}
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

  // ============================================================
  // MODÜL 6: BİLGİ KAZANCI MOTORU
  // ============================================================
  Future<String> generateLearningInsight(StudentModel student) async {
    final prompt = '''
Aşağıdaki öğrenci profilini analiz et ve kişiselleştirilmiş bir içgörü üret:

Ad: ${student.name}
Seviye: ${student.level}
Başarı oranı: ${(student.successRate * 100).toInt()}%
Seri: ${student.streak} gün
Konu hakimiyetleri: ${student.topicMastery.entries.map((e) => '${e.key}: ${(e.value * 100).toInt()}%').join(', ')}

Kısa (2-3 cümle) ve motive edici bir değerlendirme yap. Emoji kullan. Türkçe yaz.
Güçlü yönleri öne çıkar ve en çok gelişmesi gereken alana dikkat çek.
''';

    try {
      return await _callAPI(prompt) ?? '🌟 Harika ilerliyorsun! Devam et!';
    } catch (e) {
      return '🌟 Harika ilerliyorsun! Devam et!';
    }
  }

  // ============================================================
  // MODÜL 8: EĞLENCELİ ÖĞRETİM MOTORU - Hikaye modu
  // ============================================================
  Future<String> generateStoryIntro(String topic) async {
    final prompt = '''
"$topic" konusunu öğretmek için eğlenceli ve merak uyandıran bir hikaye girişi yaz.
Sanki bir RPG oyununun başlangıcı gibi olsun. Maksimum 3 cümle. Emoji kullan. Türkçe.
Öğrenciyi bu maceraya davet et!
''';

    try {
      return await _callAPI(prompt) ?? '🎮 Yeni bir macera başlıyor!';
    } catch (e) {
      return '🎮 Yeni bir macera başlıyor!';
    }
  }

  // ============================================================
  // TEMEL API ÇAĞRISI
  // ============================================================
  Future<String?> _callAPI(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 1024,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['content'][0]['text'] as String?;
      } else {
        debugPrint('API hatası: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('HTTP hatası: $e');
      return null;
    }
  }
}
