import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../models/companion.model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static FirestoreService get instance => GetIt.instance<FirestoreService>();

  static void initialize() {
    GetIt.instance.registerSingleton<FirestoreService>(FirestoreService());
  }

  Future<void> addOrUpdateCompanion(Companion companion) async {
    final companionRef =
        _db.collection('companions').doc(companion.companionAcctId);
    await companionRef.set(companion.toFirestore());
  }

  Future<Companion?> getCompanion(String companionAcctId) async {
    final companionRef = _db.collection('companions').doc(companionAcctId);
    final doc = await companionRef.get();
    if (doc.exists) {
      return Companion.fromFirestore(doc);
    }
    return null;
  }

  Future<void> deleteCompanion(String companionAcctId) async {
    final companionRef = _db.collection('companions').doc(companionAcctId);
    await companionRef.delete();
  }
}
