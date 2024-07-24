import "dart:async";
import "package:flutter/material.dart";
import "package:get_it/get_it.dart";
import "package:go_router/go_router.dart";
import "package:wanderguard_companion_app/screens/add_patient_screen.dart";
import "package:wanderguard_companion_app/screens/patient_list_screen.dart";

import "../controllers/auth_controller.dart";
import "../enum/auth_state.enum.dart";
import "../screens/auth/login_screen.dart";
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
      if (state.matchedLocation == LoginScreen.route) {
        return HomeScreen.route;
      }
      if (state.matchedLocation == SignupScreen.route) {
        return HomeScreen.route;
      }
      return null;
    }
    if (AuthController.instance.state != AuthState.authenticated) {
      if (state.matchedLocation == LoginScreen.route) {
        return null;
      }
      if (state.matchedLocation == SignupScreen.route) {
        return null;
      }
      return OnboardingScreen.route;
    }
    return null;
  }

  GlobalRouter() {
    _rootNavigatorKey = GlobalKey<NavigatorState>();
    _shellNavigatorKey = GlobalKey<NavigatorState>();
    router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: OnboardingScreen.route,
      redirect: handleRedirect,
      refreshListenable: AuthController.instance,
      routes: [
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: OnboardingScreen.route,
          name: OnboardingScreen.name,
          builder: (context, _) {
            return const OnboardingScreen();
          },
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: LoginScreen.route,
          name: LoginScreen.name,
          builder: (context, _) {
            return const LoginScreen();
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
              path: AddPatientScreen.route,
              name: AddPatientScreen.name,
              builder: (context, _) {
                return AddPatientScreen();
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
