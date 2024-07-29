import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/size_config.dart';
import '../../widgets/navbar.dart';
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
              color: Color(0XFF8048C8),
              child: Column(
                children: [
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      Text(
                        'Profile',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 48),
                    ],
                  ),
                  SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: toggleEditMode,
                    child: Text(
                      isEditMode ? 'Save Profile' : 'Edit Profile',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 161, 159, 159),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            SizedBox(height: 20),
            ProfileContent(isEditMode: isEditMode),
          ],
        ),
      ),
    );
  }
}

class Section extends StatelessWidget {
  final String title;
  final List<SectionItem> items;

  Section({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF313131),
            )),
        SizedBox(height: 10),
        ...items
            .map((item) => ListTile(
                  leading: SvgPicture.asset(
                    item.iconPath,
                    width: 24,
                    height: 24,
                    color: Color(0xFF313131),
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(color: Color(0xFF313131)),
                  ),
                  trailing:
                      Icon(Icons.arrow_forward_ios, color: Color(0xFF313131)),
                  onTap: item.onTap,
                ))
            .toList(),
      ],
    );
  }
}

class SectionItem {
  final String title;
  final String iconPath;
  final VoidCallback? onTap;

  SectionItem({required this.iconPath, required this.title, this.onTap});
}

void main() {
  runApp(MaterialApp(
    home: ProfileScreen(),
  ));
}
