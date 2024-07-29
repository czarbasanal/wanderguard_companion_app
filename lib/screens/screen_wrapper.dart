import 'package:flutter/material.dart';
import 'package:wanderguard_companion_app/screens/notifications/notification_screen.dart';
import 'package:wanderguard_companion_app/screens/patients/patient_list_screen.dart';
import 'package:wanderguard_companion_app/utils/size_config.dart';
import 'package:wanderguard_companion_app/widgets/navbar.dart';
import '../routing/router.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';

class ScreenWrapper extends StatefulWidget {
  final Widget? child;
  const ScreenWrapper({super.key, this.child});

  @override
  State<ScreenWrapper> createState() => _ScreenWrapperState();
}

class _ScreenWrapperState extends State<ScreenWrapper> {
  int index = 0;

  List<String> routes = [
    HomeScreen.route,
    PatientListScreen.route,
    NotificationScreen.route,
    ProfileScreen.route
  ];

  void _onItemTapped(int i) {
    setState(() {
      index = i;
      GlobalRouter.I.router.go(routes[i]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(child: widget.child ?? const Placeholder()),
      bottomNavigationBar: CustomBottomNavBar(
        iconGap: SizeConfig.screenWidth * 0.16,
        height: 65.0,
        onTap: _onItemTapped,
        selectedIndex: index,
      ),
    );
  }
}
