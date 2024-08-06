import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wanderguard_companion_app/enum/account_status.enum.dart';
import 'package:wanderguard_companion_app/enum/account_type.enum.dart';
import 'package:wanderguard_companion_app/enum/auth_state.enum.dart';
import 'package:wanderguard_companion_app/models/companion.model.dart';
import 'package:wanderguard_companion_app/models/backup_companion.model.dart';
import 'package:wanderguard_companion_app/controllers/companion_data_controller.dart';
import 'package:wanderguard_companion_app/controllers/backup_companion_data_controller.dart';
import 'package:wanderguard_companion_app/state/homescreen_state.dart';
import 'package:wanderguard_companion_app/state/backup_companion_homescreen_state.dart';

import '../routing/account_type_checker.dart';

class AuthController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static void initialize() {
    GetIt.instance.registerSingleton<AuthController>(AuthController());
  }

  static AuthController get instance => GetIt.instance<AuthController>();

  late StreamSubscription<User?> currentAuthedUser;

  AuthState state = AuthState.unauthenticated;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  listen() {
    currentAuthedUser = _auth.authStateChanges().listen(handleUserChanges);
  }

  void handleUserChanges(User? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      state = AuthState.unauthenticated;
      await prefs.remove('companionAcctId');
      await prefs.remove('backupCompanionAcctId');
    } else {
      state = AuthState.authenticated;
      final accountType = await getCurrentUserAccountType();
      if (accountType == 'primary_companion') {
        await prefs.setString('companionAcctId', user.uid);
      } else if (accountType == 'backup_companion') {
        await prefs.setString('backupCompanionAcctId', user.uid);
      }
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final accountType = await getCurrentUserAccountType();
      if (accountType == 'primary_companion') {
        final Companion? companion = await CompanionDataController.instance
            .getCompanion(userCredential.user!.uid);
        if (companion == null) {
          throw Exception('Invalid account type');
        }
        CompanionDataController.instance.setCompanion(companion);
      } else if (accountType == 'backup_companion') {
        final BackupCompanion? backupCompanion =
            await BackupCompanionDataController.instance
                .getBackupCompanion(userCredential.user!.uid);
        if (backupCompanion == null) {
          throw Exception('Invalid account type');
        }
        BackupCompanionDataController.instance
            .setBackupCompanion(backupCompanion);
      }

      state = AuthState.authenticated;
    } catch (e) {
      print('Error logging in user: $e');
      throw Exception('Failed to log in');
    }
  }

  Future<void> signInWithGoogle() async {
    GoogleSignInAccount? gSign = await _googleSignIn.signIn();
    if (gSign == null) throw Exception("No Signed in account");
    GoogleSignInAuthentication googleAuth = await gSign.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> register(
      String email,
      String password,
      String firstName,
      String lastName,
      String contactNo,
      String address,
      GeoPoint currentLocation) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final Companion newCompanion = Companion(
        companionAcctId: userCredential.user!.uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        address: address,
        currentLocation: currentLocation,
        contactNo: contactNo,
        photoUrl: '',
        acctType: AccountType.primaryCompanion,
        acctStatus: AccountStatus.offline,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await CompanionDataController.instance.addCompanion(newCompanion);
      CompanionDataController.instance.setCompanion(newCompanion);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> logout() async {
    if (_googleSignIn.currentUser != null) {
      _googleSignIn.signOut();
    }
    await _auth.signOut();
    CompanionDataController.instance.setCompanion(null);
    BackupCompanionDataController.instance.setBackupCompanion(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    HomeScreenState.instance.reset();
    BackupCompanionHomeScreenState.instance.reset();
  }

  Future<void> loadSession() async {
    listen();
    final prefs = await SharedPreferences.getInstance();
    String? companionAcctId = prefs.getString('companionAcctId');
    String? backupCompanionAcctId = prefs.getString('backupCompanionAcctId');
    if (companionAcctId != null) {
      try {
        final Companion? companion = await CompanionDataController.instance
            .getCompanion(companionAcctId);
        CompanionDataController.instance.setCompanion(companion);
        handleUserChanges(FirebaseAuth.instance.currentUser);
      } catch (e) {
        print('Error loading user session: $e');
        handleUserChanges(null);
      }
    } else if (backupCompanionAcctId != null) {
      try {
        final BackupCompanion? backupCompanion =
            await BackupCompanionDataController.instance
                .getBackupCompanion(backupCompanionAcctId);
        BackupCompanionDataController.instance
            .setBackupCompanion(backupCompanion);
        handleUserChanges(FirebaseAuth.instance.currentUser);
      } catch (e) {
        print('Error loading user session: $e');
        handleUserChanges(null);
      }
    } else {
      handleUserChanges(null);
    }
  }
}
