import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/ai_service.dart';
import 'services/student_model_service.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StudentModelService()),
        ChangeNotifierProvider(create: (_) => AIService()),
      ],
      child: const AIEgitimApp(),
    ),
  );
}

class AIEgitimApp extends StatelessWidget {
  const AIEgitimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Öğretmenim',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,

      ),
      home: const HomeScreen(),
    );
  }
}
