import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';
import '../../utils/size_config.dart';
import 'profile_content.dart';

class ProfileScreen extends StatefulWidget {
  static const route = '/profile';
  static const name = 'Profile';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditMode = false;
  void toggleEditMode() {
    setState(() {
      isEditMode = !isEditMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: CustomColors.primaryColor,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Profile',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const CircleAvatar(
                    radius: 50,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: toggleEditMode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 161, 159, 159),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    child: Text(
                      isEditMode ? 'Save Profile' : 'Edit Profile',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ProfileContent(isEditMode: isEditMode),
          ],
        ),
      ),
    );
  }
}
