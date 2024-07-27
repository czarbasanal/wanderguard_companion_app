import "dart:async";
import "package:flutter/material.dart";
import "package:get_it/get_it.dart";
import "package:go_router/go_router.dart";
import "package:wanderguard_companion_app/screens/add_patient_screen.dart";
import "package:wanderguard_companion_app/screens/patient_list_screen.dart";
import "package:wanderguard_companion_app/screens/set_geofence_screen.dart";

import "../controllers/auth_controller.dart";
import "../enum/auth_state.enum.dart";
import "../screens/auth/signin_screen.dart";
import "../screens/auth/onboarding_screen.dart";
import "../screens/auth/signup_screen.dart";
import "../screens/home_screen.dart";
import "../screens/profile_screen.dart";
import "../screens/screen_wrapper.dart";

class GlobalRouter {
  static void initialize() {
    GetIt.instance.registerSingleton<GlobalRouter>(GlobalRouter());
  }

  static GlobalRouter get I => GetIt.instance<GlobalRouter>();

  late GoRouter router;
  late GlobalKey<NavigatorState> _rootNavigatorKey;
  late GlobalKey<NavigatorState> _shellNavigatorKey;

  FutureOr<String?> handleRedirect(
      BuildContext context, GoRouterState state) async {
    if (AuthController.instance.state == AuthState.authenticated) {
      if (state.matchedLocation == SigninScreen.route) {
        return HomeScreen.route;
      }
      if (state.matchedLocation == SignupScreen.route) {
        return HomeScreen.route;
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
              path: PatientListScreen.route,
              name: PatientListScreen.name,
              builder: (context, _) {
                return PatientListScreen();
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
          ],
          builder: (context, state, child) {
            return ScreenWrapper(
              child: child,
            );
          },
        ),
      ],
    );
  }
}
