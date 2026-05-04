import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/student_model_service.dart';
import 'home_screen.dart';

class StudentSetupScreen extends StatefulWidget {
  const StudentSetupScreen({super.key});

  @override
  State<StudentSetupScreen> createState() => _StudentSetupScreenState();
}

class _StudentSetupScreenState extends State<StudentSetupScreen> {
  final TextEditingController _controller = TextEditingController();
  int selectedGrade = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seni Tanıyalım 🎯')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Adın',
              ),
            ),
            const SizedBox(height: 20),

            DropdownButton<int>(
              value: selectedGrade,
              items: List.generate(8, (i) => i + 1)
                  .map((grade) => DropdownMenuItem(
                        value: grade,
                        child: Text('$grade. sınıf'),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedGrade = val!;
                });
              },
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () async {
                if (_controller.text.isEmpty) return;

                await context
                    .read<StudentModelService>()
                    .createStudent(_controller.text, selectedGrade);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomeScreen(),
                  ),
                );
              },
              child: const Text('Başla 🚀'),
            )
          ],
        ),
      ),
    );
  }
}
