class QuestionAttempt {
  final String questionId;
  final String topic;
  final bool isCorrect;

  QuestionAttempt({
    required this.questionId,
    required this.topic,
    required this.isCorrect,
  });
}

class StudentModel {
  String id;
  String name;

  int xp;
  int totalAttempts;
  int totalCorrect;

  Map<String, double> topicMastery;

  StudentModel({
    required this.id,
    required this.name,
    this.xp = 0,
    this.totalAttempts = 0,
    this.totalCorrect = 0,
    Map<String, double>? topicMastery,
  }) : topicMastery = topicMastery ?? {};

  void recordAttempt(QuestionAttempt attempt) {
    totalAttempts++;

    if (attempt.isCorrect) {
      totalCorrect++;
    }

    final current = topicMastery[attempt.topic] ?? 0.0;

    if (attempt.isCorrect) {
      topicMastery[attempt.topic] = (current + 0.1).clamp(0.0, 1.0);
      xp += 10;
    } else {
      topicMastery[attempt.topic] = (current - 0.05).clamp(0.0, 1.0);
    }
  }
}
