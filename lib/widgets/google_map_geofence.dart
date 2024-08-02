import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GeofenceWidget extends StatefulWidget {
  final Function(GeoPoint, double) onGeofenceSet;

  const GeofenceWidget({Key? key, required this.onGeofenceSet})
      : super(key: key);

  @override
  _GeofenceWidgetState createState() => _GeofenceWidgetState();
}

class _GeofenceWidgetState extends State<GeofenceWidget> {
  Set<Marker> markers = {};
  Set<Circle> circles = {};
  GeoPoint? geofenceCenter;
  double geofenceRadius = 100.0;

  void _onMapTapped(LatLng position) {
    setState(() {
      geofenceCenter = GeoPoint(position.latitude, position.longitude);
      markers = {
        Marker(
          markerId: MarkerId('geofence_center'),
          position: position,
        ),
      };
      circles = {
        Circle(
          circleId: CircleId('geofence_radius'),
          center: position,
          radius: geofenceRadius,
          fillColor: Colors.deepPurpleAccent.withOpacity(0.2),
          strokeColor: Colors.deepPurpleAccent,
          strokeWidth: 2,
        ),
      };
    });
    widget.onGeofenceSet(geofenceCenter!, geofenceRadius);
  }

  void _onRadiusChanged(double radius) {
    setState(() {
      geofenceRadius = radius;
      if (geofenceCenter != null) {
        _onMapTapped(
            LatLng(geofenceCenter!.latitude, geofenceCenter!.longitude));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(10.3157, 123.8854),
            zoom: 14.0,
          ),
          markers: markers,
          circles: circles,
          onTap: _onMapTapped,
          onMapCreated: (GoogleMapController controller) {},
        ),
        if (geofenceCenter != null)
          DraggableScrollableSheet(
            initialChildSize: 0.33,
            minChildSize: 0.33,
            maxChildSize: 0.33,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  children: [
                    Text(
                      'Radius: ${geofenceRadius.toStringAsFixed(1)} meters',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      activeColor: Colors.deepPurple,
                      inactiveColor: Colors.grey.shade400,
                      value: geofenceRadius,
                      min: 5,
                      max: 1000,
                      divisions: 98,
                      label: geofenceRadius.round().toString(),
                      onChanged: _onRadiusChanged,
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
