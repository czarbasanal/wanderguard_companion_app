import 'package:flutter/material.dart';
import 'package:wanderguard_companion_app/models/backup_companion.model.dart';
import 'package:wanderguard_companion_app/routing/router.dart';
import 'package:wanderguard_companion_app/screens/profile/backup_companions/backup_list_screen.dart';
import 'package:wanderguard_companion_app/widgets/section.dart';
import 'package:wanderguard_companion_app/widgets/section_item.dart';
import '../controllers/auth_controller.dart';
import 'backup_companion_detail.dart';

class BackupCompanionProfileContent extends StatelessWidget {
  final BackupCompanion backupCompanion;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneNumberController;
  final TextEditingController emailController;
  final TextEditingController addressController;

  BackupCompanionProfileContent({
    required this.backupCompanion,
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
          BackupCompanionDetail(
            backupCompanion: backupCompanion,
            firstNameController: firstNameController,
            lastNameController: lastNameController,
            phoneNumberController: phoneNumberController,
            emailController: emailController,
            addressController: addressController,
          ),
          const SizedBox(height: 20),
          Section(title: 'Others', items: [
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
