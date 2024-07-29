import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BackupCompanionList extends StatefulWidget {
  @override
  _BackupCompanionListState createState() => _BackupCompanionListState();
}

class _BackupCompanionListState extends State<BackupCompanionList> {
  List<Map<String, dynamic>> companions = [];

  void _addCompanion(
      String name, String phone, String address, ImageProvider<Object>? image) {
    setState(() {
      companions.add({
        'name': name,
        'phone': phone,
        'address': address,
        'image': image,
      });
    });
  }

  void _showAddCompanionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddCompanionDialog(onSave: _addCompanion);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Backup Companions',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddCompanionDialog,
          ),
        ],
      ),
      body: companions.isEmpty
          ? Center(
              child: Text(
                'No Backup Companions',
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: companions.length,
              itemBuilder: (context, index) {
                final companion = companions[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: Container(
                    height: 140, // Increased height
                    padding: EdgeInsets.all(15), // Increased padding
                    child: Row(
                      children: [
                        Container(
                          width: 90,
                          height: 90, // Increased width and height
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade300,
                            image: companion['image'] != null
                                ? DecorationImage(
                                    image: companion['image'],
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: companion['image'] == null
                              ? Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                  size: 50,
                                )
                              : null,
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                companion['name'],
                                style: GoogleFonts.poppins(
                                    fontSize: 22, // Increased font size
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Text(
                                companion['phone'],
                                style: GoogleFonts.poppins(
                                    fontSize: 18), // Increased font size
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Address: ${companion['address']}',
                                style: GoogleFonts.poppins(
                                    fontSize: 18), // Increased font size
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class AddCompanionDialog extends StatefulWidget {
  final Function(String, String, String, ImageProvider<Object>?) onSave;

  AddCompanionDialog({required this.onSave});

  @override
  _AddCompanionDialogState createState() => _AddCompanionDialogState();
}

class _AddCompanionDialogState extends State<AddCompanionDialog> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _phone = '';
  String _address = '';
  ImageProvider<Object>? _image;

  void _saveCompanion() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onSave(_name, _phone, _address, _image);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Companion', style: GoogleFonts.poppins()),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
                style: GoogleFonts.poppins(),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Number'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _phone = value!;
                },
                style: GoogleFonts.poppins(),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
                onSaved: (value) {
                  _address = value!;
                },
                style: GoogleFonts.poppins(),
              ),
              SizedBox(height: 20),
              OutlinedButton(
                onPressed: () {
                  // Handle image upload here
                },
                child: Text('Upload Image', style: GoogleFonts.poppins()),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel', style: GoogleFonts.poppins()),
        ),
        TextButton(
          onPressed: _saveCompanion,
          child: Text('Save', style: GoogleFonts.poppins()),
        ),
      ],
    );
  }
}
