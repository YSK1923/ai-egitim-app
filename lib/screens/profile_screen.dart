import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/student_model_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final student = context.watch<StudentModelService>().student;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person)),
            const SizedBox(height: 10),
            Text(student.name, style: const TextStyle(fontSize: 20)),

            const SizedBox(height: 20),

            _stat('XP', '${student.xp}'),
            _stat('Toplam Soru', '${student.totalAttempts}'),
            _stat('Doğru Sayısı', '${student.totalCorrect}'),

            const SizedBox(height: 20),

            Text(
              'Başarı Oranı: ${(student.totalAttempts == 0 ? 0 : (student.totalCorrect / student.totalAttempts * 100)).toStringAsFixed(1)}%',
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value),
        ],
      ),
    );
  }
}
