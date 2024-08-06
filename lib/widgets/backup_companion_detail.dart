import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wanderguard_companion_app/models/backup_companion.model.dart';
import 'package:wanderguard_companion_app/controllers/backup_companion_data_controller.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';
import 'package:wanderguard_companion_app/widgets/dialogs/waiting_dialog.dart';

class BackupCompanionDetail extends StatefulWidget {
  final BackupCompanion backupCompanion;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneNumberController;
  final TextEditingController emailController;
  final TextEditingController addressController;

  const BackupCompanionDetail({
    required this.backupCompanion,
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneNumberController,
    required this.emailController,
    required this.addressController,
  });

  @override
  _BackupCompanionDetailState createState() => _BackupCompanionDetailState();
}

class _BackupCompanionDetailState extends State<BackupCompanionDetail> {
  bool isEditMode = false;

  void toggleEditMode() async {
    if (isEditMode) {
      saveBackupCompanionData();
    } else {
      setState(() {
        isEditMode = true;
      });
    }
  }

  Future<void> saveBackupCompanionData() async {
    final updatedBackupCompanion = widget.backupCompanion.copyWith(
      firstName: widget.firstNameController.text.trim(),
      lastName: widget.lastNameController.text.trim(),
      contactNo: widget.phoneNumberController.text.trim(),
      email: widget.emailController.text.trim(),
      address: widget.addressController.text.trim(),
    );

    await BackupCompanionDataController.instance
        .updateBackupCompanion(updatedBackupCompanion);
    setState(() {
      isEditMode = false;
    });
  }

  InputDecoration buildInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: CustomColors.primaryColor),
      ),
      border: UnderlineInputBorder(),
      labelStyle: TextStyle(color: CustomColors.primaryColor),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Backup Companion Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF313131),
                ),
              ),
              TextButton(
                  onPressed: () {
                    toggleEditMode();
                  },
                  child: Text(
                    isEditMode ? 'Save' : 'Edit',
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationColor: isEditMode
                            ? CustomColors.primaryColor
                            : Colors.grey,
                        fontSize: 15,
                        color: isEditMode
                            ? CustomColors.primaryColor
                            : Colors.grey),
                  ))
            ],
          ),
          const SizedBox(height: 24),
          isEditMode
              ? BackupCompanionEditForm(
                  firstNameController: widget.firstNameController,
                  lastNameController: widget.lastNameController,
                  contactNoController: widget.phoneNumberController,
                  emailController: widget.emailController,
                  addressController: widget.addressController,
                  buildInputDecoration: buildInputDecoration,
                )
              : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: BackupCompanionDataController.instance
                      .getBackupCompanionStream(
                          widget.backupCompanion.backupCompanionAcctId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return WaitingDialog(
                        prompt: 'Loading...',
                        color: CustomColors.primaryColor,
                      );
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Text('No data available');
                    }

                    final updatedBackupCompanion =
                        BackupCompanion.fromFirestore(snapshot.data!);
                    return BackupCompanionDisplay(
                        backupCompanion: updatedBackupCompanion);
                  },
                ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class BackupCompanionEditForm extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController contactNoController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final InputDecoration Function(String) buildInputDecoration;

  const BackupCompanionEditForm({
    required this.firstNameController,
    required this.lastNameController,
    required this.contactNoController,
    required this.emailController,
    required this.addressController,
    required this.buildInputDecoration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: firstNameController,
          decoration: buildInputDecoration('First Name'),
          cursorColor: CustomColors.primaryColor,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: lastNameController,
          decoration: buildInputDecoration('Last Name'),
          cursorColor: CustomColors.primaryColor,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: contactNoController,
          decoration: buildInputDecoration('Contact No'),
          cursorColor: CustomColors.primaryColor,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: emailController,
          decoration: buildInputDecoration('Email'),
          cursorColor: CustomColors.primaryColor,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: addressController,
          decoration: buildInputDecoration('Address'),
          cursorColor: CustomColors.primaryColor,
        ),
      ],
    );
  }
}

class BackupCompanionDisplay extends StatelessWidget {
  final BackupCompanion backupCompanion;

  const BackupCompanionDisplay({required this.backupCompanion});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'Name: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF313131),
                ),
              ),
              TextSpan(
                  text:
                      '${backupCompanion.firstName} ${backupCompanion.lastName}'),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'Contact No: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF313131),
                ),
              ),
              TextSpan(text: backupCompanion.contactNo),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'Email: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF313131),
                ),
              ),
              TextSpan(text: backupCompanion.email),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'Address: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF313131),
                ),
              ),
              TextSpan(text: backupCompanion.address),
            ],
          ),
        ),
      ],
    );
  }
}
