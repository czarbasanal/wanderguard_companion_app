import 'package:dynamic_multi_step_form/dynamic_multi_step_form.dart';
import 'package:go_router/go_router.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../controllers/auth_controller.dart';
import '../../routing/router.dart';
import '../../services/information_service.dart';
import '../../widgets/dialogs/waiting_dialog.dart';
import '../home_screen.dart';
import 'onboarding_screen.dart';

class SignupScreen extends StatefulWidget {
  static const String route = "/signup";
  static const String name = "Sign up";

  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKeyNew = GlobalKey<DynamicFormState>();
  int currentPageIndex = 0;
  String? signupConfig;

  @override
  void initState() {
    super.initState();
    _loadFormJson();
  }

  Future<void> _loadFormJson() async {
    try {
      signupConfig =
          await localJsonRw.localRead(fileName: "signup_form_config.json");
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
          "Register",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            size: 20,
          ),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              context.go(OnboardingScreen.route);
            }
          },
        ),
      ),
      body: signupConfig == null
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
                          signupConfig!,
                          childElementList: [],
                          dynamicFormKey: _formKeyNew,
                          finalSubmitCallBack: (int currentPage,
                              Map<String, dynamic> data) async {
                            try {
                              String firstName = data['0']['first_name'] ?? '';
                              String lastName = data['0']['last_name'] ?? '';
                              String contactNo = data['0']['contact_no'] ?? '';
                              String street = data['1']['street'] ?? '';
                              String barangay = data['1']['barangay'] ?? '';
                              String city = data['1']['city'] ?? '';
                              String province = data['1']['province'] ?? '';
                              String postalCode =
                                  data['1']['postal_code'] ?? '';

                              String email = data['2']['email'] ?? '';
                              String password = data['2']['password'] ?? '';

                              String address =
                                  '$street, $barangay, $city, $province, $postalCode';

                              GeoPoint currentLocation = const GeoPoint(0, 0);

                              await WaitingDialog.show(
                                context,
                                future: AuthController.instance.register(
                                  email,
                                  password,
                                  firstName,
                                  lastName,
                                  contactNo,
                                  address,
                                  currentLocation,
                                ),
                                prompt: 'Signing up...',
                              );
                              if (mounted) {
                                GlobalRouter.I.router.go(HomeScreen.route);
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
