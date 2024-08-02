import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wanderguard_companion_app/models/geofence.model.dart';
import '../models/companion.model.dart';
import '../models/patient.model.dart';
import '../controllers/companion_data_controller.dart';
import '../controllers/patient_data_controller.dart';
import '../state/homescreen_state.dart';
import 'permission_service.dart';

class LocationService {
  static void initialize() {
    GetIt.instance.registerSingleton<LocationService>(LocationService());
  }

  static LocationService get instance => GetIt.instance<LocationService>();

  Future<Position> getCurrentLocation() async {
    await PermissionService.requestLocationPermission();
    return await Geolocator.getCurrentPosition();
  }

  Future<void> updateCompanionLocation(Position position) async {
    try {
      Companion? companion =
          CompanionDataController.instance.companionModelNotifier.value;
      if (companion != null) {
        companion.updateCurrentLocation(
            GeoPoint(position.latitude, position.longitude));
        await FirebaseFirestore.instance
            .collection('companions')
            .doc(companion.companionAcctId)
            .update({
          'currentLocation': GeoPoint(position.latitude, position.longitude),
          'updatedAt': DateTime.now(),
        });
      }
    } catch (e) {
      throw 'Failed to update location: $e';
    }
  }

  Future<void> locatePatient(
      HomeScreenState homeScreenState, Patient patient) async {
    await homeScreenState.scrollableController.animateTo(
      0.06,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    homeScreenState.setLoadingMarker(true);

    await homeScreenState.moveCamera(LatLng(
      patient.lastLocTracked.latitude,
      patient.lastLocTracked.longitude,
    ));

    await homeScreenState.addMarker(
      LatLng(patient.lastLocTracked.latitude, patient.lastLocTracked.longitude),
      patient.patientAcctId,
      patient.photoUrl,
    );

    drawGeofence(homeScreenState, patient.defaultGeofence);

    homeScreenState.setLoadingMarker(false);

    homeScreenState.setSelectedPatient(patient);
    homeScreenState.setShowFloatingCard(true);
  }

  void drawGeofence(HomeScreenState homeScreenState, Geofence? geofence) {
    if (geofence != null) {
      final center =
          LatLng(geofence.center.latitude, geofence.center.longitude);
      final radius = geofence.radius;

      final circle = Circle(
        circleId: CircleId(
            'geofence_${geofence.center.latitude}_${geofence.center.longitude}'),
        center: center,
        radius: radius,
        fillColor: Colors.deepPurpleAccent.withOpacity(0.2),
        strokeColor: Colors.deepPurpleAccent,
        strokeWidth: 2,
      );

      homeScreenState.addCircle(circle);
    }
  }
}
