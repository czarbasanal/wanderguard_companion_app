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
import 'package:wanderguard_companion_app/widgets/draggable_patient_list.dart';
import 'package:wanderguard_companion_app/widgets/google_map.dart';
import 'package:wanderguard_companion_app/widgets/patient_card_small.dart';

class HomeScreen extends StatefulWidget {
  static const route = '/home';
  static const name = 'Home';

  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final homeScreenState =
        Provider.of<HomeScreenState>(context, listen: false);

    LocationService.instance.getCurrentLocation().then((position) {
      homeScreenState.setInitialPosition(CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 15,
      ));
      homeScreenState.setLoadingLocation(false);
      LocationService.instance.updateCompanionLocation(position);
    }).catchError((e) {
      homeScreenState.setLoadingLocation(false);
      Info.showSnackbarMessage(context, message: e.toString(), label: "Error");
    });

    _loadMarkers(homeScreenState);

    homeScreenState.scrollableController.addListener(() {
      homeScreenState.isSheetDragged.value =
          homeScreenState.scrollableController.size > 0.06;
      if (homeScreenState.isSheetDragged.value) {
        homeScreenState.setShowFloatingCard(false);
      }
    });
  }

  Future<void> _loadMarkers(HomeScreenState homeScreenState) async {
    List<Marker> savedMarkers =
        await SharedPreferenceService.instance.loadMarkers();
    homeScreenState.setMarkers(savedMarkers.toSet());
  }

  @override
  Widget build(BuildContext context) {
    final homeScreenState = Provider.of<HomeScreenState>(context);

    return Scaffold(
      backgroundColor: CustomColors.tertiaryColor,
      body: Stack(
        children: [
          IndexedStack(
            index: 0, // Only show the map at index 0
            children: [
              homeScreenState.loadingLocation
                  ? WaitingDialog(
                      prompt: "Loading...",
                      color: CustomColors.primaryColor,
                    )
                  : GoogleMapWidget(),
            ],
          ),
          DraggableScrollableSheet(
            controller: homeScreenState.scrollableController,
            initialChildSize: 0.06,
            minChildSize: 0.06,
            maxChildSize: 0.7,
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
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ValueListenableBuilder(
                          valueListenable: homeScreenState.isSheetDragged,
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
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Patient List",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: null,
                              child: Text(
                                'Locate All',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: CustomColors.primaryColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const DraggablePatientList(),
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
              valueListenable: homeScreenState.showFloatingCard,
              builder: (context, showCard, child) {
                return AnimatedOpacity(
                  opacity: showCard ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Visibility(
                    visible: showCard,
                    child: ValueListenableBuilder<Patient?>(
                      valueListenable: homeScreenState.selectedPatient,
                      builder: (context, patient, child) {
                        if (patient == null) return const SizedBox.shrink();
                        return PatientCardSmall(
                          patient: patient,
                          onLocate: () => LocationService.instance
                              .locatePatient(homeScreenState, patient),
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
            valueListenable: homeScreenState.isLoadingMarker,
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
