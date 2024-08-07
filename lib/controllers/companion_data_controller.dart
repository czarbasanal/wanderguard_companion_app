import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:wanderguard_companion_app/services/firestore_service.dart';

import '../models/companion.model.dart';

class CompanionDataController with ChangeNotifier {
  ValueNotifier<Companion?> companionModelNotifier = ValueNotifier(null);
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? companionStream;

  Companion? get currentCompanion => companionModelNotifier.value;

  static void initialize() {
    GetIt.instance
        .registerSingleton<CompanionDataController>(CompanionDataController());
  }

  static CompanionDataController get instance =>
      GetIt.instance<CompanionDataController>();

  Future<void> addCompanion(Companion companion) async {
    print('Adding companion: ${companion.companionAcctId}');
    await FirestoreService.instance.addDocument(
        'companions', companion.companionAcctId, companion.toFirestore());
  }

  Future<void> updateCompanion(Companion companion) async {
    print('Updating companion: ${companion.companionAcctId}');
    await FirestoreService.instance.updateDocument(
        'companions', companion.companionAcctId, companion.toFirestore());
  }

  Future<Companion?> getCompanion(String companionAcctId) async {
    print('Fetching companion data for: $companionAcctId');
    final doc = await FirestoreService.instance
        .getDocument('companions', companionAcctId);
    if (doc.exists) {
      print('Companion data found: ${doc.data()}');
      return Companion.fromFirestore(doc);
    } else {
      print('Companion not found');
    }
    return null;
  }

  Future<void> deleteCompanion(String companionAcctId) async {
    print('Deleting companion: $companionAcctId');
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
      print('Listening to changes for companion: ${companion.companionAcctId}');
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
        print('Companion data changed: $data');
        final companion = Companion.fromFirestore(snapshot);
        companionModelNotifier.value = companion;
        notifyListeners();
      }
    }
  }

  Future<void> updateCompanionLocation(Position position) async {
    try {
      Companion? companion = companionModelNotifier.value;
      if (companion != null) {
        companion.updateCurrentLocation(
            GeoPoint(position.latitude, position.longitude));
        await FirestoreService.instance.updateDocument(
          'companions',
          companion.companionAcctId,
          {
            'currentLocation': GeoPoint(position.latitude, position.longitude),
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          },
        );
        print('Updated location for companion: ${companion.companionAcctId}');
      }
    } catch (e) {
      print('Failed to update location: $e');
      throw 'Failed to update location: $e';
    }
  }

  @override
  void dispose() {
    companionStream?.cancel();
    super.dispose();
  }
}
