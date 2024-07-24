import 'package:cloud_firestore/cloud_firestore.dart';

class Geofence {
  final GeoPoint center;
  final double radius; // in meters

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
}
