import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapGeofenceWidget extends StatefulWidget {
  final Function(LatLng, double) onGeofenceSet;

  const GoogleMapGeofenceWidget({Key? key, required this.onGeofenceSet})
      : super(key: key);

  @override
  _GoogleMapGeofenceWidgetState createState() =>
      _GoogleMapGeofenceWidgetState();
}

class _GoogleMapGeofenceWidgetState extends State<GoogleMapGeofenceWidget> {
  late GoogleMapController mapController;
  LatLng _center = const LatLng(37.7749, -122.4194);
  LatLng? _geofenceCenter;
  double _geofenceRadius = 1000.0;
  Circle? _geofenceCircle;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _setGeofence(LatLng position) {
    setState(() {
      _geofenceCenter = position;
      _geofenceCircle = Circle(
        circleId: CircleId('geofence'),
        center: position,
        radius: _geofenceRadius,
        fillColor: Colors.blue.withOpacity(0.2),
        strokeColor: Colors.blue,
        strokeWidth: 2,
      );
    });

    widget.onGeofenceSet(position, _geofenceRadius);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 11.0,
            ),
            circles: _geofenceCircle != null ? {_geofenceCircle!} : {},
            onTap: _setGeofence,
          ),
        ),
        if (_geofenceCenter != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Geofence set at: ${_geofenceCenter!.latitude}, ${_geofenceCenter!.longitude}, Radius: $_geofenceRadius meters',
              textAlign: TextAlign.center,
            ),
          ),
        Slider(
          value: _geofenceRadius,
          min: 100.0,
          max: 10000.0,
          divisions: 99,
          label: _geofenceRadius.round().toString(),
          onChanged: (double value) {
            setState(() {
              _geofenceRadius = value;
              if (_geofenceCenter != null) {
                _setGeofence(_geofenceCenter!);
              }
            });
          },
        ),
      ],
    );
  }
}
