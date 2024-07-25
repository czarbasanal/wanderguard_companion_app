import 'package:flutter/material.dart';
import 'package:wanderguard_companion_app/models/patient.model.dart';
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
      appBar: AppBar(
        title: const Text('My Patients',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
              onPressed: () {},
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
              prompt: 'Loading patients...',
              color: CustomColors.primaryColor,
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final patients = snapshot.data;

          if (patients == null || patients.isEmpty) {
            return Center(child: Text('No registered patients yet.'));
          }

          return ListView.builder(
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final patient = patients[index];
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(patient.photoUrl),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${patient.firstName} ${patient.lastName}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                // Edit patient functionality
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        buildPatientInfo('Age:',
                            calculateAge(patient.dateOfBirth).toString()),
                        buildPatientInfo('Address:', patient.homeAddress),
                        buildPatientInfo('Contact No:', patient.contactNo),
                        buildPatientInfo('Last Location:',
                            patient.lastLocTracked.toString()),
                        buildPatientInfo('Last Online:', 'static data'),
                        buildPatientInfo('Transfer Status:', 'static data'),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            // Transfer patient functionality
                          },
                          child: Text(
                            'transfer patient',
                            style: TextStyle(
                              backgroundColor: CustomColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            // Locate patient functionality
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.primaryColor,
                          ),
                          child: Text('Locate'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            // Call patient functionality
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.primaryColor,
                          ),
                          child: Text('Call Patient'),
                        ),
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
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          style: TextStyle(
              fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
        ),
        SizedBox(width: 5),
        Text(value),
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
