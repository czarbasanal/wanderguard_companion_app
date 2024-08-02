import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderguard_companion_app/enum/account_status.enum.dart';
import 'package:wanderguard_companion_app/enum/account_type.enum.dart';

class BackupCompanion {
  final String backupCompanionAcctId;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String address;
  final String contactNo;
  final String photoUrl;
  final AccountType acctType;
  final AccountStatus acctStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  GeoPoint currentLocation;
  final String companionAcctId;
  final String patientAcctId;

  BackupCompanion(
      {required this.backupCompanionAcctId,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.password,
      required this.address,
      required this.contactNo,
      required this.photoUrl,
      required this.acctType,
      required this.acctStatus,
      required this.createdAt,
      required this.updatedAt,
      required this.currentLocation,
      required this.companionAcctId,
      required this.patientAcctId});

  void updateCurrentLocation(GeoPoint newLocation) {
    currentLocation = newLocation;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'backupCompanionAcctId': backupCompanionAcctId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'address': address,
      'contactNo': contactNo,
      'photoUrl': photoUrl,
      'acctType': acctType.name,
      'acctStatus': acctStatus.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'currentLocation': currentLocation,
      'companionAcctId': companionAcctId,
      'patientAcctId': patientAcctId
    };
  }

  factory BackupCompanion.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return BackupCompanion(
        backupCompanionAcctId: data['backupCompanionAcctId'],
        firstName: data['firstName'],
        lastName: data['lastName'],
        email: data['email'],
        password: data['password'],
        address: data['address'],
        contactNo: data['contactNo'],
        photoUrl: data['photoUrl'],
        acctType: AccountTypeExtension.fromString(data['acctType']),
        acctStatus: AccountStatusExtension.fromString(data['acctStatus']),
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        updatedAt: (data['updatedAt'] as Timestamp).toDate(),
        currentLocation: data['currentLocation'],
        companionAcctId: data['companionAcctId'],
        patientAcctId: data['patientAcctId']);
  }

  BackupCompanion copyWith(
      {String? backupCompanionAcctId,
      String? firstName,
      String? lastName,
      String? email,
      String? password,
      String? address,
      String? contactNo,
      String? photoUrl,
      AccountType? acctType,
      AccountStatus? acctStatus,
      DateTime? createdAt,
      DateTime? updatedAt,
      GeoPoint? currentLocation,
      String? companionAcctId,
      String? patientAcctId}) {
    return BackupCompanion(
        backupCompanionAcctId:
            backupCompanionAcctId ?? this.backupCompanionAcctId,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        email: email ?? this.email,
        password: password ?? this.password,
        address: address ?? this.address,
        contactNo: contactNo ?? this.contactNo,
        photoUrl: photoUrl ?? this.photoUrl,
        acctType: acctType ?? this.acctType,
        acctStatus: acctStatus ?? this.acctStatus,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        currentLocation: currentLocation ?? this.currentLocation,
        companionAcctId: companionAcctId ?? this.companionAcctId,
        patientAcctId: patientAcctId ?? this.patientAcctId);
  }
}
