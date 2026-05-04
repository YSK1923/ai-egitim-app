import 'package:flutter/material.dart';
import '../models/question_model.dart';

class StudyScreen extends StatefulWidget {
  final Topic topic;

  const StudyScreen({super.key, required this.topic});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  Question? _question;
  int? selected;

  @override
  void initState() {
    super.initState();

    _question = Question(
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

  @override
  Widget build(BuildContext context) {
    if (_question == null) {
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
            Text(_question!.text, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ...List.generate(_question!.options.length, (i) {
              return ElevatedButton(
                onPressed: selected == null
                    ? () => setState(() => selected = i)
                    : null,
                child: Text(_question!.options[i]),
              );
            }),
            const SizedBox(height: 20),
            if (selected != null)
              Text(
                selected == _question!.correctIndex
                    ? 'Doğru 🎉'
                    : 'Yanlış\n${_question!.explanation}',
              )
          ],
        ),
      ),
    );
  }
}
