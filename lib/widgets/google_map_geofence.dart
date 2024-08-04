import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GeofenceWidget extends StatefulWidget {
  final Function(GeoPoint, double) onGeofenceSet;
  final GeoPoint? initialGeofenceCenter;
  final double? initialGeofenceRadius;

  const GeofenceWidget({
    Key? key,
    required this.onGeofenceSet,
    this.initialGeofenceCenter,
    this.initialGeofenceRadius,
  }) : super(key: key);

  @override
  _GeofenceWidgetState createState() => _GeofenceWidgetState();
}

class _GeofenceWidgetState extends State<GeofenceWidget> {
  Set<Marker> markers = {};
  Set<Circle> circles = {};
  GeoPoint? geofenceCenter;
  double geofenceRadius = 100.0;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    if (widget.initialGeofenceCenter != null &&
        widget.initialGeofenceRadius != null) {
      geofenceCenter = widget.initialGeofenceCenter;
      geofenceRadius = widget.initialGeofenceRadius!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _drawGeofence(
            LatLng(geofenceCenter!.latitude, geofenceCenter!.longitude),
            geofenceRadius);
        if (_mapController != null) {
          _moveCamera(
              LatLng(geofenceCenter!.latitude, geofenceCenter!.longitude));
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant GeofenceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialGeofenceCenter != oldWidget.initialGeofenceCenter ||
        widget.initialGeofenceRadius != oldWidget.initialGeofenceRadius) {
      setState(() {
        geofenceCenter = widget.initialGeofenceCenter;
        geofenceRadius = widget.initialGeofenceRadius ?? 100.0;
      });
      if (geofenceCenter != null) {
        _drawGeofence(
            LatLng(geofenceCenter!.latitude, geofenceCenter!.longitude),
            geofenceRadius);
        if (_mapController != null) {
          _moveCamera(
              LatLng(geofenceCenter!.latitude, geofenceCenter!.longitude));
        }
      } else {
        _clearGeofence();
      }
    }
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      geofenceCenter = GeoPoint(position.latitude, position.longitude);
      _drawGeofence(position, geofenceRadius);
    });
    widget.onGeofenceSet(geofenceCenter!, geofenceRadius);
  }

  Future<void> _drawGeofence(LatLng center, double radius) async {
    final BitmapDescriptor markerIcon = await _createCustomMarker();
    setState(() {
      markers = {
        Marker(
          markerId: MarkerId('geofence_center'),
          position: center,
          icon: markerIcon,
        ),
      };
      circles = {
        Circle(
          circleId: CircleId('geofence_radius'),
          center: center,
          radius: radius,
          fillColor: Colors.deepPurpleAccent.withOpacity(0.2),
          strokeColor: Colors.deepPurpleAccent,
          strokeWidth: 2,
        ),
      };
    });
  }

  void _clearGeofence() {
    setState(() {
      markers.clear();
      circles.clear();
    });
  }

  Future<BitmapDescriptor> _createCustomMarker() async {
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
  }

  void _moveCamera(LatLng center) {
    _mapController?.animateCamera(CameraUpdate.newLatLng(center));
  }

  void _onRadiusChanged(double radius) {
    setState(() {
      geofenceRadius = radius;
      if (geofenceCenter != null) {
        _drawGeofence(
          LatLng(geofenceCenter!.latitude, geofenceCenter!.longitude),
          geofenceRadius,
        );
      }
    });
    widget.onGeofenceSet(geofenceCenter!, geofenceRadius);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: geofenceCenter != null
                ? LatLng(geofenceCenter!.latitude, geofenceCenter!.longitude)
                : LatLng(10.3157, 123.8854),
            zoom: 14.0,
          ),
          markers: markers,
          circles: circles,
          onTap: _onMapTapped,
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            if (geofenceCenter != null) {
              _moveCamera(
                  LatLng(geofenceCenter!.latitude, geofenceCenter!.longitude));
            }
          },
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
                      min: 0,
                      max: 1000,
                      divisions: 199,
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
