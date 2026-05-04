import 'package:flutter/material.dart';
import '../models/question_model.dart';

class AIService extends ChangeNotifier {
  bool isLoading = false;

  // 🧠 Hikaye giriş
  Future<String> generateStoryIntro(String topic) async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    isLoading = false;
    notifyListeners();

    return "Yeni bir macera başlıyor 🚀 ($topic)";
  }

  // ❓ Soru üretimi
  Future<Question> generateQuestion({
    required String topic,
    required String subtopic,
    required int difficulty,
    required dynamic student,
  }) async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    isLoading = false;
    notifyListeners();

    return Question(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      topic: topic, // 🔥 zorunlu alan
      text: "2 + 2 kaçtır?",
      options: ["3", "4", "5", "6"],
      correctIndex: 1,
      explanation: "2 + 2 = 4 eder.",
      subtopic: subtopic,
      difficulty: difficulty,
      examProbability: 0.8,
      storyContext: "Bir kahraman 2 elma buldu, sonra 2 tane daha buldu...",
    );
  }

  // 🤖 Yanlış cevap analizi
  Future<AIResponse> analyzeWrongAnswer({
    required Question question,
    required String userAnswer,
    required dynamic student,
    required int attemptNumber,
  }) async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    isLoading = false;
    notifyListeners();

    return AIResponse(
      encouragement: "Biraz daha dikkat etmelisin 💪",
      explanation: "Doğru cevap 4 çünkü 2+2=4",
      alternativeExplanation: "Toplama işlemi yapıyoruz.",
      storyMode: "Kahraman toplamayı öğreniyor...",
    );
  }

  // 📊 Ana sayfa içgörü
  Future<String> generateLearningInsight(dynamic student) async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    isLoading = false;
    notifyListeners();

    return "Bugün harika gidiyorsun! 🔥 En güçlü konun gelişiyor.";
  }
}
