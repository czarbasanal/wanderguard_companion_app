import 'package:dynamic_multi_step_form/dynamic_multi_step_form.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wanderguard_companion_app/screens/onboarding/onboarding_screen.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderguard_companion_app/utils/size_config.dart';

import '../../controllers/auth_controller.dart';
import '../../routing/router.dart';
import '../../services/information_service.dart';
import '../../widgets/dialogs/waiting_dialog.dart';
import '../home/home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  static const String route = "/signup";
  static const String name = "Sign up";

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
      backgroundColor: CustomColors.secondaryColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: CustomColors.secondaryColor,
        surfaceTintColor: CustomColors.secondaryColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            size: 20,
          ),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              context.go(OnBoardingScreen.route);
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
          : SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    height: SizeConfig.screenHeight * 0.85,
                    width: SizeConfig.screenWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                                'lib/assets/icons/wanderguard-logo-small.svg'),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Row(
                          children: [
                            Text('Sign Up',
                                style: GoogleFonts.poppins(
                                    fontSize: 3 * SizeConfig.textMultiplier,
                                    color: CustomColors.primaryColor,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Expanded(
                          // height: SizeConfig.screenHeight * 0.5,
                          child: Column(
                            children: [
                              Expanded(
                                child: DynamicForm(
                                  formPadding: const EdgeInsets.all(0),
                                  formIndicatorPadding: const EdgeInsets.only(
                                      top: 15, left: 0, right: 0, bottom: 15),
                                  signupConfig!,
                                  childElementList: [],
                                  dynamicFormKey: _formKeyNew,
                                  finalSubmitCallBack: (int currentPage,
                                      Map<String, dynamic> data) async {
                                    try {
                                      String firstName =
                                          data['0']['first_name'] ?? '';
                                      String lastName =
                                          data['0']['last_name'] ?? '';
                                      String contactNo =
                                          data['0']['contact_no'] ?? '';
                                      String street = data['1']['street'] ?? '';
                                      String barangay =
                                          data['1']['barangay'] ?? '';
                                      String city = data['1']['city'] ?? '';
                                      String province =
                                          data['1']['province'] ?? '';
                                      String postalCode =
                                          data['1']['postal_code'] ?? '';

                                      String email = data['2']['email'] ?? '';
                                      String password =
                                          data['2']['password'] ?? '';

                                      String address =
                                          '$street, $barangay, $city, $province, $postalCode';

                                      GeoPoint currentLocation =
                                          const GeoPoint(0, 0);

                                      await WaitingDialog.show(
                                        context,
                                        future:
                                            AuthController.instance.register(
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
                                        GlobalRouter.I.router
                                            .go(HomeScreen.route);
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
                              MaterialButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                textColor: CustomColors.secondaryColor,
                                color: CustomColors.primaryColor,
                                minWidth: double.infinity,
                                height: 55,
                                onPressed: () {
                                  _formKeyNew.currentState!
                                      .nextStepCustomClick();
                                },
                                child: const Text(
                                  'Next',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
