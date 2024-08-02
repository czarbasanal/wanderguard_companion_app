import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderguard_companion_app/enum/account_status.enum.dart';
import 'package:wanderguard_companion_app/enum/account_type.enum.dart';

class Companion {
  final String companionAcctId;
  final String firstName;
  final String lastName;
  final String email;
  final String address;
  final String contactNo;
  final String photoUrl;
  final AccountType acctType;
  final AccountStatus acctStatus;
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
    required this.acctStatus,
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
      'acctType': acctType.name,
      'acctStatus': acctStatus.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
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
      acctType: AccountTypeExtension.fromString(data['acctType']),
      acctStatus: AccountStatusExtension.fromString(data['acctStatus']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      currentLocation: data['currentLocation'],
    );
  }

  Companion copyWith({
    String? companionAcctId,
    String? firstName,
    String? lastName,
    String? email,
    String? address,
    String? contactNo,
    String? photoUrl,
    AccountType? acctType,
    AccountStatus? acctStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    GeoPoint? currentLocation,
  }) {
    return Companion(
      companionAcctId: companionAcctId ?? this.companionAcctId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      address: address ?? this.address,
      contactNo: contactNo ?? this.contactNo,
      photoUrl: photoUrl ?? this.photoUrl,
      acctType: acctType ?? this.acctType,
      acctStatus: acctStatus ?? this.acctStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currentLocation: currentLocation ?? this.currentLocation,
    );
  }
}
