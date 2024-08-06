import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wanderguard_companion_app/models/patient.model.dart';
import 'package:wanderguard_companion_app/services/information_service.dart';
import 'package:wanderguard_companion_app/services/location_service.dart';
import 'package:wanderguard_companion_app/services/shared_preferences_service.dart';
import 'package:wanderguard_companion_app/state/homescreen_state.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';
import 'package:wanderguard_companion_app/utils/size_config.dart';
import 'package:wanderguard_companion_app/widgets/dialogs/waiting_dialog.dart';
import 'package:wanderguard_companion_app/widgets/google_map.dart';
import 'package:wanderguard_companion_app/widgets/patient_card_small.dart';

import '../../state/backup_companion_homescreen_state.dart';
import '../../widgets/backup_companion_draggable_patient_list.dart';

class BackupCompanionHomeScreen extends StatefulWidget {
  static const route = '/backup-companion-home';
  static const name = 'BackupCompanionHome';

  const BackupCompanionHomeScreen({super.key});

  @override
  _BackupCompanionHomeScreenState createState() =>
      _BackupCompanionHomeScreenState();
}

class _BackupCompanionHomeScreenState extends State<BackupCompanionHomeScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    final backupCompanionHomeScreenState =
        Provider.of<BackupCompanionHomeScreenState>(context, listen: false);

    LocationService.instance.getCurrentLocation().then((position) {
      backupCompanionHomeScreenState.setInitialPosition(CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 15,
      ));
      print('Initial Position: $position');
      backupCompanionHomeScreenState.setLoadingLocation(false);
      LocationService.instance.updateCompanionLocation(position);
    }).catchError((e) {
      backupCompanionHomeScreenState.setLoadingLocation(false);
      Info.showSnackbarMessage(context, message: e.toString(), label: "Error");
    });

    _loadMarkers(backupCompanionHomeScreenState);

    backupCompanionHomeScreenState.scrollableController.addListener(() {
      backupCompanionHomeScreenState.isSheetDragged.value =
          backupCompanionHomeScreenState.scrollableController.size > 0.06;
      if (backupCompanionHomeScreenState.isSheetDragged.value) {
        backupCompanionHomeScreenState.setShowFloatingCard(false);
      }
    });
  }

  Future<void> _loadMarkers(
      BackupCompanionHomeScreenState backupCompanionHomeScreenState) async {
    List<Marker> savedMarkers =
        await SharedPreferenceService.instance.loadMarkers();
    backupCompanionHomeScreenState.setMarkers(savedMarkers.toSet());
  }

  @override
  Widget build(BuildContext context) {
    final backupCompanionHomeScreenState =
        Provider.of<BackupCompanionHomeScreenState>(context);

    return Scaffold(
      backgroundColor: CustomColors.tertiaryColor,
      body: Stack(
        children: [
          IndexedStack(
            index: 0,
            children: [
              backupCompanionHomeScreenState.loadingLocation
                  ? WaitingDialog(
                      prompt: "Loading...",
                      color: CustomColors.primaryColor,
                    )
                  : GoogleMapWidget(),
            ],
          ),
          DraggableScrollableSheet(
            controller: backupCompanionHomeScreenState.scrollableController,
            initialChildSize: 0.06,
            minChildSize: 0.06,
            maxChildSize: 0.8,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: CustomColors.tertiaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 4,
                      blurRadius: 4,
                      offset: const Offset(0, 3),
                    )
                  ],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: SizedBox(
                    height: SizeConfig.screenHeight * 0.715,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 24,
                        ),
                        ValueListenableBuilder(
                          valueListenable:
                              backupCompanionHomeScreenState.isSheetDragged,
                          builder: (context, isDragged, child) {
                            return Container(
                              width: SizeConfig.screenWidth * 0.15,
                              height: 3,
                              decoration: BoxDecoration(
                                color: isDragged
                                    ? CustomColors.primaryColor
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(50),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                "Patients List",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Expanded(
                            child: BackupCompanionDraggablePatientList()),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: SizeConfig.screenHeight * 0.07,
            child: ValueListenableBuilder<bool>(
              valueListenable: backupCompanionHomeScreenState.showFloatingCard,
              builder: (context, showCard, child) {
                return AnimatedOpacity(
                  opacity: showCard ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Visibility(
                    visible: showCard,
                    child: ValueListenableBuilder<Patient?>(
                      valueListenable:
                          backupCompanionHomeScreenState.selectedPatient,
                      builder: (context, patient, child) {
                        if (patient == null) return const SizedBox.shrink();
                        return PatientCardSmall(
                          patient: patient,
                          onLocate: () => LocationService.instance
                              .locatePatient(
                                  backupCompanionHomeScreenState, patient),
                          onCall: () {
                            // Call functionality
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: backupCompanionHomeScreenState.isLoadingMarker,
            builder: (context, isLoading, child) {
              return isLoading
                  ? Container(
                      color: Colors.white.withOpacity(0.8),
                      child: Center(
                        child: WaitingDialog(
                          prompt: "Locating Patient...",
                          color: CustomColors.primaryColor,
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
