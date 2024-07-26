import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AlarmItemWidget extends StatelessWidget {
  final String title;
  final TimeOfDay time;
  final List<bool> days;
  final bool isEnabled;
  final Function(bool) onToggle;
  final Function() onEdit;
  final Function() onDelete;

  AlarmItemWidget({
    required this.title,
    required this.time,
    required this.days,
    required this.isEnabled,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${time.format(context)}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                ),
              ),
              Row(
                children: ['M', 'T', 'W', 'Th', 'F', 'S', 'S']
                    .asMap()
                    .entries
                    .map((entry) {
                  int idx = entry.key;
                  String day = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Text(
                      day,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        color: days[idx] ? Colors.black : Colors.grey,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          trailing: Switch(
            value: isEnabled,
            onChanged: onToggle,
            activeColor: Color(0XFF8048C8),
          ),
          onTap: onEdit,
          onLongPress: onDelete,
        ),
        Divider(),
      ],
    );
  }
}
