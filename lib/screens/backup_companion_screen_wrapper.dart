import 'package:flutter/material.dart';
import 'package:wanderguard_companion_app/screens/notifications/notification_screen.dart';
import 'package:wanderguard_companion_app/screens/patients/patient_list_screen.dart';
import 'package:wanderguard_companion_app/utils/size_config.dart';
import 'package:wanderguard_companion_app/widgets/navbar.dart';
import '../routing/router.dart';
import '../widgets/backup_companion_navbar.dart';
import 'home/backup_companion_home_screen.dart';
import 'home/home_screen.dart';
import 'notifications/backup_companion_notification_screen.dart';
import 'profile/backup_companion_profile_screen.dart';
import 'profile/profile_screen.dart';

class BackupCompanionScreenWrapper extends StatefulWidget {
  final Widget? child;
  final ValueNotifier<int> selectedIndexNotifier;

  const BackupCompanionScreenWrapper(
      {super.key, this.child, required this.selectedIndexNotifier});

  @override
  State<BackupCompanionScreenWrapper> createState() =>
      _BackupCompanionScreenWrapperState();
}

class _BackupCompanionScreenWrapperState
    extends State<BackupCompanionScreenWrapper> {
  List<String> routes = [
    BackupCompanionHomeScreen.route,
    BackupCompanionNotificationScreen.route,
    BackupCompanionProfileScreen.route,
  ];

  void _onItemTapped(int i) {
    if (i < 0 || i >= routes.length) return;
    widget.selectedIndexNotifier.value = i;
    GlobalRouter.I.router.go(routes[i]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(child: widget.child ?? const Placeholder()),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: widget.selectedIndexNotifier,
        builder: (context, index, child) {
          return BackupCompanionCustomBottomNavBar(
            iconGap: SizeConfig.screenWidth * 0.16,
            height: 65.0,
            onTap: _onItemTapped,
            selectedIndex: index,
          );
        },
      ),
    );
  }
}
