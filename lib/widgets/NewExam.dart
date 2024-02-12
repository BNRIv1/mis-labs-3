import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewExam extends StatefulWidget {
  final Function addExam;

  const NewExam({super.key, required this.addExam});

  @override
  _NewExamState createState() => _NewExamState();
}

class _NewExamState extends State<NewExam> {
  final _subjectController = TextEditingController();
  DateTime _examDate = DateTime.now();
  TimeOfDay examTime = TimeOfDay.now();

  void _submitData() {
    final enteredSubject = _subjectController.text;

    if (enteredSubject.isEmpty ||
        _examDate == null ||
        examTime == null) {
      return;
    }

    widget.addExam(
        enteredSubject,
        _examDate,
        examTime
    );

    Navigator.of(context).pop();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2025),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _examDate = pickedDate;
      });
    });
  }

  void _presentTimePicker() {
    showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 0, minute: 0))
        .then((pickedTime) {
      if (pickedTime == null) {
        return;
      }
      setState(() {
        examTime = pickedTime;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(labelText: 'Subject Name:'),
              controller: _subjectController,
              onSubmitted: (_) => _submitData(),
            ),
            Container(
              height: 70,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _examDate == null
                          ? 'Please Choose a Date!'
                          : 'Default Date: ${DateFormat.yMd().format(_examDate)}',
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor),
                    onPressed: _presentDatePicker,
                    child: const Text(
                      'Please Choose a Date!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 70,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      examTime == null
                          ? 'Please Choose Time!'
                          : 'Default Time: ${examTime.format(context)}',
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor),
                    onPressed: _presentTimePicker,
                    child: const Text(
                      'Please Choose Time!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).textTheme.labelLarge?.color,
                  backgroundColor: Theme.of(context).secondaryHeaderColor,
                  fixedSize: const Size.fromWidth(50),
                  alignment: Alignment.center
              ),
              onPressed: _submitData,
              child: const Text('+', style: TextStyle(fontWeight: FontWeight.bold),),
            ),
          ],
        ),
      ),
    );
  }
}