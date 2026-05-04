import 'package:flutter/material.dart';
import '../models/student_model.dart';

class StudentModelService extends ChangeNotifier {
  StudentModel _student = StudentModel(
    id: '1',
    name: 'Öğrenci',
  );

  StudentModel get student => _student;

  Future<void> recordAttempt(QuestionAttempt attempt) async {
    _student.recordAttempt(attempt);
    notifyListeners();
  }
}
