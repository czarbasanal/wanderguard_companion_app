import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanderguard_companion_app/models/patient.model.dart';
import 'package:wanderguard_companion_app/controllers/patient_data_controller.dart';
import 'package:wanderguard_companion_app/state/homescreen_state.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';
import 'package:wanderguard_companion_app/widgets/dialogs/waiting_dialog.dart';
import 'package:wanderguard_companion_app/widgets/patient_card_small.dart';
import 'package:wanderguard_companion_app/services/location_service.dart';

class DraggablePatientList extends StatelessWidget {
  const DraggablePatientList({super.key});

  @override
  Widget build(BuildContext context) {
    final homeScreenState = Provider.of<HomeScreenState>(context);

    return StreamBuilder<List<Patient>>(
      stream: PatientDataController.instance.getPatientsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: WaitingDialog(
            prompt: 'Loading Patients...',
            color: CustomColors.primaryColor,
          ));
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

                return PatientCardSmall(
                  patient: updatedPatient,
                  onLocate: () => LocationService.instance
                      .locatePatient(homeScreenState, updatedPatient),
                  onCall: () {
                    // Call functionality
                  },
                  onTap: () {
                    homeScreenState.scrollableController
                        .animateTo(0.06,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut)
                        .then((_) {
                      homeScreenState.setSelectedPatient(updatedPatient);
                      homeScreenState.setShowFloatingCard(true);
                    });
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
