import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/student_model_service.dart';
import 'home_screen.dart';

class GradeSelectionScreen extends StatelessWidget {
  const GradeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EFFE),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
                children: [
                  _gradeButton(context, 5),
                  _gradeButton(context, 6),
                  _gradeButton(context, 7),
                  _gradeButton(context, 8),
                  _gradeButton(context, 9),
                  _gradeButton(context, 10),
                  _gradeButton(context, 11),
                  _gradeButton(context, 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gradeButton(BuildContext context, int grade) {
    return ElevatedButton(
      onPressed: () async {
        await context.read<StudentModelService>().setGrade(grade);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
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
  }
}
