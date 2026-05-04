import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/question_model.dart';
import '../services/student_model_service.dart';

class StudyScreen extends StatefulWidget {
  final Topic topic;

  const StudyScreen({super.key, required this.topic});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  Question? _currentQuestion;
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    _loadDummyQuestion();
  }

  void _loadDummyQuestion() {
    _currentQuestion = Question(
      id: '1',
      topic: widget.topic.id,
      subtopic: '',
      text: '2 + 2 kaçtır?',
      options: ['3', '4', '5', '6'],
      correctIndex: 1,
      explanation: '2 + 2 = 4',
      difficulty: 1,
      examProbability: 0.5,
      emoji: '➕',
      storyContext: '',
    );
  }

  void _answerQuestion(int index) async {
    setState(() {
      selectedIndex = index;
    });

    final isCorrect = index == _currentQuestion!.correctIndex;

    await context.read<StudentModelService>().recordAttempt(
          QuestionAttempt(
            questionId: _currentQuestion!.id,
            topicId: widget.topic.id, // 🔥 DİKKAT: topic değil topicId
            isCorrect: isCorrect,
            timestamp: DateTime.now(), // 🔥 genelde bu da gerekir
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentQuestion == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.topic.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              _currentQuestion!.text,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ...List.generate(_currentQuestion!.options.length, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ElevatedButton(
                  onPressed: selectedIndex == null
                      ? () => _answerQuestion(i)
                      : null,
                  child: Text(_currentQuestion!.options[i]),
                ),
              );
            }),
            const SizedBox(height: 20),
            if (selectedIndex != null)
              Text(
                selectedIndex == _currentQuestion!.correctIndex
                    ? 'Doğru! 🎉'
                    : 'Yanlış 😢\n${_currentQuestion!.explanation}',
              ),
          ],
        ),
      ),
    );
  }
}
