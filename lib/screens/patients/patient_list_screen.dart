import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wanderguard_companion_app/main.dart';
import 'package:wanderguard_companion_app/models/patient.model.dart';
import 'package:wanderguard_companion_app/routing/router.dart';
import 'package:wanderguard_companion_app/screens/home/home_screen.dart';
import 'package:wanderguard_companion_app/screens/patients/add_patient_screen.dart';
import 'package:wanderguard_companion_app/screens/patients/edit_patient_screen.dart';
import 'package:wanderguard_companion_app/services/zegocloud_service.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';
import 'package:wanderguard_companion_app/utils/geopoint_converter.dart';
import 'package:wanderguard_companion_app/widgets/dialogs/waiting_dialog.dart';
import 'package:wanderguard_companion_app/controllers/patient_data_controller.dart';
import 'package:wanderguard_companion_app/widgets/dialogs/confirmation_dialog.dart';
import 'package:wanderguard_companion_app/widgets/call_patient_button.dart'; // Import the CallPatientButton

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  static const route = '/patients';
  static const name = 'Patients';

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  void _deletePatient(String patientAcctId) async {
    final bool confirmed = await showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Delete Patient',
        content: 'Are you sure you want to delete this patient?',
        onConfirm: () {
          Navigator.of(context).pop(true);
        },
        onCancel: () {
          Navigator.of(context).pop(false);
        },
      ),
    );

    if (confirmed) {
      try {
        await PatientDataController.instance.deletePatient(patientAcctId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Patient deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete patient: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.tertiaryColor,
      appBar: AppBar(
        backgroundColor: CustomColors.tertiaryColor,
        surfaceTintColor: CustomColors.tertiaryColor,
        title: const Text('My Patients',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
              onPressed: () {
                GlobalRouter.I.router.push(AddPatientScreen.route);
              },
              icon: const Icon(
                Icons.add_rounded,
                size: 30,
              ))
        ],
      ),
      body: StreamBuilder<List<Patient>>(
        stream: PatientDataController.instance.getPatientsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return WaitingDialog(
              prompt: 'Loading...',
              color: CustomColors.primaryColor,
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final patients = snapshot.data;

          if (patients == null || patients.isEmpty) {
            return const Center(child: Text('No registered patients yet.'));
          }

          return ListView.builder(
            itemCount: patients.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final patient = patients[index];
              return FutureBuilder<String>(
                future:
                    GeoPointConverter.geoPointToAddress(patient.lastLocTracked),
                builder: (context, lastLocSnapshot) {
                  final address =
                      lastLocSnapshot.data ?? 'Fetching location...';

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Stack(
                      children: [
                        Card(
                          color: CustomColors.secondaryColor,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: CachedNetworkImage(
                                    imageUrl: patient.photoUrl,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        WaitingDialog(
                                      color: CustomColors.primaryColor,
                                      prompt: '',
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${patient.firstName} ${patient.lastName}',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        PatientDataController.instance
                                            .setPatient(patient);
                                        GlobalRouter.I.router
                                            .push(EditPatientScreen.route);
                                      },
                                      child: SvgPicture.asset(
                                        'lib/assets/icons/edit-patient-icon.svg',
                                        width: 20,
                                        height: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                buildPatientInfo(
                                    'Age:',
                                    calculateAge(patient.dateOfBirth)
                                        .toString()),
                                buildPatientInfo(
                                    'Address:', patient.homeAddress),
                                buildPatientInfo(
                                    'Contact No:', patient.contactNo),
                                buildPatientInfo(
                                    'Status:', patient.acctStatus.name),
                                buildPatientInfo('Last Location:', address),
                                const SizedBox(height: 24),
                                MaterialButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  textColor: CustomColors.secondaryColor,
                                  color: CustomColors.primaryColor,
                                  minWidth: double.infinity,
                                  height: 50,
                                  onPressed: () {
                                    GlobalRouter.I.router.go(HomeScreen.route);
                                  },
                                  child: const Text(
                                    'Locate',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Static button behind the row of call patient buttons
                                    Container(
                                      width: double.infinity,
                                      height: 50,
                                      margin: const EdgeInsets.only(
                                          top:
                                              20), // Adjust the margin to align with the row
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: CustomColors
                                              .primaryColor, // Button color
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: const Text(
                                          'Call Patient',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    // Row of CallPatientButton widgets
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        CallPatientButton(
                                          patientAcctId: patient.patientAcctId,
                                          patientName:
                                              '${patient.firstName} ${patient.lastName}',
                                          callType: CallType.videoCall,
                                          opacity: 0.0,
                                        ),
                                        CallPatientButton(
                                          patientAcctId: patient.patientAcctId,
                                          patientName:
                                              '${patient.firstName} ${patient.lastName}',
                                          callType: CallType.videoCall,
                                          opacity: 0.0,
                                        ),
                                        CallPatientButton(
                                          patientAcctId: patient.patientAcctId,
                                          patientName:
                                              '${patient.firstName} ${patient.lastName}',
                                          callType: CallType.videoCall,
                                          opacity: 0.0,
                                        ),
                                        CallPatientButton(
                                          patientAcctId: patient.patientAcctId,
                                          patientName:
                                              '${patient.firstName} ${patient.lastName}',
                                          callType: CallType.videoCall,
                                          opacity: 0.0,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 30,
                          right: 26,
                          child: GestureDetector(
                            onTap: () {
                              _deletePatient(patient.patientAcctId);
                            },
                            child: SvgPicture.asset(
                              'lib/assets/icons/delete-patient.svg',
                              width: 20,
                              height: 20,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

Widget buildPatientInfo(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

int calculateAge(DateTime birthDate) {
  DateTime today = DateTime.now();
  int age = today.year - birthDate.year;
  if (today.month < birthDate.month ||
      (today.month == birthDate.month && today.day < birthDate.day)) {
    age--;
  }
  return age;
}
