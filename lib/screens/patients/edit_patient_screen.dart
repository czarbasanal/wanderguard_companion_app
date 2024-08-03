import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wanderguard_companion_app/models/patient.model.dart';
import 'package:wanderguard_companion_app/routing/router.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';
import 'package:wanderguard_companion_app/widgets/dialogs/waiting_dialog.dart';
import 'package:wanderguard_companion_app/controllers/patient_data_controller.dart';

class EditPatientScreen extends StatefulWidget {
  const EditPatientScreen({Key? key, required this.patient}) : super(key: key);

  final Patient patient;

  static const route = '/edit_patient';
  static const name = 'Edit Patient';

  @override
  _EditPatientScreenState createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends State<EditPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _homeAddressController;
  late TextEditingController _contactNoController;
  DateTime? _selectedDateOfBirth;
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();
  Patient? patient;

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.patient.firstName);
    _lastNameController = TextEditingController(text: widget.patient.lastName);
    _selectedDateOfBirth = widget.patient.dateOfBirth;
    _dateOfBirthController = TextEditingController(
        text: _selectedDateOfBirth!.toLocal().toString().split(' ')[0]);
    _homeAddressController =
        TextEditingController(text: widget.patient.homeAddress);
    _contactNoController =
        TextEditingController(text: widget.patient.contactNo);
    patient = widget.patient;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    _homeAddressController.dispose();
    _contactNoController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: CustomColors.primaryColor),
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: CustomColors.primaryColor),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: CustomColors.primaryColor),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
    );
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: CustomColors.primaryColor,
            colorScheme: ColorScheme.light(primary: CustomColors.primaryColor),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
        _dateOfBirthController.text =
            _selectedDateOfBirth!.toLocal().toString().split(' ')[0];
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      _uploadImage(pickedFile);
    }
  }

  Future<void> _uploadImage(XFile pickedFile) async {
    setState(() {
      isLoading = true;
    });

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('patient_photos')
          .child('${patient!.patientAcctId}.jpg');
      await ref.putFile(File(pickedFile.path));
      final url = await ref.getDownloadURL();

      final updatedPatient = patient!.copyWith(photoUrl: url);
      await PatientDataController.instance.updatePatient(updatedPatient);

      setState(() {
        patient = updatedPatient;
      });
    } catch (error) {
      print('Error uploading image: $error');
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WaitingDialog(
          prompt: 'Saving...',
          color: CustomColors.secondaryColor,
        ),
      );

      try {
        Patient updatedPatient = widget.patient.copyWith(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          dateOfBirth: _selectedDateOfBirth!,
          homeAddress: _homeAddressController.text,
          contactNo: _contactNoController.text,
        );

        await PatientDataController.instance.updatePatient(updatedPatient);

        context.pop();
        context.pop(true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Patient updated successfully')),
        );
      } catch (e) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update patient: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: CustomColors.tertiaryColor,
        body: Center(
          child: WaitingDialog(
            prompt: 'Loading...',
            color: CustomColors.primaryColor,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: CustomColors.tertiaryColor,
      appBar: AppBar(
        backgroundColor: CustomColors.tertiaryColor,
        surfaceTintColor: CustomColors.tertiaryColor,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Edit Patient',
            style: TextStyle(fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            size: 20,
          ),
          onPressed: () {
            GlobalRouter.I.router.pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: CustomColors.primaryColor,
                        width: 4.0,
                      ),
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: patient!.photoUrl,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 150,
                          height: 150,
                          color: CustomColors.primaryColor,
                          child: Center(
                            child: WaitingDialog(
                              color: CustomColors.primaryColor,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: CustomColors.tertiaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            'lib/assets/images/profile-placeholder.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          cursorColor:
                              CustomColors.primaryColor.withOpacity(0.75),
                          cursorErrorColor: Colors.red,
                          controller: _firstNameController,
                          decoration: _inputDecoration('First Name'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the first name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          cursorColor:
                              CustomColors.primaryColor.withOpacity(0.75),
                          cursorErrorColor: Colors.red,
                          controller: _lastNameController,
                          decoration: _inputDecoration('Last Name'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the last name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => _selectDateOfBirth(context),
                          child: AbsorbPointer(
                            child: TextFormField(
                              cursorColor:
                                  CustomColors.primaryColor.withOpacity(0.75),
                              cursorErrorColor: Colors.red,
                              controller: _dateOfBirthController,
                              decoration: _inputDecoration('Date of Birth'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the date of birth';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          cursorColor:
                              CustomColors.primaryColor.withOpacity(0.75),
                          cursorErrorColor: Colors.red,
                          controller: _homeAddressController,
                          decoration: _inputDecoration('Home Address'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the home address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          cursorColor:
                              CustomColors.primaryColor.withOpacity(0.75),
                          cursorErrorColor: Colors.red,
                          controller: _contactNoController,
                          decoration: _inputDecoration('Contact No'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the contact number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textColor: CustomColors.secondaryColor,
                          color: CustomColors.primaryColor,
                          minWidth: double.infinity,
                          height: 50,
                          onPressed: _saveChanges,
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 110,
                right: 130,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: CustomColors.tertiaryColor,
                      shape: BoxShape.circle),
                  child: IconButton(
                    onPressed: () => _showImageSourceActionSheet(context),
                    icon: const Icon(
                      CupertinoIcons.photo_camera_solid,
                      size: 24,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text('Choose an image source'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              _pickImage(ImageSource.camera);
            },
            child: Text('Camera',
                style: TextStyle(color: CustomColors.primaryColor)),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              _pickImage(ImageSource.gallery);
            },
            child: Text('Gallery',
                style: TextStyle(color: CustomColors.primaryColor)),
          ),
        ],
      ),
    );
  }
}
