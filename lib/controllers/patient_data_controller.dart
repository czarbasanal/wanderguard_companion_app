import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wanderguard_companion_app/services/firestore_service.dart';
import '../models/patient.model.dart';

class PatientDataController {
  Future<void> addPatient({
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required String contactNo,
    required String address,
    GeoPoint? lastLocTracked,
    DateTime? lastLocUpdated,
    LatLng? geofenceCenter,
    double? geofenceRadius,
    required String email,
    required String password,
  }) async {
    try {
      final Patient patient = Patient(
        patientAcctId: '',
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
        contactNo: contactNo,
        address: address,
        lastLocTracked: lastLocTracked,
        lastLocUpdated: lastLocUpdated,
        companionAcctId: '',
        geofenceCenter: geofenceCenter,
        geofenceRadius: geofenceRadius,
        email: email,
        password: password,
      );
      await FirestoreService.instance.addPatient(patient);
    } catch (e) {
      debugPrint("Error adding patient: $e");
      rethrow;
    }
  }
}
