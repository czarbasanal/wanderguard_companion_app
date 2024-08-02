import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wanderguard_companion_app/models/companion.model.dart';
import 'package:wanderguard_companion_app/controllers/companion_data_controller.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';
import 'package:wanderguard_companion_app/widgets/dialogs/waiting_dialog.dart';

class CompanionDetail extends StatefulWidget {
  final Companion companion;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneNumberController;
  final TextEditingController emailController;
  final TextEditingController addressController;

  const CompanionDetail({
    required this.companion,
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneNumberController,
    required this.emailController,
    required this.addressController,
  });

  @override
  _CompanionDetailState createState() => _CompanionDetailState();
}

class _CompanionDetailState extends State<CompanionDetail> {
  bool isEditMode = false;

  void toggleEditMode() async {
    if (isEditMode) {
      saveCompanionData();
    } else {
      setState(() {
        isEditMode = true;
      });
    }
  }

  Future<void> saveCompanionData() async {
    final updatedCompanion = widget.companion.copyWith(
      firstName: widget.firstNameController.text.trim(),
      lastName: widget.lastNameController.text.trim(),
      contactNo: widget.phoneNumberController.text.trim(),
      email: widget.emailController.text.trim(),
      address: widget.addressController.text.trim(),
    );

    await CompanionDataController.instance.updateCompanion(updatedCompanion);
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
                'Companion Details',
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
              ? CompanionEditForm(
                  firstNameController: widget.firstNameController,
                  lastNameController: widget.lastNameController,
                  contactNoController: widget.phoneNumberController,
                  emailController: widget.emailController,
                  addressController: widget.addressController,
                  buildInputDecoration: buildInputDecoration,
                )
              : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: CompanionDataController.instance
                      .getCompanionStream(widget.companion.companionAcctId),
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

                    final updatedCompanion =
                        Companion.fromFirestore(snapshot.data!);
                    return CompanionDisplay(companion: updatedCompanion);
                  },
                ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class CompanionEditForm extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController contactNoController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final InputDecoration Function(String) buildInputDecoration;

  const CompanionEditForm({
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

class CompanionDisplay extends StatelessWidget {
  final Companion companion;

  const CompanionDisplay({required this.companion});

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
              TextSpan(text: '${companion.firstName} ${companion.lastName}'),
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
              TextSpan(text: companion.contactNo),
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
              TextSpan(text: companion.email),
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
              TextSpan(text: companion.address),
            ],
          ),
        ),
      ],
    );
  }
}
