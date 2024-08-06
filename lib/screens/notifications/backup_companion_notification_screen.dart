import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanderguard_companion_app/services/notification_service.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';

import '../../state/backup_companion_homescreen_state.dart';

class BackupCompanionNotificationScreen extends StatefulWidget {
  const BackupCompanionNotificationScreen({super.key});

  static const route = '/backupcompanionnotification';
  static const name = 'BackupCompanionNotification';

  @override
  State<BackupCompanionNotificationScreen> createState() =>
      BackupCompanionNotificationScreenState();
}

class BackupCompanionNotificationScreenState
    extends State<BackupCompanionNotificationScreen> {
  @override
  Widget build(BuildContext context) {
    final backupCompanionHomeScreenState =
        Provider.of<BackupCompanionHomeScreenState>(context);

    return Scaffold(
      backgroundColor: CustomColors.primaryColor,
      appBar: AppBar(
          title: const Text(
        'Notifications',
        style: TextStyle(fontWeight: FontWeight.bold),
      )),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                NotificationService.showPersistentNotification(
                  0,
                  'WanderGuard Emergency Alert',
                  'Patient has exited geofence!',
                );
              },
              child: const Text('Show Persistent Notification'),
            ),
            ElevatedButton(
              onPressed: () {
                final patient =
                    backupCompanionHomeScreenState.selectedPatient.value;
                if (patient != null && !patient.isWithinGeofence) {
                  NotificationService.showPersistentNotification(
                    1,
                    'Geofence Alert',
                    'Patient ${patient.firstName} ${patient.lastName} is outside the geofence!',
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Patient is within the geofence.'),
                    ),
                  );
                }
              },
              child: const Text('Check Patient Geofence Status'),
            ),
          ],
        ),
      ),
    );
  }
}
