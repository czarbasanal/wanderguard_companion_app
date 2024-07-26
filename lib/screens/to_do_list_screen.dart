import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/daily_routine.model.dart';
import '../models/medication.model.dart';
import '../widgets/navbar.dart';
import '../widgets/routine and medication/daily_routine_data.dart';
import '../widgets/routine and medication/medication_data_widget.dart';

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  DateTime _selectedDate = DateTime.now();
  String _currentTab = 'Daily Routine';
  bool _isEditing = false;

  final Map<String, List<TodoItem>> _todoData = {};
  final List<MedicationItem> _medicationData = [];

  List<TodoItem> get _todoItems {
    String day = DateFormat('EEEE').format(_selectedDate);
    return _todoData[day] ?? [];
  }

  void _toggleTodoItem(int index) {
    setState(() {
      String day = DateFormat('EEEE').format(_selectedDate);
      _todoData[day]![index].isDone = !_todoData[day]![index].isDone;
    });
  }

  void _addTodoItem(String task, DateTime date) {
    setState(() {
      String day = DateFormat('EEEE').format(date);
      _todoData.putIfAbsent(day, () => []);
      _todoData[day]!.add(TodoItem(task: task));
    });
  }

  void _deleteTodoItem(int index) {
    setState(() {
      String day = DateFormat('EEEE').format(_selectedDate);
      _todoData[day]!.removeAt(index);
    });
  }

  void _addMedicationItem(MedicationItem item) {
    setState(() {
      _medicationData.add(item);
    });
  }

  void _deleteMedicationItem(int index) {
    setState(() {
      _medicationData.removeAt(index);
    });
  }

  void _editMedicationItem(int index, MedicationItem newItem) {
    setState(() {
      _medicationData[index] = newItem;
    });
  }

  void _showAddTodoDialog(DateTime date, [TodoItem? itemToEdit]) {
    TextEditingController _taskController = TextEditingController(
      text: itemToEdit?.task ?? '',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            itemToEdit != null ? 'Edit Task' : 'Add New Task',
            style: GoogleFonts.poppins(),
          ),
          content: TextField(
            controller: _taskController,
            decoration: InputDecoration(
              hintText: 'Enter task here',
              border: InputBorder.none,
            ),
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(),
              ),
            ),
            TextButton(
              onPressed: () {
                final taskText = _taskController.text.trim();
                if (taskText.isNotEmpty) {
                  setState(() {
                    if (itemToEdit != null) {
                      itemToEdit.task = taskText;
                    } else {
                      _addTodoItem(taskText, date);
                    }
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text(
                itemToEdit != null ? 'Save' : 'Add',
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddMedicationDialog([MedicationItem? itemToEdit, int? index]) {
    TextEditingController _titleController = TextEditingController(
      text: itemToEdit?.title ?? '',
    );
    List<bool> _selectedDays = itemToEdit?.days ?? List<bool>.filled(7, false);
    TimeOfDay _selectedTime = itemToEdit?.time ?? TimeOfDay.now();
    bool _isEnabled = itemToEdit?.isEnabled ?? true;

    Future<void> _selectTime(BuildContext context, StateSetter setState) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
      );
      if (picked != null && picked != _selectedTime) {
        setState(() {
          _selectedTime = picked;
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(
                itemToEdit != null ? 'Edit Medication' : 'Add New Medication',
                style: GoogleFonts.poppins(),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Enter title',
                      border: InputBorder.none,
                    ),
                    style: GoogleFonts.poppins(),
                  ),
                  ListTile(
                    title: Text(
                      'Time: ${_selectedTime.format(context)}',
                      style: GoogleFonts.poppins(),
                    ),
                    trailing: Icon(Icons.access_time),
                    onTap: () => _selectTime(context, setState),
                  ),
                  Wrap(
                    children: ['M', 'T', 'W', 'Th', 'F', 'S', 'S']
                        .asMap()
                        .entries
                        .map((entry) {
                      int idx = entry.key;
                      String day = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: ChoiceChip(
                          label: Text(day, style: GoogleFonts.poppins()),
                          selected: _selectedDays[idx],
                          onSelected: (bool selected) {
                            setState(() {
                              _selectedDays[idx] = selected;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  SwitchListTile(
                    title: Text('Enabled', style: GoogleFonts.poppins()),
                    value: _isEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _isEnabled = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final title = _titleController.text.trim();
                    if (title.isNotEmpty) {
                      final newItem = MedicationItem(
                        title: title,
                        time: _selectedTime,
                        days: _selectedDays,
                        isEnabled: _isEnabled,
                      );
                      setState(() {
                        if (itemToEdit != null && index != null) {
                          _editMedicationItem(index, newItem);
                        } else {
                          _addMedicationItem(newItem);
                        }
                      });
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    itemToEdit != null ? 'Save' : 'Add',
                    style: GoogleFonts.poppins(),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCustomTodoListDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext, Animation animation,
          Animation secondaryAnimation) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.7,
                    padding: EdgeInsets.all(16.0),
                    color: Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _currentTab = 'Daily Routine';
                                });
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: _currentTab == 'Daily Routine'
                                    ? Color(0XFF8048C8)
                                    : Colors.grey[600],
                                padding: EdgeInsets.zero,
                                minimumSize: Size(50, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                alignment: Alignment.centerLeft,
                              ),
                              child: Text(
                                'Daily Routine',
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                            SizedBox(width: 15),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _currentTab = 'Medication';
                                });
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: _currentTab == 'Medication'
                                    ? Color(0XFF8048C8)
                                    : Colors.grey[600],
                                padding: EdgeInsets.zero,
                                minimumSize: Size(50, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                alignment: Alignment.centerLeft,
                              ),
                              child: Text(
                                'Medication',
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              icon: SvgPicture.asset(
                                _isEditing
                                    ? 'lib/assets/icons/add.svg'
                                    : 'lib/assets/icons/edit.svg',
                              ),
                              onPressed: () {
                                if (_isEditing) {
                                  if (_currentTab == 'Daily Routine') {
                                    _showAddTodoDialog(_selectedDate);
                                  } else {
                                    _showAddMedicationDialog();
                                  }
                                } else {
                                  setState(() {
                                    _isEditing = true;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_left),
                              onPressed: () {
                                setState(() {
                                  _selectedDate =
                                      _selectedDate.subtract(Duration(days: 1));
                                });
                              },
                            ),
                            Text(
                              DateFormat('EEEE')
                                  .format(_selectedDate)
                                  .toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.arrow_right),
                              onPressed: () {
                                setState(() {
                                  _selectedDate =
                                      _selectedDate.add(Duration(days: 1));
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                if (_currentTab == 'Daily Routine')
                                  DailyRoutineData(
                                    todoItems: _todoItems,
                                    toggleTodoItem: _toggleTodoItem,
                                    isEditing: _isEditing,
                                    onEditTask: (item) {
                                      _showAddTodoDialog(_selectedDate, item);
                                    },
                                    onDeleteTask: (index) {
                                      _deleteTodoItem(index);
                                    },
                                  )
                                else
                                  MedicationData(
                                    medicationItems: _medicationData,
                                    isEditing: _isEditing,
                                    onEditMedication: _showAddMedicationDialog,
                                    onDeleteMedication: _deleteMedicationItem,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            if (_isEditing) {
                              setState(() {
                                _isEditing = false;
                              });
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                          child: Text(
                            _isEditing ? 'Save' : 'Close',
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'To-Do List App',
          style: GoogleFonts.poppins(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: _showCustomTodoListDialog,
                child: Text(
                  'To-Do List',
                  style: GoogleFonts.poppins(fontSize: 24, color: Colors.blue),
                ),
              ),
            ),
          ),
          Navbar(),
        ],
      ),
    );
  }
}
