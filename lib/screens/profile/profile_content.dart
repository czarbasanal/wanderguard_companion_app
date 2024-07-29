import 'package:flutter/material.dart';
import 'package:wanderguard_companion_app/screens/profile/backup_companion_list.dart';
import '../../controllers/auth_controller.dart';
import 'companion_detail.dart';
import 'profile_screen.dart';

class ProfileContent extends StatelessWidget {
  final bool isEditMode;

  ProfileContent({required this.isEditMode});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CompanionDetail(isEditMode: isEditMode),
          SizedBox(height: 20),
          Section(title: 'Content', items: [
            SectionItem(
                iconPath: 'lib/assets/icons/notification.svg',
                title: 'Notifications'),
            SectionItem(
                iconPath: 'lib/assets/icons/pending.svg', title: 'Pending'),
            SectionItem(
                iconPath: 'lib/assets/icons/patients.svg',
                title: 'Backup Companion',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BackupCompanionList(),
                    ),
                  );
                }),
            SectionItem(
                iconPath: 'lib/assets/icons/logout.svg',
                title: 'Logout',
                onTap: () {
                  AuthController.instance.logout();
                }),
          ]),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
