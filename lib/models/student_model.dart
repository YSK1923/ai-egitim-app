class StudentModel {
  final String name;
  final int xp;
  final int level;
  final int streak;
  final int grade;

  StudentModel({
    required this.name,
    required this.xp,
    required this.level,
    required this.streak,
    required this.grade,
  });

  StudentModel copyWith({
    String? name,
    int? xp,
    int? level,
    int? streak,
    int? grade,
  }) {
    return StudentModel(
      name: name ?? this.name,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      grade: grade ?? this.grade,
    );
  }

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      name: json['name'] ?? '',
      xp: json['xp'] ?? 0,
      level: json['level'] ?? 1,
      streak: json['streak'] ?? 0,
      grade: json['grade'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'xp': xp,
      'level': level,
      'streak': streak,
      'grade': grade,
    };
  }
}
