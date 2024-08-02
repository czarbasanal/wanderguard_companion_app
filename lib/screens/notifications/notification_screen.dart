import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanderguard_companion_app/services/notification_service.dart';
import 'package:wanderguard_companion_app/state/homescreen_state.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  static const route = '/notification';
  static const name = 'Notification';

  @override
  State<NotificationScreen> createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    final homeScreenState = Provider.of<HomeScreenState>(context);

    return Scaffold(
      backgroundColor: CustomColors.tertiaryColor,
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
                final patient = homeScreenState.selectedPatient.value;
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
