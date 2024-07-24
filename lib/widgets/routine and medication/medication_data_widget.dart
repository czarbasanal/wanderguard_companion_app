import 'package:flutter/material.dart';
import '../../models/medication.model.dart';
import 'alarm_item_widget.dart';

class MedicationData extends StatelessWidget {
  final List<MedicationItem> medicationItems;
  final bool isEditing;
  final Function(MedicationItem?, [int?]) onEditMedication;
  final Function(int) onDeleteMedication;

  MedicationData({
    required this.medicationItems,
    required this.isEditing,
    required this.onEditMedication,
    required this.onDeleteMedication,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...medicationItems.asMap().entries.map((entry) {
          int index = entry.key;
          MedicationItem item = entry.value;
          return AlarmItemWidget(
            title: item.title,
            time: item.time,
            days: item.days,
            isEnabled: item.isEnabled,
            onToggle: (value) {
              item.isEnabled = value;
            },
            onEdit: () => onEditMedication(item, index),
            onDelete: () => onDeleteMedication(index),
          );
        }).toList(),
      ],
    );
  }
}
