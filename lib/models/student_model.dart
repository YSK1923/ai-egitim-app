class StudentModel {
  final String id;
  String name;
  int xp;
  int level;
  int streak; // consecutive days
  Map<String, double> topicMastery; // topic -> mastery 0.0-1.0
  List<String> completedTopics;
  List<QuestionAttempt> attempts;
  int totalCorrect;
  int totalAttempts;
  DateTime lastActive;

  StudentModel({
    required this.id,
    required this.name,
    this.xp = 0,
    this.level = 1,
    this.streak = 0,
    Map<String, double>? topicMastery,
    List<String>? completedTopics,
    List<QuestionAttempt>? attempts,
    this.totalCorrect = 0,
    this.totalAttempts = 0,
    DateTime? lastActive,
  })  : topicMastery = topicMastery ?? {},
        completedTopics = completedTopics ?? [],
        attempts = attempts ?? [],
        lastActive = lastActive ?? DateTime.now();

  double get successRate =>
      totalAttempts == 0 ? 0 : totalCorrect / totalAttempts;

  int get xpToNextLevel => level * 100;

  String get levelTitle {
    if (level < 3) return '🌱 Acemi Kaşif';
    if (level < 6) return '⭐ Yükselen Yıldız';
    if (level < 10) return '🚀 Bilgi Kâşifi';
    if (level < 15) return '🔥 Deha Aday';
    return '🏆 Süper Deha';
  }

  void addXP(int amount) {
    xp += amount;
    while (xp >= xpToNextLevel) {
      xp -= xpToNextLevel;
      level++;
    }
  }

  void recordAttempt(QuestionAttempt attempt) {
    attempts.add(attempt);
    totalAttempts++;
    if (attempt.isCorrect) totalCorrect++;

    // Update topic mastery
    final topic = attempt.topic;
    final current = topicMastery[topic] ?? 0.0;
    if (attempt.isCorrect) {
      topicMastery[topic] = (current + 0.1).clamp(0.0, 1.0);
    } else {
      topicMastery[topic] = (current - 0.05).clamp(0.0, 1.0);
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'xp': xp,
        'level': level,
        'streak': streak,
        'topicMastery': topicMastery,
        'completedTopics': completedTopics,
        'totalCorrect': totalCorrect,
        'totalAttempts': totalAttempts,
        'lastActive': lastActive.toIso8601String(),
      };

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
        id: json['id'],
        name: json['name'],
        xp: json['xp'] ?? 0,
        level: json['level'] ?? 1,
        streak: json['streak'] ?? 0,
        topicMastery: Map<String, double>.from(json['topicMastery'] ?? {}),
        completedTopics: List<String>.from(json['completedTopics'] ?? []),
        totalCorrect: json['totalCorrect'] ?? 0,
        totalAttempts: json['totalAttempts'] ?? 0,
        lastActive: DateTime.tryParse(json['lastActive'] ?? '') ?? DateTime.now(),
      );
}

class QuestionAttempt {
  final String topic;
  final String question;
  final String userAnswer;
  final bool isCorrect;
  final int attemptNumber; // kaçıncı denemede doğru
  final DateTime timestamp;
  final int timeSpentSeconds;

  QuestionAttempt({
    required this.topic,
    required this.question,
    required this.userAnswer,
    required this.isCorrect,
    required this.attemptNumber,
    required this.timeSpentSeconds,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
