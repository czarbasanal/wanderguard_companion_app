import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:wanderguard_companion_app/controllers/companion_data_controller.dart';
import 'package:wanderguard_companion_app/enum/account_status.enum.dart';
import 'package:wanderguard_companion_app/enum/account_type.enum.dart';
import 'package:wanderguard_companion_app/models/patient.model.dart';
import 'package:wanderguard_companion_app/services/firestore_service.dart';

import 'backup_companion_data_controller.dart';

class PatientDataController with ChangeNotifier {
  ValueNotifier<Patient?> patientModelNotifier = ValueNotifier(null);
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? patientStream;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static void initialize() {
    GetIt.instance
        .registerSingleton<PatientDataController>(PatientDataController());
  }

  static PatientDataController get instance =>
      GetIt.instance<PatientDataController>();

  void setPatient(Patient? patient) {
    patientModelNotifier.value = patient;
    notifyListeners();
    if (patient != null) {
      listenToPatientChanges(patient.patientAcctId);
    } else {
      patientStream?.cancel();
      patientStream = null;
    }
  }

  void listenToPatientChanges(String patientAcctId) {
    patientStream?.cancel();
    patientStream = FirestoreService.instance
        .getDocumentStream('patients', patientAcctId)
        .listen(onPatientDataChange);
  }

  void onPatientDataChange(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.exists) {
      final data = snapshot.data();
      if (data != null) {
        final patient = Patient.fromFirestore(snapshot);
        patientModelNotifier.value = patient;
        notifyListeners();
      }
    }
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
          photoUrl: patient.photoUrl,
          acctType: AccountType.patient,
          acctStatus: AccountStatus.offline,
          lastLocTracked: const GeoPoint(0, 0),
          lastLocUpdated: DateTime.now(),
          defaultGeofence: patient.defaultGeofence,
          geofences: patient.geofences,
          emergencyContacts: patient.emergencyContacts,
          isWithinGeofence: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          companionAcctId: companionUser.uid,
        );

        await FirestoreService.instance
            .addDocument('patients', patientUid, newPatient.toFirestore());
      } catch (e) {
        throw Exception("Error registering patient: $e");
      }
    } else {
      throw Exception("No user is currently logged in.");
    }
  }

  Future<void> updatePatient(Patient patient) async {
    try {
      await FirestoreService.instance.updateDocument(
          'patients', patient.patientAcctId, patient.toFirestore());
      setPatient(patient);
      notifyListeners();
    } catch (e) {
      throw Exception("Error updating patient: $e");
    }
  }

  Future<void> deletePatient(String patientAcctId) async {
    await FirestoreService.instance.deleteDocument('patients', patientAcctId);
  }

  Future<Patient?> getPatient(String patientAcctId) async {
    final doc =
        await FirestoreService.instance.getDocument('patients', patientAcctId);
    if (doc.exists) {
      return Patient.fromFirestore(doc);
    }
    return null;
  }

  Stream<List<Patient>> getPatientsStream() {
    final companionId = CompanionDataController
        .instance.companionModelNotifier.value?.companionAcctId;

    if (companionId == null) {
      return Stream.value([]);
    }

    return FirestoreService.instance.getCollectionStream('patients',
        queryBuilder: (query) {
      return query.where('companionAcctId', isEqualTo: companionId);
    }).map((snapshot) =>
        snapshot.docs.map((doc) => Patient.fromFirestore(doc)).toList());
  }

  Stream<List<Patient>> getPatientsStreamFromBackupCompanion() {
    final backupCompanionId = BackupCompanionDataController
        .instance.backupCompanionModelNotifier.value?.backupCompanionAcctId;

    if (backupCompanionId == null) {
      return Stream.value([]);
    }

    return FirestoreService.instance.getCollectionStream('backup_companions',
        queryBuilder: (query) {
      return query.where('backupCompanionAcctId', isEqualTo: backupCompanionId);
    }).asyncMap((snapshot) async {
      final List<Patient> patients = [];
      for (final doc in snapshot.docs) {
        final patientId = doc['patientAcctId'];
        final patientDoc =
            await FirestoreService.instance.getDocument('patients', patientId);
        if (patientDoc.exists) {
          patients.add(Patient.fromFirestore(patientDoc));
        }
      }
      return patients;
    });
  }

  ValueNotifier<Patient?> getPatientNotifier(String patientAcctId) {
    final notifier = ValueNotifier<Patient?>(null);
    FirestoreService.instance
        .getDocumentStream('patients', patientAcctId)
        .listen((snapshot) {
      if (snapshot.exists) {
        notifier.value = Patient.fromFirestore(snapshot);
      }
    });
    return notifier;
  }

  @override
  void dispose() {
    patientStream?.cancel();
    super.dispose();
  }
}
