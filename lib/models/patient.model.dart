import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderguard_companion_app/enum/account_status.enum.dart';
import 'package:wanderguard_companion_app/enum/account_type.enum.dart';

import 'geofence.model.dart';
import 'emergency_contact.model.dart';

class Patient {
  final String patientAcctId;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String homeAddress;
  final String contactNo;
  final DateTime dateOfBirth;
  final String photoUrl;
  final AccountType acctType;
  final AccountStatus acctStatus;
  final GeoPoint lastLocTracked;
  final DateTime lastLocUpdated;
  final Geofence defaultGeofence;
  final List<Geofence> geofences;
  final List<EmergencyContact> emergencyContacts;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String companionAcctId;

  Patient({
    required this.patientAcctId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.homeAddress,
    required this.contactNo,
    required this.dateOfBirth,
    required this.photoUrl,
    required this.acctType,
    required this.acctStatus,
    required this.lastLocTracked,
    required this.lastLocUpdated,
    required this.defaultGeofence,
    required this.geofences,
    required this.emergencyContacts,
    required this.createdAt,
    required this.updatedAt,
    required this.companionAcctId,
  });

  // Convert Patient to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'patientAcctId': patientAcctId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'homeAddress': homeAddress,
      'contactNo': contactNo,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'photoUrl': photoUrl,
      'acctType': acctType.name,
      'acctStatus': acctStatus.name,
      'lastLocTracked': lastLocTracked,
      'lastLocUpdated': Timestamp.fromDate(lastLocUpdated),
      'defaultGeofence': defaultGeofence.toFirestore(),
      'geofences': geofences.map((geofence) => geofence.toFirestore()).toList(),
      'emergencyContacts':
          emergencyContacts.map((contact) => contact.toFirestore()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'companionAcctId': companionAcctId,
    };
  }

  factory Patient.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Patient(
      patientAcctId: data['patientAcctId'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      email: data['email'],
      password: data['password'],
      homeAddress: data['homeAddress'],
      contactNo: data['contactNo'],
      dateOfBirth: (data['dateOfBirth'] as Timestamp).toDate(),
      photoUrl: data['photoUrl'],
      acctType: AccountTypeExtension.fromString(data['acctType']),
      acctStatus: AccountStatusExtension.fromString(data['acctStatus']),
      lastLocTracked: data['lastLocTracked'],
      lastLocUpdated: (data['lastLocUpdated'] as Timestamp).toDate(),
      defaultGeofence: Geofence.fromFirestore(data['defaultGeofence']),
      geofences: (data['geofences'] as List)
          .map((geofenceData) => Geofence.fromFirestore(geofenceData))
          .toList(),
      emergencyContacts: (data['emergencyContacts'] as List)
          .map((contactData) => EmergencyContact.fromFirestore(contactData))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      companionAcctId: data['companionAcctId'],
    );
  }
}
