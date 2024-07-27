import 'package:dynamic_multi_step_form/dynamic_multi_step_form.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';
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
  // PatientDataController.initialize();
  FirestoreService.initialize();
  await AuthController.instance.loadSession();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
