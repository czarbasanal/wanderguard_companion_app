import 'package:flutter/material.dart';
import 'package:wanderguard_companion_app/widgets/section.dart';
import 'package:wanderguard_companion_app/widgets/section_item.dart';
import '../../controllers/auth_controller.dart';
import 'companion_detail.dart';

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
          const SizedBox(height: 20),
          Section(title: 'Content', items: [
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
