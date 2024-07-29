import 'package:dynamic_multi_step_form/dynamic_multi_step_form.dart';
import 'package:go_router/go_router.dart';
import 'package:wanderguard_companion_app/routing/router.dart';
import 'package:wanderguard_companion_app/screens/patients/set_geofence_screen.dart';
import 'package:wanderguard_companion_app/services/information_service.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';
import 'package:wanderguard_companion_app/widgets/dialogs/waiting_dialog.dart';

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

  @override
  void initState() {
    super.initState();
    _loadFormJson();
  }

  Future<void> _loadFormJson() async {
    try {
      addPatientConfig = null;
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
            GlobalRouter.I.router.pop();
          },
        ),
      ),
      body: addPatientConfig == null
          ? Center(
              child: WaitingDialog(
                prompt: "Loading form...",
                color: CustomColors.primaryColor,
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
                          dynamicFormKey: _formKeyNew,
                          finalSubmitCallBack: (int currentPage,
                              Map<String, dynamic> data) async {
                            try {
                              final formData = {
                                'first_name': data['0']['first_name'] ?? '',
                                'last_name': data['0']['last_name'] ?? '',
                                'date_of_birth':
                                    data['0']['date_of_birth'] ?? '',
                                'contact_no': data['0']['contact_no'] ?? '',
                                'street': data['1']['street'] ?? '',
                                'barangay': data['1']['barangay'] ?? '',
                                'city': data['1']['city'] ?? '',
                                'province': data['1']['province'] ?? '',
                                'postal_code': data['1']['postal_code'] ?? '',
                                'email': data['2']['email'] ?? '',
                                'password': data['2']['password'] ?? '',
                              };
                              context.push(SetGeofenceScreen.route,
                                  extra: formData);

                              _formKeyNew.currentState!.formSubmitData.clear();
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
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textColor: CustomColors.secondaryColor,
                          color: CustomColors.primaryColor,
                          minWidth: double.infinity,
                          height: 55,
                          onPressed: () {
                            _formKeyNew.currentState!.nextStepCustomClick();
                          },
                          child: const Text(
                            'Next',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
