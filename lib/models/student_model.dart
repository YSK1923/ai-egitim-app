class StudentModel {
  String id;
  String name;
  int xp;
  int level;
  int streak;
  DateTime lastActive;

  int totalAttempts;
  int totalCorrect;

  Map<String, double> topicMastery;

  StudentModel({
    required this.id,
    required this.name,
    this.xp = 0,
    this.level = 1,
    this.streak = 0,
    DateTime? lastActive,
    this.totalAttempts = 0,
    this.totalCorrect = 0,
    Map<String, double>? topicMastery,
  })  : lastActive = lastActive ?? DateTime.now(),
        topicMastery = topicMastery ?? {};

  void addXP(int amount) {
    xp += amount;
    level = (xp / 100).floor() + 1;
  }

  double get successRate {
    if (totalAttempts == 0) return 0;
    return totalCorrect / totalAttempts;
  }

  String get levelTitle {
    if (level < 5) return "Başlangıç";
    if (level < 10) return "Gelişiyor";
    if (level < 20) return "İyi";
    return "Usta";
  }
}

class QuestionAttempt {
  final String questionId;
  final String topicId;
  final bool isCorrect;
  final DateTime timestamp;

  QuestionAttempt({
    required this.questionId,
    required this.topicId,
    required this.isCorrect,
    required this.timestamp,
  });
}
