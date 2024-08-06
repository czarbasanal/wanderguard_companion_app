import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wanderguard_companion_app/firebase_options.dart';
import 'package:wanderguard_companion_app/services/notification_service.dart';
import 'dart:async';

Future<void> startBackgroundService() async {
  FlutterBackgroundService().configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'persistent_channel_id',
      initialNotificationTitle: 'WanderGuard Service',
      initialNotificationContent: 'Service is running',
      foregroundServiceNotificationId: 1,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

void onStart(ServiceInstance service) async {
  NotificationService.showPersistentNotification(
    1,
    'WanderGuard Service',
    'Running ${DateTime.now()}',
  );
  DartPluginRegistrant.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.initialize();

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    NotificationService.showPersistentNotification(
      1,
      'WanderGuard Service',
      'Running ${DateTime.now()}',
    );
  });

  Timer.periodic(const Duration(seconds: 5), (timer) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      listenToPatientGeofenceStatus(user.uid);
    }
  });
}

void listenToPatientGeofenceStatus(String acctId) {
  FirebaseFirestore.instance
      .collection('patients')
      .where('companionAcctId', isEqualTo: acctId)
      .snapshots()
      .listen((snapshot) {
    for (var doc in snapshot.docs) {
      bool isWithinGeofence = doc.data()['isWithinGeofence'] ?? true;
      if (!isWithinGeofence) {
        NotificationService.showAlertNotification(
          doc.id.hashCode,
          'WanderGuard Alert',
          'Patient ${doc.data()['firstName']} ${doc.data()['lastName']} is outside the geofence!',
        );
      }
    }
  });

  FirebaseFirestore.instance
      .collection('backup_companions')
      .where('backupCompanionAcctId', isEqualTo: acctId)
      .snapshots()
      .listen((snapshot) {
    for (var doc in snapshot.docs) {
      String patientAcctId = doc.data()['patientAcctId'];
      FirebaseFirestore.instance
          .collection('patients')
          .doc(patientAcctId)
          .snapshots()
          .listen((patientDoc) {
        if (patientDoc.exists) {
          bool isWithinGeofence =
              patientDoc.data()!['isWithinGeofence'] ?? true;
          if (!isWithinGeofence) {
            NotificationService.showAlertNotification(
              patientDoc.id.hashCode,
              'WanderGuard Alert',
              'Patient ${patientDoc.data()!['firstName']} ${patientDoc.data()!['lastName']} is outside the geofence!',
            );
          }
        }
      });
    }
  });
}

Future<bool> onIosBackground(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  return true;
}
