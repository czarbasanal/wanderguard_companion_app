import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wanderguard_companion_app/models/patient.model.dart';
import 'package:wanderguard_companion_app/controllers/patient_data_controller.dart';
import 'package:wanderguard_companion_app/screens/profile/backup_companions/add_backup_screen.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';
import 'package:wanderguard_companion_app/utils/geopoint_converter.dart';
import 'package:wanderguard_companion_app/widgets/dialogs/waiting_dialog.dart';
import 'package:wanderguard_companion_app/routing/router.dart';

class SelectPatientScreen extends StatefulWidget {
  const SelectPatientScreen({super.key});

  static const String route = "/select_patient";
  static const String name = "Select Patient";

  @override
  State<SelectPatientScreen> createState() => _SelectPatientScreenState();
}

class _SelectPatientScreenState extends State<SelectPatientScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: CustomColors.secondaryColor,
        surfaceTintColor: CustomColors.secondaryColor,
        centerTitle: true,
        title: const Text(
          "Select Patient",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            size: 20,
          ),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: StreamBuilder<List<Patient>>(
        stream: PatientDataController.instance.getPatientsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: WaitingDialog(
                prompt: 'Loading Patients...',
                color: CustomColors.primaryColor,
              ),
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
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final patient = patients[index];
              return ValueListenableBuilder<Patient?>(
                valueListenable: PatientDataController.instance
                    .getPatientNotifier(patient.patientAcctId),
                builder: (context, updatedPatient, child) {
                  if (updatedPatient == null) {
                    return Container();
                  }

                  return GestureDetector(
                    onTap: () {
                      final formData = {
                        'patientAcctId': updatedPatient.patientAcctId
                      };
                      GlobalRouter.I.router.push(AddBackupCompanionScreen.route,
                          extra: formData);
                    },
                    child: Card(
                      color: CustomColors.secondaryColor,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: updatedPatient.photoUrl,
                                width: 85,
                                height: 85,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => WaitingDialog(
                                  color: CustomColors.primaryColor,
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${updatedPatient.firstName} ${updatedPatient.lastName}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    updatedPatient.contactNo,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text(
                                    'Last Location:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  FutureBuilder<String>(
                                    future: GeoPointConverter.geoPointToAddress(
                                        updatedPatient.lastLocTracked),
                                    builder: (context, lastLocSnapshot) {
                                      final location = lastLocSnapshot.data ??
                                          'Fetching location...';
                                      return Text(
                                        location,
                                        style: const TextStyle(fontSize: 14),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
