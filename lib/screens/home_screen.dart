import 'package:flutter/material.dart';
import 'topic_selection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Öğretmenim'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TopicSelectionScreen(),
              ),
            );
          },
          child: const Text('Çalışmaya Başla 🚀'),
        ),
      ),
    );
  }
}
