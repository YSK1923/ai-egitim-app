import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/student_model_service.dart';
import 'screens/home_screen.dart';
import 'screens/student_setup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StudentModelService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const RootScreen(),
      ),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await context.read<StudentModelService>().loadStudent();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<StudentModelService>();

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!service.hasStudent) {
      return const StudentSetupScreen();
    }

    return const HomeScreen();
  }
}
