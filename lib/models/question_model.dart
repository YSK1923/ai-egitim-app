class Question {
  final String id;
  final String topic;
  final String subtopic;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final int difficulty; // 1-5
  final double examProbability; // çıkma ihtimali 0.0-1.0
  final String emoji;
  final String storyContext; // hikaye bağlamı

  Question({
    required this.id,
    required this.topic,
    required this.subtopic,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.difficulty,
    required this.examProbability,
    required this.emoji,
    required this.storyContext,
  });

  String get correctAnswer => options[correctIndex];

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json['id'] ?? DateTime.now().toString(),
        topic: json['topic'] ?? '',
        subtopic: json['subtopic'] ?? '',
        text: json['text'] ?? '',
        options: List<String>.from(json['options'] ?? []),
        correctIndex: json['correctIndex'] ?? 0,
        explanation: json['explanation'] ?? '',
        difficulty: json['difficulty'] ?? 1,
        examProbability: (json['examProbability'] ?? 0.5).toDouble(),
        emoji: json['emoji'] ?? '📚',
        storyContext: json['storyContext'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'topic': topic,
        'subtopic': subtopic,
        'text': text,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
        'difficulty': difficulty,
        'examProbability': examProbability,
        'emoji': emoji,
        'storyContext': storyContext,
      };
}

class Topic {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final List<String> subtopics;
  final int totalQuestions;

  Topic({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.subtopics,
    required this.totalQuestions,
  });
}

// Örnek konular
final List<Topic> defaultTopics = [
  Topic(
    id: 'matematik',
    name: 'Matematik',
    emoji: '🔢',
    description: 'Sayılar, cebir, geometri ve daha fazlası',
    subtopics: ['Cebir', 'Geometri', 'Sayılar', 'İstatistik', 'Olasılık'],
    totalQuestions: 500,
  ),
  Topic(
    id: 'turkce',
    name: 'Türkçe',
    emoji: '📖',
    description: 'Dil bilgisi, okuma ve yazma becerileri',
    subtopics: ['Dil Bilgisi', 'Okuma', 'Yazım', 'Anlam Bilgisi'],
    totalQuestions: 400,
  ),
  Topic(
    id: 'fen',
    name: 'Fen Bilimleri',
    emoji: '🔬',
    description: 'Fizik, kimya ve biyoloji',
    subtopics: ['Fizik', 'Kimya', 'Biyoloji', 'Dünya Bilimi'],
    totalQuestions: 450,
  ),
  Topic(
    id: 'sosyal',
    name: 'Sosyal Bilgiler',
    emoji: '🌍',
    description: 'Tarih, coğrafya ve vatandaşlık',
    subtopics: ['Tarih', 'Coğrafya', 'Vatandaşlık'],
    totalQuestions: 350,
  ),
  Topic(
    id: 'ingilizce',
    name: 'İngilizce',
    emoji: '🇬🇧',
    description: 'Grammar, vocabulary and reading',
    subtopics: ['Grammar', 'Vocabulary', 'Reading', 'Writing'],
    totalQuestions: 400,
  ),
];

class AIResponse {
  final String explanation;
  final String alternativeExplanation;
  final String storyMode;
  final String encouragement;
  final List<String> hints;
  final int suggestedXP;

  AIResponse({
    required this.explanation,
    required this.alternativeExplanation,
    required this.storyMode,
    required this.encouragement,
    required this.hints,
    required this.suggestedXP,
  });

  factory AIResponse.fromJson(Map<String, dynamic> json) => AIResponse(
        explanation: json['explanation'] ?? '',
        alternativeExplanation: json['alternativeExplanation'] ?? '',
        storyMode: json['storyMode'] ?? '',
        encouragement: json['encouragement'] ?? '',
        hints: List<String>.from(json['hints'] ?? []),
        suggestedXP: json['suggestedXP'] ?? 10,
      );
}
