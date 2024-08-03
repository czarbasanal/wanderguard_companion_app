import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:wanderguard_companion_app/models/backup_companion.model.dart';
import 'package:wanderguard_companion_app/services/firestore_service.dart';

class BackupCompanionDataController with ChangeNotifier {
  ValueNotifier<BackupCompanion?> backupCompanionModelNotifier =
      ValueNotifier(null);
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      backupCompanionStream;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static void initialize() {
    GetIt.instance.registerSingleton<BackupCompanionDataController>(
        BackupCompanionDataController());
  }

  static BackupCompanionDataController get instance =>
      GetIt.instance<BackupCompanionDataController>();

  Future<void> addBackupCompanion(BackupCompanion backupCompanion) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: backupCompanion.email,
        password: backupCompanion.password,
      );

      String backupCompanionUid = userCredential.user!.uid;

      final BackupCompanion newBackupCompanion = BackupCompanion(
        backupCompanionAcctId: backupCompanionUid,
        firstName: backupCompanion.firstName,
        lastName: backupCompanion.lastName,
        email: backupCompanion.email,
        password: backupCompanion.password,
        address: backupCompanion.address,
        contactNo: backupCompanion.contactNo,
        photoUrl: backupCompanion.photoUrl,
        companionAcctId: backupCompanion.companionAcctId,
        patientAcctId: backupCompanion.patientAcctId,
        acctType: backupCompanion.acctType,
        acctStatus: backupCompanion.acctStatus,
        currentLocation: backupCompanion.currentLocation,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirestoreService.instance.addDocument('backup_companions',
          backupCompanionUid, newBackupCompanion.toFirestore());
    } catch (e) {
      throw Exception("Error registering backup companion: $e");
    }
  }

  Future<void> updateBackupCompanion(BackupCompanion backupCompanion) async {
    await FirestoreService.instance.updateDocument('backup_companions',
        backupCompanion.backupCompanionAcctId, backupCompanion.toFirestore());
  }

  Future<BackupCompanion?> getBackupCompanion(
      String backupCompanionAcctId) async {
    final doc = await FirestoreService.instance
        .getDocument('backup_companions', backupCompanionAcctId);
    if (doc.exists) {
      return BackupCompanion.fromFirestore(doc);
    }
    return null;
  }

  Future<void> deleteBackupCompanion(String backupCompanionAcctId) async {
    await FirestoreService.instance
        .deleteDocument('backup_companions', backupCompanionAcctId);
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getBackupCompanionStream(
      String backupCompanionAcctId) {
    return FirebaseFirestore.instance
        .collection("backup_companions")
        .doc(backupCompanionAcctId)
        .snapshots();
  }

  void setBackupCompanion(BackupCompanion? backupCompanion) {
    backupCompanionModelNotifier.value = backupCompanion;
    notifyListeners();
    if (backupCompanion != null) {
      listenToBackupCompanionChanges(backupCompanion.backupCompanionAcctId);
    } else {
      backupCompanionStream?.cancel();
      backupCompanionStream = null;
    }
  }

  void listenToBackupCompanionChanges(String backupCompanionAcctId) {
    backupCompanionStream?.cancel();
    backupCompanionStream = FirebaseFirestore.instance
        .collection("backup_companions")
        .doc(backupCompanionAcctId)
        .snapshots()
        .listen(onBackupCompanionDataChange);
  }

  void onBackupCompanionDataChange(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.exists) {
      final data = snapshot.data();
      if (data != null) {
        final backupCompanion = BackupCompanion.fromFirestore(snapshot);
        backupCompanionModelNotifier.value = backupCompanion;
        notifyListeners();
      }
    }
  }

  Future<void> updateBackupCompanionLocation(Position position) async {
    try {
      BackupCompanion? backupCompanion = backupCompanionModelNotifier.value;
      if (backupCompanion != null) {
        backupCompanion.updateCurrentLocation(
            GeoPoint(position.latitude, position.longitude));
        await FirestoreService.instance.updateDocument(
          'backup_companions',
          backupCompanion.backupCompanionAcctId,
          {
            'currentLocation': GeoPoint(position.latitude, position.longitude),
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          },
        );
      }
    } catch (e) {
      throw 'Failed to update location: $e';
    }
  }

  Stream<List<BackupCompanion>> getBackupCompanionsByCompanionAcctId(
      String companionAcctId) {
    return FirestoreService.instance.getCollectionStream(
      'backup_companions',
      queryBuilder: (query) {
        return query.where('companionAcctId', isEqualTo: companionAcctId);
      },
    ).map((snapshot) => snapshot.docs
        .map((doc) => BackupCompanion.fromFirestore(doc))
        .toList());
  }

  @override
  void dispose() {
    backupCompanionStream?.cancel();
    super.dispose();
  }
}
