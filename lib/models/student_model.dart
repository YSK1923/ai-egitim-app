class StudentModel {
  final String name;
  final int grade;

  StudentModel({
    required this.name,
    required this.grade,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'grade': grade,
      };

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      name: json['name'],
      grade: json['grade'],
    );
  }
}
