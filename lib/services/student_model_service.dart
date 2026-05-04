import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student_model.dart';

class StudentModelService extends ChangeNotifier {
  StudentModel? _student;

  StudentModel? get student => _student;

  Future<void> loadStudent() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('student');

    if (json != null) {
      _student = StudentModel.fromJson(jsonDecode(json));
      notifyListeners();
    }
  }

  Future<void> createStudent(String name, int grade) async {
    _student = StudentModel(name: name, grade: grade);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('student', jsonEncode(_student!.toJson()));

    notifyListeners();
  }
}
