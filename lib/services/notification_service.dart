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
            importance: NotificationImportance.Max),
      ],
      debug: true,
    );
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
