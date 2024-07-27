import 'package:flutter/material.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';

import '../controllers/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  static const route = '/profile';
  static const name = 'Profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile',
            style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24),
          child: MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textColor: CustomColors.secondaryColor,
            color: CustomColors.primaryColor,
            minWidth: double.infinity,
            height: 55,
            onPressed: () {
              AuthController.instance.logout();
            },
            child: const Text(
              'Logout',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
