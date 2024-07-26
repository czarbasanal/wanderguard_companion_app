import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wanderguard_companion_app/models/patient.model.dart';
import 'package:wanderguard_companion_app/routing/router.dart';
import 'package:wanderguard_companion_app/screens/add_patient_screen.dart';
import 'package:wanderguard_companion_app/services/firestore_service.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';
import 'package:wanderguard_companion_app/widgets/dialogs/waiting_dialog.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  static const route = '/patients';
  static const name = 'Patients';

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
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
      body: FutureBuilder<List<Patient>>(
        future: FirestoreService.instance.getPatients(),
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
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
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
                          child: Image.network(
                            patient.photoUrl,
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              onTap: () {},
                              child: SvgPicture.asset(
                                'lib/assets/icons/edit-patient-icon.svg',
                                width: 20,
                                height: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        buildPatientInfo('Age:',
                            calculateAge(patient.dateOfBirth).toString()),
                        buildPatientInfo('Address:', patient.homeAddress),
                        buildPatientInfo('Contact No:', patient.contactNo),
                        buildPatientInfo('Status:', patient.acctStatus.name),
                        buildPatientInfo('Last Location:',
                            patient.lastLocTracked.toString()),
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
                            // Implement locate patient here
                          },
                          child: const Text(
                            'Locate',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: CustomColors.primaryColor,
                            side: BorderSide(
                                color:
                                    CustomColors.primaryColor), // Border color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            minimumSize:
                                const Size(double.infinity, 50), // Text color
                          ),
                          onPressed: () {
                            // Implement call patient here
                          },
                          child: const Text(
                            'Call Patient',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
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
    padding: const EdgeInsets.symmetric(vertical: 2.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 5),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
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
