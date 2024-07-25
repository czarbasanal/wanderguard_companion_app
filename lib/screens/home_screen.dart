import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:wanderguard_companion_app/utils/colors.dart';
import '../services/information_service.dart';
import '../widgets/dialogs/waiting_dialog.dart';
import '../controllers/companion_data_controller.dart';
import '../services/firestore_service.dart';
import '../models/companion.model.dart';

class HomeScreen extends StatefulWidget {
  static const route = '/home';
  static const name = 'Home';

  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 2,
  );
  bool _loadingLocation = true;
  late GoogleMapController _controller;

  @override
  void initState() {
    super.initState();
    _determinePosition().then((position) {
      setState(() {
        _initialPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        );
        _loadingLocation = false;
      });
      _updateCurrentLocation(position);
    }).catchError((e) {
      setState(() {
        _loadingLocation = false;
      });
      Info.showSnackbarMessage(context, message: e.toString(), label: "Error");
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied, we cannot request permissions.';
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _updateCurrentLocation(Position position) async {
    try {
      Companion? companion =
          CompanionDataController.instance.companionModelNotifier.value;
      if (companion != null) {
        companion.updateCurrentLocation(
            GeoPoint(position.latitude, position.longitude));
        await FirestoreService.instance.addOrUpdateCompanion(companion);
      }
    } catch (e) {
      Info.showSnackbarMessage(context,
          message: "Failed to update location: $e", label: "Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.tertiaryColor,
      body: _loadingLocation
          ? WaitingDialog(
              prompt: "Loading...",
              color: CustomColors.primaryColor,
            )
          : GoogleMap(
              initialCameraPosition: _initialPosition,
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
              },
            ),
    );
  }
}
