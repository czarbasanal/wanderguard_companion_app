import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:geolocator/geolocator.dart';

class PermissionService {
  static Future<void> initialize() async {
    try {
      await requestLocationPermission();
      await requestNotificationPermission();
      print('All permissions granted successfully');
    } catch (e) {
      print('Error requesting permissions: $e');
    }
  }

  static Future<bool> requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied, we cannot request permissions.';
    }

    return true;
  }

  static Future<void> requestNotificationPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      isAllowed =
          await AwesomeNotifications().requestPermissionToSendNotifications();
      if (!isAllowed) {
        throw 'User declined or has not accepted permission';
      } else {
        print('User granted permission');
      }
    }
  }
}
