import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/student_model_service.dart';
import 'home_screen.dart';

class GradeSelectionScreen extends StatelessWidget {
  const GradeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final grades = List.generate(8, (i) => i + 5);

    return Scaffold(
      backgroundColor: const Color(0xFFF0EFFE),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🎓 Hangi sınıftasın?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: grades.map((grade) {
                  return ElevatedButton(
                    onPressed: () async {
                      await context
                          .read<StudentModelService>()
                          .setGrade(grade);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      '$grade. sınıf',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
