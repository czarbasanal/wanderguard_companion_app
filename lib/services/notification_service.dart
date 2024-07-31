import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dynamic_multi_step_form/dynamic_multi_step_form.dart';
import 'dart:typed_data';

class NotificationService {
  static Future<void> initialize() async {
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'persistent_channel_id',
          channelName: 'Persistent Notifications',
          channelDescription:
              'This channel is used for persistent notifications.',
          defaultColor: Colors.red,
          ledColor: Colors.red,
          importance: NotificationImportance.Max,
          enableVibration: true,
          playSound: true,
          defaultRingtoneType: DefaultRingtoneType.Alarm,
          soundSource: 'resource://raw/alarm_sound',
          vibrationPattern: Int64List.fromList(
              [0, 1000, 500, 1000, 500, 1000, 500, 1000, 500, 1000, 500, 1000]),
        ),
      ],
      debug: true,
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
        notificationLayout: NotificationLayout.Default,
        autoDismissible: false,
        displayOnForeground: true,
        displayOnBackground: true,
        wakeUpScreen: true,
        locked: false,
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
}
