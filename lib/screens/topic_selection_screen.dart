import 'package:flutter/material.dart';
import '../models/question_model.dart';
import 'study_screen.dart';

class TopicSelectionScreen extends StatelessWidget {
  const TopicSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konu Seç')),
      body: ListView.builder(
        itemCount: defaultTopics.length,
        itemBuilder: (context, index) {
          final topic = defaultTopics[index];

          return ListTile(
            title: Text(topic.name),
            leading: Text(topic.emoji),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StudyScreen(topic: topic),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
