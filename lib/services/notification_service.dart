import 'package:awesome_notifications/awesome_notifications.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class NotificationService {
  static Future<void> initialize() async {
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'alert_channel_id',
          channelName: 'Alert Notifications',
          channelDescription: 'This channel is used for alert notifications.',
          defaultColor: Colors.red,
          ledColor: Colors.red,
          importance: NotificationImportance.Max,
          enableVibration: true,
          playSound: true,
          defaultRingtoneType: DefaultRingtoneType.Alarm,
          // onlyAlertOnce: false,
          soundSource: 'resource://raw/alarm_sound',
          vibrationPattern: Int64List.fromList(
              [0, 1000, 500, 1000, 500, 1000, 500, 1000, 500, 1000, 500, 1000]),
        ),
        NotificationChannel(
            channelKey: 'persistent_channel_id',
            channelName: 'Persistent Notifications',
            channelDescription:
                'This channel is used for persistent notifications.',
            defaultColor: Colors.deepPurple,
            ledColor: Colors.blue,
            importance: NotificationImportance.Low),
      ],
      debug: true,
    );
    AwesomeNotifications().setListeners(
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
      onActionReceivedMethod: onActionReceivedMethod,
    );
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // Handle notification creation
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // Handle notification display
  }

  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Handle notification dismissal
    if (receivedAction.id == 0) {
      // This was the geofence alert notification
      print('Geofence alert notification dismissed');
    }
    if (receivedAction.id == 1) {
      // This was the persistent notification
      print('Persistent notification dismissed');
      showPersistentNotification(
        1,
        'WanderGuard Service',
        'Running ${DateTime.now()}',
      );
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Handle notification action
  }
  static Future<void> showAlertNotification(
      int id, String title, String body) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'alert_channel_id',
        title: title,
        body: body,
        icon: 'resource://drawable/logo_purple',
        notificationLayout: NotificationLayout.BigText,
        autoDismissible: false,
        displayOnForeground: true,
        displayOnBackground: true,
        wakeUpScreen: true,
        locked: true,
        ticker: 'WanderGuard Alert',
        progress: null, // No progress bar
        customSound: 'resource://raw/alarm_sound',
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'DISMISS',
          label: 'Dismiss',
          autoDismissible: true,
        ),
      ],
    );
  }

  static Future<void> showPersistentNotification(
      int id, String title, String body) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'persistent_channel_id',
        title: title,
        body: body,
        icon: 'resource://drawable/logo_purple',
        notificationLayout: NotificationLayout.BigText,
        autoDismissible: false,
        displayOnForeground: true,
        displayOnBackground: true,
        wakeUpScreen: true,
        locked: true,
        ticker: 'WanderGuard Alert',
        progress: null, // No progress bar
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'DISMISS',
          label: 'Dismiss',
          autoDismissible: true,
        ),
      ],
    );
  }
}
