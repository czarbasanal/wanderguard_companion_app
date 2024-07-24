import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_multi_step_form/dynamic_multi_step_form.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../controllers/patient_data_controller.dart';
import '../../utils/colors.dart';
import '../../widgets/dialogs/waiting_dialog.dart';
import '../services/information_service.dart';
import '../widgets/geofence_widget.dart';
import '../widgets/custom_form_field.dart';

class AddPatientScreen extends StatefulWidget {
  static const String route = "/add_patient";
  static const String name = "Add Patient";

  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKeyNew = GlobalKey<DynamicFormState>();
  int currentPageIndex = 0;
  String? addPatientConfig;

  LatLng? geofenceCenter;
  double? geofenceRadius;

  @override
  void initState() {
    super.initState();
    _loadFormJson();
  }

  Future<void> _loadFormJson() async {
    try {
      addPatientConfig =
          await localJsonRw.localRead(fileName: "add_patient_form.json");
      setState(() {});
    } catch (error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Info.showSnackbarMessage(
          context,
          message: error.toString(),
          actionLabel: 'Close',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Add Patient",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            size: 20,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: addPatientConfig == null
          ? const Center(
              child: WaitingDialog(
                prompt: "Loading form...",
                color: Colors.deepPurpleAccent,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: DynamicForm(
                          addPatientConfig!,
                          childElementList: [
                            [
                              ChildElement(
                                index: 2,
                                childElement: CustomFormField(
                                  stepIndex:
                                      2, // Assuming form3 is the third step
                                  fieldIndex:
                                      0, // Assuming this is the position you want the map to appear
                                  builder: (context, key, field, isValid) {
                                    return GoogleMapGeofenceWidget(
                                      onGeofenceSet: (center, radius) {
                                        setState(() {
                                          geofenceCenter = center;
                                          geofenceRadius = radius;
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                            ]
                          ],
                          dynamicFormKey: _formKeyNew,
                          finalSubmitCallBack: (int currentPage,
                              Map<String, dynamic> data) async {
                            try {
                              String firstName = data['0']['first_name'] ?? '';
                              String lastName = data['0']['last_name'] ?? '';
                              String dateOfBirthStr =
                                  data['0']['date_of_birth'] ?? '';
                              String contactNo = data['0']['contact_no'] ?? '';
                              String street = data['1']['street'] ?? '';
                              String barangay = data['1']['barangay'] ?? '';
                              String city = data['1']['city'] ?? '';
                              String province = data['1']['province'] ?? '';
                              String email = data['3']['email'] ?? '';
                              String password = data['3']['password'] ?? '';

                              DateTime dateOfBirth =
                                  DateTime.parse(dateOfBirthStr);

                              String address =
                                  '$street, $barangay, $city, $province';

                              GeoPoint currentLocation = const GeoPoint(0, 0);

                              // Use PatientDataController to add patient
                              await WaitingDialog.show(
                                context,
                                future: PatientDataController().addPatient(
                                  firstName: firstName,
                                  lastName: lastName,
                                  dateOfBirth: dateOfBirth,
                                  contactNo: contactNo,
                                  address: address,
                                  lastLocTracked: currentLocation,
                                  lastLocUpdated: DateTime.now(),
                                  geofenceCenter: geofenceCenter,
                                  geofenceRadius: geofenceRadius,
                                  email: email,
                                  password: password,
                                ),
                                prompt: 'Adding patient...',
                              );
                              if (mounted) {
                                // GlobalRouter.I.router.go(HomeScreen.route);
                              }
                            } catch (e) {
                              Info.showSnackbarMessage(
                                context,
                                message: e.toString(),
                                actionLabel: 'Close',
                              );
                            }
                          },
                          currentStepCallBack: ({
                            int? currentIndex,
                            Map<String, dynamic>? formSubmitData,
                            Map<String, dynamic>? formInformation,
                            bool? isBack = false,
                          }) {
                            setState(() {
                              currentPageIndex = currentIndex!;
                            });
                          },
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 15)
                            .copyWith(bottom: 8),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            backgroundColor: CustomColors.primaryColor,
                            maximumSize:
                                Size(MediaQuery.of(context).size.width, 50),
                            minimumSize:
                                Size(MediaQuery.of(context).size.width, 50),
                          ),
                          clipBehavior: Clip.hardEdge,
                          onPressed: () async {
                            _formKeyNew.currentState!.nextStepCustomClick();
                          },
                          child: const Text(
                            'Next',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
