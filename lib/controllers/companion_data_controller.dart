import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../models/companion.model.dart';

class CompanionDataController with ChangeNotifier {
  ValueNotifier<Companion?> companionModelNotifier = ValueNotifier(null);
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? companionStream;

  static void initialize() {
    GetIt.instance
        .registerSingleton<CompanionDataController>(CompanionDataController());
  }

  static CompanionDataController get instance =>
      GetIt.instance<CompanionDataController>();

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

  @override
  void dispose() {
    companionStream?.cancel();
    super.dispose();
  }
}
