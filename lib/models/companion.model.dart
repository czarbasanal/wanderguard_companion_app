import 'package:cloud_firestore/cloud_firestore.dart';

import '../enum/account_type.enum.dart';

class Companion {
  final String companionAcctId;
  final String firstName;
  final String lastName;
  final String email;
  final String address;
  final String contactNo;
  final String photoUrl;
  final AccountType acctType;
  final DateTime createdAt;
  final DateTime updatedAt;
  GeoPoint currentLocation;

  Companion({
    required this.companionAcctId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.address,
    required this.contactNo,
    required this.photoUrl,
    required this.acctType,
    required this.createdAt,
    required this.updatedAt,
    required this.currentLocation,
  });

  // Method to update the current location
  void updateCurrentLocation(GeoPoint newLocation) {
    currentLocation = newLocation;
  }

  // Convert Companion to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'companionAcctId': companionAcctId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'address': address,
      'contactNo': contactNo,
      'photoUrl': photoUrl,
      'acctType': acctType.toString(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'currentLocation': currentLocation,
    };
  }

  factory Companion.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Companion(
      companionAcctId: data['companionAcctId'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      email: data['email'],
      address: data['address'],
      contactNo: data['contactNo'],
      photoUrl: data['photoUrl'],
      acctType: AccountType.values
          .firstWhere((e) => e.toString() == data['acctType']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      currentLocation: data['currentLocation'],
    );
  }
}
