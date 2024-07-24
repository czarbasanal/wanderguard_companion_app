import 'package:flutter/material.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  static const route = '/patients';
  static const name = 'Patients';

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Patients',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.add_rounded,
                size: 30,
              ))
        ],
      ),
      body: const Center(child: Placeholder()),
    );
  }
}
