import 'package:cloud_firestore/cloud_firestore.dart';

class Exam {
  String subjectName;
  DateTime examDate;

  Exam({
    required this.subjectName,
    required this.examDate,
  });

  factory Exam.fromMap(Map<String, dynamic>? map) {
    if (map == null || map['subjectName'] == null || map['examDate'] == null) {
      return Exam(subjectName: 'Default', examDate: DateTime.now());
    }

    return Exam(
      subjectName: map['subjectName'] as String,
      examDate: (map['examDate'] as Timestamp).toDate(),
    );
  }
}