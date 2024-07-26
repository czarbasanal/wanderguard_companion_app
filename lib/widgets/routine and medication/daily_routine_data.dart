import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/daily_routine.model.dart';

class DailyRoutineData extends StatefulWidget {
  final List<TodoItem> todoItems;
  final Function(int) toggleTodoItem;
  final bool isEditing;
  final Function(TodoItem) onEditTask;
  final Function(int) onDeleteTask;

  DailyRoutineData({
    required this.todoItems,
    required this.toggleTodoItem,
    required this.isEditing,
    required this.onEditTask,
    required this.onDeleteTask,
  });

  @override
  _DailyRoutineDataState createState() => _DailyRoutineDataState();
}

class _DailyRoutineDataState extends State<DailyRoutineData> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.todoItems.asMap().entries.map((entry) {
        int index = entry.key;
        TodoItem item = entry.value;
        return Container(
          padding: EdgeInsets.symmetric(vertical: 1.0),
          child: Column(
            children: [
              ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!widget.isEditing)
                      Theme(
                        data: ThemeData(
                          checkboxTheme: CheckboxThemeData(
                            side: MaterialStateBorderSide.resolveWith((states) {
                              return BorderSide(
                                color: Color(0xFF838383),
                                width: 0.8,
                              );
                            }),
                          ),
                        ),
                        child: Checkbox(
                          value: item.isDone,
                          onChanged: (bool? value) {
                            widget.toggleTodoItem(index);
                            setState(() {});
                          },
                        ),
                      ),
                    Expanded(
                      child: Text(
                        item.task,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Color(0xFF838383), // Task text color
                          decoration: item.isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                    if (widget.isEditing)
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_horiz,
                            color: Color(0xFF838383)), // Icon color
                        onSelected: (value) {
                          if (value == 'edit') {
                            widget.onEditTask(item);
                          } else if (value == 'delete') {
                            widget.onDeleteTask(index);
                            setState(() {});
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text(
                              'Edit',
                              style: GoogleFonts.poppins(
                                  color: Color(
                                      0xFF838383)), // Edit menu text color
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Delete',
                              style:
                                  GoogleFonts.poppins(color: Color(0xFF838383)),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Divider(color: Color(0xFF838383), height: 1),
            ],
          ),
        );
      }).toList(),
    );
  }
}
