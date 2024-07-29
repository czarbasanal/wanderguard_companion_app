import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wanderguard_companion_app/controllers/patient_data_controller.dart';
import 'package:wanderguard_companion_app/enum/account_status.enum.dart';
import 'package:wanderguard_companion_app/enum/account_type.enum.dart';
import 'package:wanderguard_companion_app/routing/router.dart';
import 'package:wanderguard_companion_app/screens/patients/patient_list_screen.dart';
import 'package:wanderguard_companion_app/services/information_service.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';
import 'package:wanderguard_companion_app/widgets/dialogs/waiting_dialog.dart';
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
  Set<Marker> markers = {};
  Set<Circle> circles = {};

  void _onGeofenceSet(GeoPoint center, double radius) {
    setState(() {
      geofenceCenter = center;
      geofenceRadius = radius;
      markers = {
        Marker(
          markerId: MarkerId('geofence_center'),
          position: LatLng(center.latitude, center.longitude),
        ),
      };
      circles = {
        Circle(
          circleId: CircleId('geofence_radius'),
          center: LatLng(center.latitude, center.longitude),
          radius: radius,
          fillColor: Colors.deepPurpleAccent.withOpacity(0.2),
          strokeColor: Colors.deepPurpleAccent,
          strokeWidth: 2,
        ),
      };
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
        lastLocTracked: GeoPoint(0, 0),
        lastLocUpdated: DateTime.now(),
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
        future: PatientDataController.instance.addPatient(newPatient),
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
          GoogleMapGeofenceWidget(
            onGeofenceSet: _onGeofenceSet,
            markers: markers,
            circles: circles,
          ),
          if (geofenceCenter != null && geofenceRadius != null)
            DraggableScrollableSheet(
              initialChildSize: 0.33,
              minChildSize: 0.33,
              maxChildSize: 0.33,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: CustomColors.secondaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Text(
                        'Radius: ${geofenceRadius!.toStringAsFixed(1)} meters',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Slider(
                        activeColor: CustomColors.primaryColor,
                        inactiveColor: Colors.grey.shade400,
                        value: geofenceRadius!,
                        min: 20,
                        max: 1000,
                        divisions: 98,
                        label: geofenceRadius!.round().toString(),
                        onChanged: (double value) {
                          setState(() {
                            geofenceRadius = value;
                            _onGeofenceSet(geofenceCenter!, geofenceRadius!);
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textColor: CustomColors.secondaryColor,
                        color: CustomColors.primaryColor,
                        minWidth: double.infinity,
                        height: 55,
                        onPressed:
                            geofenceCenter != null && geofenceRadius != null
                                ? _onFinalSubmit
                                : null,
                        child: const Text(
                          'Add Patient',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class GoogleMapGeofenceWidget extends StatefulWidget {
  final Function(GeoPoint, double) onGeofenceSet;
  final Set<Marker> markers;
  final Set<Circle> circles;

  const GoogleMapGeofenceWidget({
    Key? key,
    required this.onGeofenceSet,
    required this.markers,
    required this.circles,
  }) : super(key: key);

  @override
  _GoogleMapGeofenceWidgetState createState() =>
      _GoogleMapGeofenceWidgetState();
}

class _GoogleMapGeofenceWidgetState extends State<GoogleMapGeofenceWidget> {
  double _radius = 100.0;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(10.3157, 123.8854),
        zoom: 14.0,
      ),
      markers: widget.markers,
      circles: widget.circles,
      onTap: (LatLng position) {
        setState(() {
          widget.onGeofenceSet(
            GeoPoint(position.latitude, position.longitude),
            _radius,
          );
        });
      },
      onMapCreated: (GoogleMapController controller) {},
    );
  }
}
