class StudentModel {
  final String id;
  int xp;
  int level;
  DateTime lastActive;

  // 🔥 EKLENENLER
  Map<String, double> topicMastery;

  StudentModel({
    required this.id,
    this.xp = 0,
    this.level = 1,
    DateTime? lastActive,
    Map<String, double>? topicMastery,
  })  : lastActive = lastActive ?? DateTime.now(),
        topicMastery = topicMastery ?? {};

  // 🔥 LEVEL TITLE (profile_screen hatası çözülür)
  String get levelTitle {
    if (level < 5) return "Başlangıç 🐣";
    if (level < 10) return "Gelişen 🚀";
    if (level < 20) return "Uzman 🎯";
    return "Efsane 🏆";
  }

  // JSON
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'],
      xp: json['xp'] ?? 0,
      level: json['level'] ?? 1,
      lastActive: DateTime.tryParse(json['lastActive'] ?? '') ?? DateTime.now(),
      topicMastery: Map<String, double>.from(json['topicMastery'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'xp': xp,
        'level': level,
        'lastActive': lastActive.toIso8601String(),
        'topicMastery': topicMastery,
      };
}

////////////////////////////////////////////////////////////////////////////////
// 🔥 YENİ CLASS (HATA BURADAN GELİYORDU)
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
