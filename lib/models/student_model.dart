class QuestionAttempt {
  final String questionId;
  final String topic;
  final bool isCorrect;
  final int attemptNumber;
  final int timeSpentSeconds;
  final DateTime timestamp;

  QuestionAttempt({
    required this.questionId,
    required this.topic,
    required this.isCorrect,
    this.attemptNumber = 1,
    this.timeSpentSeconds = 30,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class StudentModel {
  String id;
  String name;
  int grade;

  int xp;
  int level;
  int streak;

  int totalAttempts;
  int totalCorrect;

  DateTime lastActive;

  Map<String, double> topicMastery;

  StudentModel({
    required this.id,
    required this.name,
    required this.grade,
    this.xp = 0,
    this.level = 1,
    this.streak = 0,
    this.totalAttempts = 0,
    this.totalCorrect = 0,
    DateTime? lastActive,
    Map<String, double>? topicMastery,
  })  : lastActive = lastActive ?? DateTime.now(),
        topicMastery = topicMastery ?? {};

  // -----------------------------
  // XP EKLE
  // -----------------------------
  void addXP(int amount) {
    xp += amount;
    level = (xp ~/ 100) + 1;
  }

  // -----------------------------
  // SORU KAYDI
  // -----------------------------
  void recordAttempt(QuestionAttempt attempt) {
    totalAttempts++;

    if (attempt.isCorrect) {
      totalCorrect++;
    }

    final current = topicMastery[attempt.topic] ?? 0.0;

    if (attempt.isCorrect) {
      topicMastery[attempt.topic] = (current + 0.1).clamp(0.0, 1.0);
    } else {
      topicMastery[attempt.topic] = (current - 0.05).clamp(0.0, 1.0);
    }

    lastActive = DateTime.now();
  }

  // -----------------------------
  // BAŞARI ORANI
  // -----------------------------
  double get successRate {
    if (totalAttempts == 0) return 0;
    return totalCorrect / totalAttempts;
  }

  // -----------------------------
  // LEVEL TITLE
  // -----------------------------
  String get levelTitle {
    if (level < 5) return "Acemi";
    if (level < 10) return "Gelişen";
    if (level < 20) return "Usta";
    return "Efsane";
  }

  // -----------------------------
  // JSON
  // -----------------------------
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'],
      name: json['name'],
      grade: json['grade'],
      xp: json['xp'] ?? 0,
      level: json['level'] ?? 1,
      streak: json['streak'] ?? 0,
      totalAttempts: json['totalAttempts'] ?? 0,
      totalCorrect: json['totalCorrect'] ?? 0,
      lastActive: DateTime.parse(json['lastActive']),
      topicMastery:
          Map<String, double>.from(json['topicMastery'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'grade': grade,
      'xp': xp,
      'level': level,
      'streak': streak,
      'totalAttempts': totalAttempts,
      'totalCorrect': totalCorrect,
      'lastActive': lastActive.toIso8601String(),
      'topicMastery': topicMastery,
    };
  }
}
