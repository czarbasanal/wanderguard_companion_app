import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:wanderguard_companion_app/controllers/patient_data_controller.dart';
import 'package:wanderguard_companion_app/screens/notifications/backup_companion_notification_screen.dart';
import 'package:wanderguard_companion_app/screens/patients/add_patient_screen.dart';
import 'package:wanderguard_companion_app/screens/notifications/notification_screen.dart';
import 'package:wanderguard_companion_app/screens/patients/edit_patient_screen.dart';
import 'package:wanderguard_companion_app/screens/patients/patient_list_screen.dart';
import 'package:wanderguard_companion_app/screens/patients/set_geofence_screen.dart';
import 'package:wanderguard_companion_app/screens/profile/backup_companions/add_backup_screen.dart';
import 'package:wanderguard_companion_app/screens/profile/backup_companions/backup_list_screen.dart';
import 'package:wanderguard_companion_app/screens/profile/backup_companions/select_patient.dart';

import '../controllers/auth_controller.dart';
import '../enum/auth_state.enum.dart';
import '../screens/auth/signin_screen.dart';
import '../screens/backup_companion_screen_wrapper.dart';
import '../screens/home/backup_companion_home_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/backup_companion_profile_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/screen_wrapper.dart';
import 'account_type_checker.dart';

class GlobalRouter {
  static void initialize() {
    GetIt.instance.registerSingleton<GlobalRouter>(GlobalRouter());
  }

  static GlobalRouter get I => GetIt.instance<GlobalRouter>();

  late GoRouter router;
  late GlobalKey<NavigatorState> _rootNavigatorKey;
  late GlobalKey<NavigatorState> _shellNavigatorKey;

  final ValueNotifier<int> selectedIndexNotifier = ValueNotifier<int>(0);
  String? _acctType;

  FutureOr<String?> handleRedirect(
      BuildContext context, GoRouterState state) async {
    if (AuthController.instance.state == AuthState.authenticated) {
      _acctType = await getCurrentUserAccountType();
      if (_acctType == 'primary_companion') {
        if (state.matchedLocation == SigninScreen.route) {
          return HomeScreen.route;
        }
        if (state.matchedLocation == SignupScreen.route) {
          return HomeScreen.route;
        }
      } else if (_acctType == 'backup_companion') {
        if (state.matchedLocation == SigninScreen.route) {
          return BackupCompanionHomeScreen.route;
        }
        if (state.matchedLocation == SignupScreen.route) {
          return BackupCompanionHomeScreen.route;
        }
      }
      return null;
    }
    if (AuthController.instance.state != AuthState.authenticated) {
      if (state.matchedLocation == SigninScreen.route) {
        return null;
      }
      if (state.matchedLocation == SignupScreen.route) {
        return null;
      }
      return OnBoardingScreen.route;
    }
    return null;
  }

  GlobalRouter() {
    _rootNavigatorKey = GlobalKey<NavigatorState>();
    _shellNavigatorKey = GlobalKey<NavigatorState>();
    router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: OnBoardingScreen.route,
      redirect: handleRedirect,
      refreshListenable: AuthController.instance,
      routes: [
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: OnBoardingScreen.route,
          name: OnBoardingScreen.name,
          builder: (context, _) {
            return const OnBoardingScreen();
          },
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: SigninScreen.route,
          name: SigninScreen.name,
          builder: (context, _) {
            return const SigninScreen();
          },
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: SignupScreen.route,
          name: SignupScreen.name,
          builder: (context, _) {
            return const SignupScreen();
          },
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: SetGeofenceScreen.route,
          name: SetGeofenceScreen.name,
          builder: (context, state) {
            final Map<String, dynamic> formData =
                state.extra as Map<String, dynamic>;
            return SetGeofenceScreen(formData: formData);
          },
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: AddPatientScreen.route,
          name: AddPatientScreen.name,
          builder: (context, state) {
            return AddPatientScreen();
          },
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: EditPatientScreen.route,
          name: EditPatientScreen.name,
          builder: (context, state) {
            return EditPatientScreen(
                patient:
                    PatientDataController.instance.patientModelNotifier.value!);
          },
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: BackupCompanionListScreen.route,
          name: BackupCompanionListScreen.name,
          builder: (context, state) {
            return BackupCompanionListScreen();
          },
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: AddBackupCompanionScreen.route,
          name: AddBackupCompanionScreen.name,
          builder: (context, state) {
            final initialFormData = state.extra as Map<String, dynamic>;
            return AddBackupCompanionScreen(initialFormData: initialFormData);
          },
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: SelectPatientScreen.route,
          name: SelectPatientScreen.name,
          builder: (context, state) {
            return SelectPatientScreen();
          },
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          routes: [
            GoRoute(
              parentNavigatorKey: _shellNavigatorKey,
              path: HomeScreen.route,
              name: HomeScreen.name,
              builder: (context, _) {
                return HomeScreen();
              },
            ),
            GoRoute(
              parentNavigatorKey: _shellNavigatorKey,
              path: BackupCompanionHomeScreen.route,
              name: BackupCompanionHomeScreen.name,
              builder: (context, _) {
                return BackupCompanionHomeScreen();
              },
            ),
            GoRoute(
              parentNavigatorKey: _shellNavigatorKey,
              path: PatientListScreen.route,
              name: PatientListScreen.name,
              builder: (context, _) {
                return PatientListScreen();
              },
            ),
            GoRoute(
              parentNavigatorKey: _shellNavigatorKey,
              path: NotificationScreen.route,
              name: NotificationScreen.name,
              builder: (context, _) {
                return NotificationScreen();
              },
            ),
            GoRoute(
              parentNavigatorKey: _shellNavigatorKey,
              path: BackupCompanionNotificationScreen.route,
              name: BackupCompanionNotificationScreen.name,
              builder: (context, _) {
                return BackupCompanionNotificationScreen();
              },
            ),
            GoRoute(
              parentNavigatorKey: _shellNavigatorKey,
              path: ProfileScreen.route,
              name: ProfileScreen.name,
              builder: (context, _) {
                return ProfileScreen();
              },
            ),
            GoRoute(
              parentNavigatorKey: _shellNavigatorKey,
              path: BackupCompanionProfileScreen.route,
              name: BackupCompanionProfileScreen.name,
              builder: (context, _) {
                return BackupCompanionProfileScreen();
              },
            ),
          ],
          builder: (context, state, child) {
            // Update the selected index based on the current route
            final location = state.uri.toString();
            List<String> routes;

            if (_acctType == 'backup_companion') {
              routes = [
                BackupCompanionHomeScreen.route,
                BackupCompanionNotificationScreen.route,
                BackupCompanionProfileScreen.route,
              ];
            } else {
              routes = [
                HomeScreen.route,
                PatientListScreen.route,
                NotificationScreen.route,
                ProfileScreen.route,
              ];
            }

            final routeIndex = routes.indexOf(location);
            if (routeIndex != -1) {
              selectedIndexNotifier.value = routeIndex;
            } else {
              selectedIndexNotifier.value = 0;
              GlobalRouter.I.router.go(routes[0]);
            }

            if (_acctType == 'backup_companion') {
              return BackupCompanionScreenWrapper(
                child: child,
                selectedIndexNotifier: selectedIndexNotifier,
              );
            } else {
              return ScreenWrapper(
                child: child,
                selectedIndexNotifier: selectedIndexNotifier,
              );
            }
          },
        ),
      ],
    );
  }
}
