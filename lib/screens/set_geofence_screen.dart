import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wanderguard_companion_app/enum/account_status.enum.dart';
import 'package:wanderguard_companion_app/enum/account_type.enum.dart';
import 'package:wanderguard_companion_app/services/firestore_service.dart';
import 'package:wanderguard_companion_app/services/information_service.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';
import 'package:wanderguard_companion_app/widgets/dialogs/waiting_dialog.dart';
import 'package:wanderguard_companion_app/widgets/geofence_widget.dart';
import 'package:intl/intl.dart';
import 'package:wanderguard_companion_app/models/patient.model.dart';
import 'package:wanderguard_companion_app/models/geofence.model.dart';

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

      String address = '$street, $barangay, $city, $province, $postalCode';

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
        photoUrl: '',
        acctType: AccountType.patient,
        acctStatus: AccountStatus.offline,
        defaultGeofence: Geofence(
          center: geofenceCenter!,
          radius: geofenceRadius!,
        ),
        geofences: [],
        emergencyContacts: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        companionAcctId: '',
      );

      await WaitingDialog.show(
        context,
        future: FirestoreService.instance.addPatient(newPatient),
        prompt: 'Adding patient...',
      );
      if (mounted) {
        Navigator.of(context).pop();
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
      appBar: AppBar(
        title: const Text("Set Geofence"),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMapGeofenceWidget(onGeofenceSet: _onGeofenceSet),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: geofenceCenter != null && geofenceRadius != null
                  ? _onFinalSubmit
                  : null,
              child: const Text("Add Patient"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: CustomColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
