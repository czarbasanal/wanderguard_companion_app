import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import 'package:wanderguard_companion_app/controllers/patient_data_controller.dart';
import 'package:wanderguard_companion_app/enum/account_status.enum.dart';
import 'package:wanderguard_companion_app/enum/account_type.enum.dart';
import 'package:wanderguard_companion_app/routing/router.dart';
import 'package:wanderguard_companion_app/screens/patients/patient_list_screen.dart';
import 'package:wanderguard_companion_app/services/information_service.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';
import 'package:wanderguard_companion_app/widgets/dialogs/waiting_dialog.dart';
import 'package:wanderguard_companion_app/models/patient.model.dart';
import 'package:wanderguard_companion_app/models/geofence.model.dart';
import 'package:wanderguard_companion_app/widgets/google_map_geofence.dart';

class SetGeofenceScreen extends StatefulWidget {
  static const String route = "/set_geofence";
  static const String name = "Set Geofence";

  final Map<String, dynamic>? formData;

  const SetGeofenceScreen({super.key, this.formData});

  @override
  _SetGeofenceScreenState createState() => _SetGeofenceScreenState();
}

class _SetGeofenceScreenState extends State<SetGeofenceScreen> {
  GeoPoint? geofenceCenter;
  double? geofenceRadius;
  final Patient? existingPatient =
      PatientDataController.instance.patientModelNotifier.value;

  @override
  void initState() {
    super.initState();
    if (existingPatient != null) {
      geofenceCenter = existingPatient!.defaultGeofence.center;
      geofenceRadius = existingPatient!.defaultGeofence.radius;
    } else {
      print('Patient is null');
    }
  }

  void _onGeofenceSet(GeoPoint center, double radius) {
    setState(() {
      geofenceCenter = center;
      geofenceRadius = radius;
    });
  }

  Future<void> _onFinalSubmit() async {
    try {
      String firstName;
      String lastName;
      DateTime dateOfBirth;
      String contactNo;
      String street;
      String barangay;
      String city;
      String province;
      String postalCode;
      String email;
      String password;
      String photoPath;

      if (existingPatient != null) {
        firstName = existingPatient!.firstName;
        lastName = existingPatient!.lastName;
        dateOfBirth = existingPatient!.dateOfBirth;
        contactNo = existingPatient!.contactNo;
        street = existingPatient!.homeAddress.split(', ')[0];
        barangay = existingPatient!.homeAddress.split(', ')[1];
        city = existingPatient!.homeAddress.split(', ')[2];
        province = existingPatient!.homeAddress.split(', ')[3];
        postalCode = existingPatient!.homeAddress.split(', ')[4];
        email = existingPatient!.email;
        password = existingPatient!.password;
        photoPath = existingPatient!.photoUrl;
      } else {
        firstName = widget.formData!['first_name'];
        lastName = widget.formData!['last_name'];
        dateOfBirth =
            DateFormat('dd/MM/yyyy').parse(widget.formData!['date_of_birth']);
        contactNo = widget.formData!['contact_no'];
        street = widget.formData!['street'];
        barangay = widget.formData!['barangay'];
        city = widget.formData!['city'];
        province = widget.formData!['province'];
        postalCode = widget.formData!['postal_code'];
        email = widget.formData!['email'];
        password = widget.formData!['password'];
        photoPath = widget.formData!['profile_photo'];
      }

      String address = '$street, $barangay, $city, $province, $postalCode';

      Future<void> createOrUpdatePatient() async {
        String photoUrl = photoPath;
        if (existingPatient == null && photoPath.isNotEmpty) {
          File photoFile = File(photoPath);
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('patient_photos/${path.basename(photoFile.path)}');
          final uploadTask = storageRef.putFile(photoFile);

          final snapshot = await uploadTask.whenComplete(() {});
          photoUrl = await snapshot.ref.getDownloadURL();
        }

        final Patient patient = Patient(
          patientAcctId: existingPatient?.patientAcctId ?? '',
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password,
          homeAddress: address,
          contactNo: contactNo,
          dateOfBirth: dateOfBirth,
          photoUrl: photoUrl,
          acctType: AccountType.patient,
          acctStatus: AccountStatus.offline,
          lastLocTracked:
              existingPatient?.lastLocTracked ?? const GeoPoint(0, 0),
          lastLocUpdated: existingPatient?.lastLocUpdated ?? DateTime.now(),
          defaultGeofence: Geofence(
            center: geofenceCenter!,
            radius: geofenceRadius!,
          ),
          geofences: existingPatient?.geofences ?? [],
          emergencyContacts: existingPatient?.emergencyContacts ?? [],
          isWithinGeofence: existingPatient?.isWithinGeofence ?? true,
          createdAt: existingPatient?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
          companionAcctId: existingPatient?.companionAcctId ?? '',
        );

        if (existingPatient == null) {
          await PatientDataController.instance.addPatient(patient);
        } else {
          await PatientDataController.instance.updatePatient(patient);
          PatientDataController.instance.patientModelNotifier.value = null;
        }
      }

      await WaitingDialog.show(
        context,
        future: createOrUpdatePatient(),
        prompt: existingPatient == null
            ? 'Adding patient...'
            : 'Updating patient...',
      );

      if (mounted) {
        GlobalRouter.I.router.go(PatientListScreen.route);
      }
    } catch (e) {
      Info.showSnackbarMessage(
        context,
        message: e.toString(),
        actionLabel: 'Close',
      );
    }
  }

  void _deleteGeofence() {
    setState(() {
      geofenceCenter = const GeoPoint(0, 0);
      geofenceRadius = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.tertiaryColor,
      appBar: AppBar(
        backgroundColor: CustomColors.tertiaryColor,
        surfaceTintColor: CustomColors.tertiaryColor,
        centerTitle: true,
        title: const Text(
          "Set Geofence",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            size: 20,
          ),
          onPressed: () {
            GlobalRouter.I.router.pop(true);
          },
        ),
      ),
      body: Stack(
        children: [
          GeofenceWidget(
            onGeofenceSet: _onGeofenceSet,
            initialGeofenceCenter: geofenceCenter,
            initialGeofenceRadius: geofenceRadius,
          ),
          if (geofenceCenter != null && geofenceRadius != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textColor: CustomColors.secondaryColor,
                color: CustomColors.primaryColor,
                minWidth: double.infinity,
                height: 55,
                onPressed: _onFinalSubmit,
                child: Text(
                  existingPatient == null ? 'Add Patient' : 'Update Patient',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          if (existingPatient != null)
            Positioned(
              bottom: 90,
              left: 16,
              right: 16,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _deleteGeofence,
                child: const Text(
                  'Delete Geofence',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
