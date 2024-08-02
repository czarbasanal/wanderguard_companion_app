import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wanderguard_companion_app/state/homescreen_state.dart';

class GoogleMapWidget extends StatefulWidget {
  @override
  _GoogleMapWidgetState createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  late GoogleMapController _controller;

  @override
  Widget build(BuildContext context) {
    final homeScreenState = Provider.of<HomeScreenState>(context);

    return GoogleMap(
      initialCameraPosition: homeScreenState.initialPosition,
      mapType: MapType.normal,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      markers: homeScreenState.markers,
      circles: homeScreenState.circles,
      onMapCreated: (GoogleMapController controller) {
        _controller = controller;
        homeScreenState.setMapController(controller);
      },
    );
  }
}
