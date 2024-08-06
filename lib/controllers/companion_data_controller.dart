import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:wanderguard_companion_app/services/firestore_service.dart';

import '../models/backup_companion.model.dart';
import '../models/companion.model.dart';
import 'backup_companion_data_controller.dart';

class CompanionDataController with ChangeNotifier {
  ValueNotifier<Companion?> companionModelNotifier = ValueNotifier(null);
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? companionStream;

  static void initialize() {
    GetIt.instance
        .registerSingleton<CompanionDataController>(CompanionDataController());
  }

  static CompanionDataController get instance =>
      GetIt.instance<CompanionDataController>();

  Future<void> addCompanion(Companion companion) async {
    await FirestoreService.instance.addDocument(
        'companions', companion.companionAcctId, companion.toFirestore());
  }

  Future<void> updateCompanion(Companion companion) async {
    await FirestoreService.instance.updateDocument(
        'companions', companion.companionAcctId, companion.toFirestore());
  }

  Future<Companion?> getCompanion(String companionAcctId) async {
    final doc = await FirestoreService.instance
        .getDocument('companions', companionAcctId);
    if (doc.exists) {
      return Companion.fromFirestore(doc);
    }
    return null;
  }

  Future<void> deleteCompanion(String companionAcctId) async {
    await FirestoreService.instance
        .deleteDocument('companions', companionAcctId);
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getCompanionStream(
      String companionAcctId) {
    return FirebaseFirestore.instance
        .collection("companions")
        .doc(companionAcctId)
        .snapshots();
  }

  void setCompanion(Companion? companion) {
    companionModelNotifier.value = companion;
    notifyListeners();
    if (companion != null) {
      listenToCompanionChanges(companion.companionAcctId);
    } else {
      companionStream?.cancel();
      companionStream = null;
    }
  }

  void listenToCompanionChanges(String companionAcctId) {
    companionStream?.cancel();
    companionStream = FirebaseFirestore.instance
        .collection("companions")
        .doc(companionAcctId)
        .snapshots()
        .listen(onCompanionDataChange);
  }

  void onCompanionDataChange(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.exists) {
      final data = snapshot.data();
      if (data != null) {
        final companion = Companion.fromFirestore(snapshot);
        companionModelNotifier.value = companion;
        notifyListeners();
      }
    }
  }

  Future<void> updateCompanionLocation(Position position) async {
    try {
      Companion? companion =
          CompanionDataController.instance.companionModelNotifier.value;
      BackupCompanion? backupCompanion = BackupCompanionDataController
          .instance.backupCompanionModelNotifier.value;

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
      } else if (backupCompanion != null) {
        backupCompanion.updateCurrentLocation(
            GeoPoint(position.latitude, position.longitude));
        await FirebaseFirestore.instance
            .collection('backup_companions')
            .doc(backupCompanion.backupCompanionAcctId)
            .update({
          'currentLocation': GeoPoint(position.latitude, position.longitude),
          'updatedAt': DateTime.now(),
        });
      } else {
        throw 'No companion or backup companion found';
      }
    } catch (e) {
      throw 'Failed to update location: $e';
    }
  }

  @override
  void dispose() {
    companionStream?.cancel();
    super.dispose();
  }
}
