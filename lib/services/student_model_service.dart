import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student_model.dart';
import '../models/question_model.dart';

class StudentModelService extends ChangeNotifier {
  StudentModel? _student;
  bool _isLoaded = false;

  StudentModel? get student => _student;
  bool get isLoaded => _isLoaded;

  // ============================================================
  // MODÜL 3: ÖĞRENCİ MODELLEMEi
  // ============================================================
  Future<void> loadStudent() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('student');
    if (json != null) {
      _student = StudentModel.fromJson(jsonDecode(json));
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> createStudent(String name) async {
    _student = StudentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );
    await _saveStudent();
    notifyListeners();
  }

  Future<void> recordAttempt(QuestionAttempt attempt) async {
    if (_student == null) return;
    _student!.recordAttempt(attempt);

    // XP hesapla
    if (attempt.isCorrect) {
      int xpGain = 20;
      if (attempt.attemptNumber == 1) xpGain = 30; // İlk seferde doğru
      if (attempt.timeSpentSeconds < 30) xpGain += 10; // Hızlı cevap
      _student!.addXP(xpGain);
    }

    await _saveStudent();
    notifyListeners();
  }

  // ============================================================
  // MODÜL 4: SORU ÖNCELİKLENDİRME
  // ============================================================
  String? getNextRecommendedTopic() {
    if (_student == null) return null;

    // En düşük hakimiyet oranına sahip konuyu önceliklendir
    if (_student!.topicMastery.isEmpty) return 'matematik';

    return _student!.topicMastery.entries
        .reduce((a, b) => a.value < b.value ? a : b)
        .key;
  }

  int getRecommendedDifficulty(String topic) {
    if (_student == null) return 1;
    final mastery = _student!.topicMastery[topic] ?? 0.0;
    // Mastery'ye göre zorluk ayarla
    if (mastery < 0.2) return 1;
    if (mastery < 0.4) return 2;
    if (mastery < 0.6) return 3;
    if (mastery < 0.8) return 4;
    return 5;
  }

  Map<String, dynamic> getStudyStats() {
    if (_student == null) return {};
    return {
      'totalQuestions': _student!.totalAttempts,
      'correctAnswers': _student!.totalCorrect,
      'successRate': _student!.successRate,
      'level': _student!.level,
      'xp': _student!.xp,
      'streak': _student!.streak,
      'strongTopics': _student!.topicMastery.entries
          .where((e) => e.value > 0.7)
          .map((e) => e.key)
          .toList(),
      'weakTopics': _student!.topicMastery.entries
          .where((e) => e.value < 0.3)
          .map((e) => e.key)
          .toList(),
    };
  }

  Future<void> _saveStudent() async {
    if (_student == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('student', jsonEncode(_student!.toJson()));
  }

  Future<void> updateStreak() async {
    if (_student == null) return;
    final lastActive = _student!.lastActive;
    final now = DateTime.now();
    final difference = now.difference(lastActive).inDays;

    if (difference == 1) {
      _student!.streak++;
    } else if (difference > 1) {
      _student!.streak = 0;
    }
    _student!.lastActive = now;
    await _saveStudent();
    notifyListeners();
  }
}
