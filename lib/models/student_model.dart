class StudentModel {
  final String id;
  String name;
  int xp;
  int level;
  int streak;
  DateTime lastActive;

  // 🔥 Öğrenme verileri
  Map<String, double> topicMastery;

  StudentModel({
    required this.id,
    this.name = 'Öğrenci',
    this.xp = 0,
    this.level = 1,
    this.streak = 0,
    DateTime? lastActive,
    Map<String, double>? topicMastery,
  })  : lastActive = lastActive ?? DateTime.now(),
        topicMastery = topicMastery ?? {};

  // 🔥 Profil ekranı için
  String get levelTitle {
    if (level < 5) return "Başlangıç 🐣";
    if (level < 10) return "Gelişen 🚀";
    if (level < 20) return "Uzman 🎯";
    return "Efsane 🏆";
  }

  // JSON
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] ?? '1',
      name: json['name'] ?? 'Öğrenci',
      xp: json['xp'] ?? 0,
      level: json['level'] ?? 1,
      streak: json['streak'] ?? 0,
      lastActive: DateTime.tryParse(json['lastActive'] ?? '') ?? DateTime.now(),
      topicMastery: Map<String, double>.from(json['topicMastery'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'xp': xp,
        'level': level,
        'streak': streak,
        'lastActive': lastActive.toIso8601String(),
        'topicMastery': topicMastery,
      };
}

////////////////////////////////////////////////////////////////////////////////
// 🔥 SORU DENEME MODELİ
////////////////////////////////////////////////////////////////////////////////

class QuestionAttempt {
  final String questionId;
  final String topicId;
  final bool isCorrect;

  QuestionAttempt({
    required this.questionId,
    required this.topicId,
    required this.isCorrect,
  });
}
