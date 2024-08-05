import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wanderguard_companion_app/firebase_options.dart';
import 'package:wanderguard_companion_app/services/notification_service.dart';
import 'dart:async';

void startBackgroundService() {
  FlutterBackgroundService().configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'persistent_channel_id',
      initialNotificationTitle: 'WanderGuard Service',
      initialNotificationContent: 'Initializing service',
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
  DartPluginRegistrant.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.initialize();

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  NotificationService.showPersistentNotification(
    1,
    'WanderGuard Service',
    'Service is running',
  );

  Timer.periodic(const Duration(seconds: 5), (timer) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      listenToPatientGeofenceStatus(user.uid);
    }
  });
}

void listenToPatientGeofenceStatus(String companionAcctId) {
  FirebaseFirestore.instance
      .collection('patients')
      .where('companionAcctId', isEqualTo: companionAcctId)
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
}

Future<bool> onIosBackground(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  return true;
}
