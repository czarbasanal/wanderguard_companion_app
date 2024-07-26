import 'package:flutter/material.dart';

class MedicationItem {
  String title;
  TimeOfDay time;
  List<bool> days;
  bool isEnabled;

  MedicationItem({
    required this.title,
    required this.time,
    required this.days,
    this.isEnabled = true,
  });
}
