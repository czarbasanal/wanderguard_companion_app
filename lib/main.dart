import 'package:dynamic_multi_step_form/dynamic_multi_step_form.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wanderguard_companion_app/controllers/backup_companion_data_controller.dart';
import 'package:wanderguard_companion_app/controllers/patient_data_controller.dart';
import 'package:wanderguard_companion_app/services/background_service.dart';
import 'package:wanderguard_companion_app/services/location_service.dart';
import 'package:wanderguard_companion_app/services/notification_service.dart';
import 'package:wanderguard_companion_app/services/permission_service.dart';
import 'package:wanderguard_companion_app/services/shared_preferences_service.dart';
import 'package:wanderguard_companion_app/state/homescreen_state.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';
import 'package:wanderguard_companion_app/utils/form_textfield_config.dart';
import 'package:wanderguard_companion_app/utils/size_config.dart';
import 'controllers/auth_controller.dart';
import 'controllers/companion_data_controller.dart';

import 'firebase_options.dart';
import 'routing/router.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AuthController.initialize();
  GlobalRouter.initialize();
  CompanionDataController.initialize();
  BackupCompanionDataController.initialize();
  PatientDataController.initialize();
  FirestoreService.initialize();
  LocationService.initialize();
  SharedPreferenceService.initialize();
  await PermissionService.initialize();
  await NotificationService.initialize();
  await AuthController.instance.loadSession();
  HomeScreenState.initialize();
  startBackgroundService();

  ConfigurationSetting.instance.setTextFieldViewConfig =
      FormTextFieldConfig.textFieldConfiguration;
  ConfigurationSetting.instance.setTelTextFieldViewConfig =
      FormTextFieldConfig.telTextFieldConfiguration;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeScreenState()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Builder(
      builder: (context) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: GlobalRouter.I.router,
          title: 'WanderGuard Companion App',
          theme: ThemeData(
            colorScheme:
                ColorScheme.fromSeed(seedColor: CustomColors.tertiaryColor),
            textTheme: GoogleFonts.poppinsTextTheme(
              Theme.of(context).textTheme,
            ),
            useMaterial3: true,
          ),
        );
      },
    );
  }
}
