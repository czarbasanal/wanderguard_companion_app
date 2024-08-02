import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_multi_step_form/dynamic_multi_step_form.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:wanderguard_companion_app/controllers/backup_companion_data_controller.dart';
import 'package:wanderguard_companion_app/controllers/companion_data_controller.dart';
import 'package:wanderguard_companion_app/enum/account_status.enum.dart';
import 'package:wanderguard_companion_app/enum/account_type.enum.dart';
import 'package:wanderguard_companion_app/models/backup_companion.model.dart';
import 'package:wanderguard_companion_app/routing/router.dart';
import 'package:wanderguard_companion_app/services/information_service.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';
import 'package:wanderguard_companion_app/widgets/dialogs/waiting_dialog.dart';

class AddBackupCompanionScreen extends StatefulWidget {
  static const String route = "/add_backup_companion";
  static const String name = "Add Backup Companion";

  final Map<String, dynamic> initialFormData;

  const AddBackupCompanionScreen({super.key, required this.initialFormData});

  @override
  State<AddBackupCompanionScreen> createState() =>
      _AddBackupCompanionScreenState();
}

class _AddBackupCompanionScreenState extends State<AddBackupCompanionScreen> {
  final _formKeyNew = GlobalKey<DynamicFormState>();
  int currentPageIndex = 0;
  String? addBackupCompanionConfig;

  @override
  void initState() {
    super.initState();
    _loadFormJson();
  }

  Future<void> _loadFormJson() async {
    try {
      addBackupCompanionConfig = null;
      addBackupCompanionConfig = await localJsonRw.localRead(
          fileName: "add_backup_companion_form.json");
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

  Future<void> _handleSubmit(Map<String, dynamic> data) async {
    print('Data: $data');
    try {
      // Show waiting dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WaitingDialog(
            prompt: 'Adding Backup Companion...',
            color: CustomColors.secondaryColor,
          );
        },
      );

      // Combine initial form data with the submitted form data
      final combinedData = {
        ...widget.initialFormData,
        'first_name': data['0']['first_name'],
        'last_name': data['0']['last_name'],
        'contact_no': data['0']['contact_no'],
        'street': data['1']['street'],
        'barangay': data['1']['barangay'],
        'city': data['1']['city'],
        'province': data['1']['province'],
        'postal_code': data['1']['postal_code'],
        'email': data['2']['email'],
        'password': data['2']['password'],
        'profile_photo': data['2']['profile_photo'],
        'companionAcctId': CompanionDataController
            .instance.companionModelNotifier.value?.companionAcctId,
        'patientAcctId': widget.initialFormData['patientAcctId']
      };

      final address = '${combinedData['street'] ?? ''}, '
          '${combinedData['barangay'] ?? ''}, '
          '${combinedData['city'] ?? ''}, '
          '${combinedData['province'] ?? ''}, '
          '${combinedData['postal_code'] ?? ''}';

      String photoUrl = '';
      if (combinedData['profile_photo'] != null) {
        File photoFile = File(combinedData['profile_photo']);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('backup_companions_photos/${path.basename(photoFile.path)}');
        final uploadTask = storageRef.putFile(photoFile);
        final snapshot = await uploadTask.whenComplete(() {});
        photoUrl = await snapshot.ref.getDownloadURL();
      }

      final backupCompanion = BackupCompanion(
        backupCompanionAcctId: '',
        firstName: combinedData['first_name'] ?? '',
        lastName: combinedData['last_name'] ?? '',
        contactNo: combinedData['contact_no'] ?? '',
        address: address,
        email: combinedData['email'] ?? '',
        password: combinedData['password'] ?? '',
        photoUrl: photoUrl,
        companionAcctId: combinedData['companionAcctId'] ?? '',
        patientAcctId: combinedData['patientAcctId'] ?? '',
        acctType: AccountType.backupCompanion,
        acctStatus: AccountStatus.offline,
        currentLocation: GeoPoint(0, 0),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await BackupCompanionDataController.instance
          .addBackupCompanion(backupCompanion);

      Navigator.of(context).pop();

      GlobalRouter.I.router.pop();
      GlobalRouter.I.router.pop();
    } catch (e) {
      Navigator.of(context).pop();
      Info.showSnackbarMessage(
        context,
        message: e.toString(),
        actionLabel: 'Close',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: CustomColors.secondaryColor,
        surfaceTintColor: CustomColors.secondaryColor,
        centerTitle: true,
        title: const Text(
          "Add Backup Companion",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            size: 20,
          ),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: addBackupCompanionConfig == null
          ? Center(
              child: WaitingDialog(
                prompt: "Loading...",
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
                          addBackupCompanionConfig!,
                          dynamicFormKey: _formKeyNew,
                          finalSubmitCallBack: (int currentPage,
                              Map<String, dynamic> data) async {
                            await _handleSubmit(data);
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
