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
  final Patient? existingPatient;

  const SetGeofenceScreen({Key? key, this.formData, this.existingPatient})
      : super(key: key);

  @override
  _SetGeofenceScreenState createState() => _SetGeofenceScreenState();
}

class _SetGeofenceScreenState extends State<SetGeofenceScreen> {
  GeoPoint? geofenceCenter;
  double? geofenceRadius;

  @override
  void initState() {
    super.initState();
    if (widget.existingPatient != null) {
      geofenceCenter = widget.existingPatient!.defaultGeofence.center;
      geofenceRadius = widget.existingPatient!.defaultGeofence.radius;
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

      if (widget.existingPatient != null) {
        firstName = widget.existingPatient!.firstName;
        lastName = widget.existingPatient!.lastName;
        dateOfBirth = widget.existingPatient!.dateOfBirth;
        contactNo = widget.existingPatient!.contactNo;
        street = widget.existingPatient!.homeAddress.split(', ')[0];
        barangay = widget.existingPatient!.homeAddress.split(', ')[1];
        city = widget.existingPatient!.homeAddress.split(', ')[2];
        province = widget.existingPatient!.homeAddress.split(', ')[3];
        postalCode = widget.existingPatient!.homeAddress.split(', ')[4];
        email = widget.existingPatient!.email;
        password = widget.existingPatient!.password;
        photoPath = widget.existingPatient!.photoUrl;
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
        if (widget.existingPatient == null && photoPath.isNotEmpty) {
          File photoFile = File(photoPath);
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('patient_photos/${path.basename(photoFile.path)}');
          final uploadTask = storageRef.putFile(photoFile);

          final snapshot = await uploadTask.whenComplete(() {});
          photoUrl = await snapshot.ref.getDownloadURL();
        }

        final Patient patient = Patient(
          patientAcctId: widget.existingPatient?.patientAcctId ?? '',
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
              widget.existingPatient?.lastLocTracked ?? const GeoPoint(0, 0),
          lastLocUpdated:
              widget.existingPatient?.lastLocUpdated ?? DateTime.now(),
          defaultGeofence: Geofence(
            center: geofenceCenter!,
            radius: geofenceRadius!,
          ),
          geofences: widget.existingPatient?.geofences ?? [],
          emergencyContacts: widget.existingPatient?.emergencyContacts ?? [],
          isWithinGeofence: widget.existingPatient?.isWithinGeofence ?? true,
          createdAt: widget.existingPatient?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
          companionAcctId: widget.existingPatient?.companionAcctId ?? '',
        );

        if (widget.existingPatient == null) {
          await PatientDataController.instance.addPatient(patient);
        } else {
          await PatientDataController.instance.updatePatient(patient);
        }
      }

      await WaitingDialog.show(
        context,
        future: createOrUpdatePatient(),
        prompt: widget.existingPatient == null
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
                child: Text(
                  widget.existingPatient == null
                      ? 'Add Patient'
                      : 'Update Patient',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
