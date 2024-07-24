import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:get_it/get_it.dart';

import '../enum/account_status.enum.dart';
import '../enum/account_type.enum.dart';
import '../models/companion.model.dart';
import '../models/patient.model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  Future<void> addPatient(Patient patient) async {
    final User? companionUser = _auth.currentUser;
    if (companionUser != null) {
      try {
        // Register the patient with Firebase Auth
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: patient.email,
          password: patient.password,
        );

        // Get the newly created patient's UID
        String patientUid = userCredential.user!.uid;

        // Store patient details in Firestore
        final DocumentReference docRef =
            _db.collection('patients').doc(patientUid);
        final Patient newPatient = Patient(
          patientAcctId: patientUid,
          firstName: patient.firstName,
          lastName: patient.lastName,
          dateOfBirth: patient.dateOfBirth,
          contactNo: patient.contactNo,
          address: patient.address,
          lastLocTracked: patient.lastLocTracked,
          lastLocUpdated: patient.lastLocUpdated,
          companionAcctId: companionUser.uid,
          geofenceCenter: patient.geofenceCenter,
          geofenceRadius: patient.geofenceRadius,
          email: patient.email,
          password: patient.password,
          acctType: AccountType.patient,
          acctStatus: AccountStatus.offline,
        );
        await docRef.set(newPatient.toFirestore());
      } catch (e) {
        throw Exception("Error registering patient: $e");
      }
    } else {
      throw Exception("No user is currently logged in.");
    }
  }
}
