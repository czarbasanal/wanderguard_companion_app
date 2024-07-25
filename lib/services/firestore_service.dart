import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:wanderguard_companion_app/enum/account_status.enum.dart';
import 'package:wanderguard_companion_app/enum/account_type.enum.dart';
import 'package:wanderguard_companion_app/models/companion.model.dart';
import 'package:wanderguard_companion_app/models/patient.model.dart';

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
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: patient.email,
          password: patient.password,
        );

        String patientUid = userCredential.user!.uid;

        final Patient newPatient = Patient(
          patientAcctId: patientUid,
          firstName: patient.firstName,
          lastName: patient.lastName,
          email: patient.email,
          password: patient.password,
          homeAddress: patient.homeAddress,
          contactNo: patient.contactNo,
          dateOfBirth: patient.dateOfBirth,
          photoUrl: '',
          acctType: AccountType.patient,
          acctStatus: AccountStatus.offline,
          lastLocTracked: GeoPoint(0, 0),
          lastLocUpdated: DateTime.now(),
          defaultGeofence: patient.defaultGeofence,
          geofences: patient.geofences,
          emergencyContacts: patient.emergencyContacts,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          companionAcctId: companionUser.uid,
        );

        final DocumentReference docRef =
            _db.collection('patients').doc(patientUid);
        await docRef.set(newPatient.toFirestore());
      } catch (e) {
        throw Exception("Error registering patient: $e");
      }
    } else {
      throw Exception("No user is currently logged in.");
    }
  }

  Future<List<Patient>> getPatients() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("No user is currently logged in.");
    }

    final querySnapshot = await _db
        .collection('patients')
        .where('companionAcctId', isEqualTo: currentUser.uid)
        .get();

    return querySnapshot.docs.map((doc) => Patient.fromFirestore(doc)).toList();
  }
}
