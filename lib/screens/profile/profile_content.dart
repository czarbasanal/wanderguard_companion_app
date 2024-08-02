import 'package:flutter/material.dart';
import 'package:wanderguard_companion_app/models/companion.model.dart';
import 'package:wanderguard_companion_app/widgets/section.dart';
import 'package:wanderguard_companion_app/widgets/section_item.dart';
import '../../controllers/auth_controller.dart';
import 'companion_detail.dart';

class ProfileContent extends StatelessWidget {
  final Companion companion;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneNumberController;
  final TextEditingController emailController;
  final TextEditingController addressController;

  ProfileContent({
    required this.companion,
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneNumberController,
    required this.emailController,
    required this.addressController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CompanionDetail(
            companion: companion,
            firstNameController: firstNameController,
            lastNameController: lastNameController,
            phoneNumberController: phoneNumberController,
            emailController: emailController,
            addressController: addressController,
          ),
          const SizedBox(height: 20),
          Section(title: 'Others', items: [
            SectionItem(
                leadingIcon: 'lib/assets/icons/transfer-patient.svg',
                title: 'Patient Transfers',
                trailingIcon: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF313131),
                )),
            SectionItem(
                leadingIcon: 'lib/assets/icons/patients.svg',
                title: 'Backup Companions',
                trailingIcon: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF313131),
                )),
            SectionItem(
                leadingIcon: 'lib/assets/icons/logout.svg',
                title: 'Logout',
                trailingIcon: null,
                onTap: () {
                  AuthController.instance.logout();
                }),
          ]),
        ],
      ),
    );
  }
}
