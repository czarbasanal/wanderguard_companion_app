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

  final Map<String, dynamic> formData;

  const SetGeofenceScreen({Key? key, required this.formData}) : super(key: key);

  @override
  _SetGeofenceScreenState createState() => _SetGeofenceScreenState();
}

class _SetGeofenceScreenState extends State<SetGeofenceScreen> {
  GeoPoint? geofenceCenter;
  double? geofenceRadius;

  void _onGeofenceSet(GeoPoint center, double radius) {
    setState(() {
      geofenceCenter = center;
      geofenceRadius = radius;
    });
  }

  Future<void> _onFinalSubmit() async {
    try {
      // Extract form data
      String firstName = widget.formData['first_name'];
      String lastName = widget.formData['last_name'];
      DateTime dateOfBirth =
          DateFormat('dd/MM/yyyy').parse(widget.formData['date_of_birth']);
      String contactNo = widget.formData['contact_no'];
      String street = widget.formData['street'];
      String barangay = widget.formData['barangay'];
      String city = widget.formData['city'];
      String province = widget.formData['province'];
      String postalCode = widget.formData['postal_code'];
      String email = widget.formData['email'];
      String password = widget.formData['password'];
      String photoPath = widget.formData['profile_photo'];

      String address = '$street, $barangay, $city, $province, $postalCode';

      Future<void> createPatient() async {
        String photoUrl = '';
        if (photoPath.isNotEmpty) {
          File photoFile = File(photoPath);
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('patient_photos/${path.basename(photoFile.path)}');
          final uploadTask = storageRef.putFile(photoFile);

          final snapshot = await uploadTask.whenComplete(() {});
          photoUrl = await snapshot.ref.getDownloadURL();
        }

        // Create patient model
        final Patient newPatient = Patient(
          patientAcctId: '',
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
          lastLocTracked: const GeoPoint(0, 0),
          lastLocUpdated: DateTime.now(),
          defaultGeofence: Geofence(
            center: geofenceCenter!,
            radius: geofenceRadius!,
          ),
          geofences: [],
          emergencyContacts: [],
          isWithinGeofence: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          companionAcctId: '',
        );

        await PatientDataController.instance.addPatient(newPatient);
      }

      await WaitingDialog.show(
        context,
        future: createPatient(),
        prompt: 'Adding patient...',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.tertiaryColor,
      appBar: AppBar(
        backgroundColor: CustomColors.tertiaryColor,
        surfaceTintColor: CustomColors.tertiaryColor,
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
            GlobalRouter.I.router.go(PatientListScreen.route);
          },
        ),
      ),
      body: Stack(
        children: [
          GeofenceWidget(onGeofenceSet: _onGeofenceSet),
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
                child: const Text(
                  'Add Patient',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
