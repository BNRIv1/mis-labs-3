import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lab3_201177/widgets/AuthGate.dart';

import '../domain/Exam.dart';
import '../widgets/NewExam.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CollectionReference _itemsCollection =
      FirebaseFirestore.instance.collection('exams');

  void _addExam() {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: NewExam(
              addExam: _addNewExamToDatabase,
            ),
          );
        });
  }

  void _addNewExamToDatabase(String subject, DateTime date, TimeOfDay time) {
    addExam(subject, date, time);
  }

  Future<void> addExam(String subject, DateTime date, TimeOfDay time) {
    User? user = FirebaseAuth.instance.currentUser;
    DateTime newDate = DateTime(
        date.year, date.month, date.day, time.hour, time.minute, 0, 0, 0);
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('exams')
          .add({'subjectName': subject, 'examDate': newDate, 'userId': user.uid});
    }

    return FirebaseFirestore.instance
        .collection('exams')
        .add({'subjectName': subject, 'examDate': newDate, 'userId': 'invalid'});
  }

  Future<void> _signOutAndNavigateToLogin(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthGate()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Error during sign out: $e');
    }
  }

  void _deleteExam(String subject, DateTime date) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Find the document with matching subject, date, and userId
      var query = _itemsCollection
          .where('subjectName', isEqualTo: subject)
          .where('examDate', isEqualTo: date)
          .where('userId', isEqualTo: user.uid);

      query.get().then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          // Delete the document with the found ID
          _itemsCollection.doc(doc.id).delete();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Exam Scheduler 201177"),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            ElevatedButton(
              onPressed: () => _addExam(),
              style: const ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll<Color>(Colors.blue)),
              child: const Text(
                "Add exam",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () => _signOutAndNavigateToLogin(context),
              style: const ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll<Color>(Colors.greenAccent)),
              child: const Text(
                "Sign out",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: _itemsCollection
                .where('userId',
                    isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              List<Exam> items =
                  snapshot.data!.docs.map((DocumentSnapshot doc) {
                return Exam.fromMap(doc.data() as Map<String, dynamic>);
              }).toList();

              return GridView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  items[index].subjectName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('yyyy-MM-dd kk:mm')
                                      .format(items[index].examDate),
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.black54),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                          top: 5.0,
                          right: 5.0,
                          child: IconButton(
                            icon: const Icon(Icons.delete_forever_rounded),
                            onPressed: () {
                              _deleteExam(items[index].subjectName,
                                  items[index].examDate);
                            },
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
              );
            }));
  }
}
