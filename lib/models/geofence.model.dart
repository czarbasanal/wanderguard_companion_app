import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class Geofence {
  final GeoPoint center;
  final double radius;

  Geofence({
    required this.center,
    required this.radius,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'center': center,
      'radius': radius,
    };
  }

  factory Geofence.fromFirestore(Map<String, dynamic> data) {
    return Geofence(
      center: data['center'],
      radius: data['radius'],
    );
  }

  bool isWithinGeofence(GeoPoint location) {
    double distanceInMeters = Geolocator.distanceBetween(
      location.latitude,
      location.longitude,
      center.latitude,
      center.longitude,
    );

    return distanceInMeters <= radius;
  }
}
