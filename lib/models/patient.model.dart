import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../enum/account_status.enum.dart';
import '../enum/account_type.enum.dart';

class Patient {
  final String patientAcctId;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String contactNo;
  final String address;
  final GeoPoint? lastLocTracked;
  final DateTime? lastLocUpdated;
  final LatLng? geofenceCenter;
  final double? geofenceRadius;
  final String companionAcctId;
  final String email;
  final String password;
  final AccountType acctType;
  final AccountStatus acctStatus;

  Patient({
    required this.patientAcctId,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.contactNo,
    required this.address,
    this.lastLocTracked,
    this.lastLocUpdated,
    required this.companionAcctId,
    this.geofenceCenter,
    this.geofenceRadius,
    required this.email,
    required this.password,
    this.acctType = AccountType.patient,
    this.acctStatus = AccountStatus.offline,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'patientAcctId': patientAcctId,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'contactNo': contactNo,
      'address': address,
      'lastLocTracked': lastLocTracked,
      'lastLocUpdated': lastLocUpdated,
      'companionAcctId': companionAcctId,
      'geofenceCenter': geofenceCenter != null
          ? {
              'latitude': geofenceCenter!.latitude,
              'longitude': geofenceCenter!.longitude
            }
          : null,
      'geofenceRadius': geofenceRadius,
      'email': email,
      'password':
          password, // Note: It's not recommended to store passwords in Firestore directly.
      'acctType': acctType.toString().split('.').last,
      'acctStatus': acctStatus.toString().split('.').last,
    };
  }

  factory Patient.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Patient(
      patientAcctId: data['patientAcctId'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      dateOfBirth: (data['dateOfBirth'] as Timestamp).toDate(),
      contactNo: data['contactNo'],
      address: data['address'],
      lastLocTracked: data['lastLocTracked'],
      lastLocUpdated: (data['lastLocUpdated'] as Timestamp).toDate(),
      companionAcctId: data['companionAcctId'],
      geofenceCenter: data['geofenceCenter'] != null
          ? LatLng(data['geofenceCenter']['latitude'],
              data['geofenceCenter']['longitude'])
          : null,
      geofenceRadius: data['geofenceRadius'],
      email: data['email'],
      password: data['password'],
      acctType: AccountType.values
          .firstWhere((e) => e.toString().split('.').last == data['acctType']),
      acctStatus: AccountStatus.values.firstWhere(
          (e) => e.toString().split('.').last == data['acctStatus']),
    );
  }
}
