import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wanderguard_companion_app/controllers/patient_data_controller.dart';
import 'package:wanderguard_companion_app/models/patient.model.dart';
import 'package:wanderguard_companion_app/services/shared_preferences_service.dart';
import 'package:wanderguard_companion_app/utils/custom_marker_generator.dart';

class HomeScreenState with ChangeNotifier {
  static void initialize() {
    GetIt.instance.registerSingleton<HomeScreenState>(HomeScreenState());
  }

  static HomeScreenState get instance => GetIt.instance<HomeScreenState>();

  CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 2,
  );
  GoogleMapController? _mapController;

  bool _loadingLocation = true;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  final ValueNotifier<bool> _isLoadingMarker = ValueNotifier(false);
  final ValueNotifier<bool> _showFloatingCard = ValueNotifier(false);
  final DraggableScrollableController _scrollableController =
      DraggableScrollableController();
  final ValueNotifier<bool> _isSheetDragged = ValueNotifier(false);

  CameraPosition get initialPosition => _initialPosition;
  bool get loadingLocation => _loadingLocation;
  Set<Marker> get markers => _markers;
  Set<Circle> get circles => _circles;
  ValueNotifier<bool> get isLoadingMarker => _isLoadingMarker;
  ValueNotifier<Patient?> get selectedPatient =>
      PatientDataController.instance.patientModelNotifier;
  ValueNotifier<bool> get showFloatingCard => _showFloatingCard;
  DraggableScrollableController get scrollableController =>
      _scrollableController;
  ValueNotifier<bool> get isSheetDragged => _isSheetDragged;

  void setInitialPosition(CameraPosition position) {
    _initialPosition = position;
    notifyListeners();
  }

  void setLoadingLocation(bool loading) {
    _loadingLocation = loading;
    notifyListeners();
  }

  void setMarkers(Set<Marker> markers) {
    _markers = markers;
    notifyListeners();
  }

  void setCircles(Set<Circle> circles) {
    _circles = circles;
    notifyListeners();
  }

  void setLoadingMarker(bool loading) {
    _isLoadingMarker.value = loading;
  }

  void setSelectedPatient(Patient? patient) {
    PatientDataController.instance.setPatient(patient);
  }

  void setShowFloatingCard(bool show) {
    _showFloatingCard.value = show;
  }

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> moveCamera(LatLng position) async {
    await _mapController?.animateCamera(
      CameraUpdate.newLatLng(position),
    );
  }

  // Future<void> addMarker(
  //     LatLng position, String markerId, String imageUrl) async {
  //   setLoadingMarker(true);
  //   try {
  //     final markerIcon = await createCustomMarker(imageUrl);
  //     final marker = Marker(
  //       markerId: MarkerId(markerId),
  //       position: position,
  //       icon: markerIcon,
  //       infoWindow: InfoWindow(title: imageUrl),
  //     );

  //     setMarkers({...markers, marker});
  //     await SharedPreferenceService.instance.saveMarkers(markers.toList());
  //   } catch (e) {
  //     print("Error creating marker: $e");
  //   } finally {
  //     setLoadingMarker(false);
  //   }
  // }

  Future<void> addMarker(
      LatLng position, String patientAcctId, String imageUrl) async {
    setLoadingMarker(true);
    try {
      BitmapDescriptor markerIcon;

      // Retrieve custom marker from SharedPreferences using patientAcctId
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? customMarkerString =
          prefs.getString('custom_marker_$patientAcctId');

      if (customMarkerString != null) {
        // Use the custom marker from SharedPreferences
        Uint8List markerBytes = base64Decode(customMarkerString);
        markerIcon = BitmapDescriptor.fromBytes(markerBytes);
      } else {
        // Create a new custom marker and save it to SharedPreferences
        markerIcon = await createCustomMarker(imageUrl);
        final Uint8List markerBytes = await createCustomMarkerBytes(imageUrl);
        prefs.setString(
            'custom_marker_$patientAcctId', base64Encode(markerBytes));
      }

      final marker = Marker(
        markerId: MarkerId(patientAcctId),
        position: position,
        icon: markerIcon,
        infoWindow: InfoWindow(title: imageUrl),
      );

      setMarkers({...markers, marker});
      await SharedPreferenceService.instance.saveMarkers(markers.toList());
    } catch (e) {
      print("Error creating marker: $e");
    } finally {
      setLoadingMarker(false);
    }
  }

  void addCircle(Circle circle) {
    setCircles({...circles, circle});
  }

  void reset() {
    _mapController?.dispose();
    _mapController = null;
    _initialPosition = const CameraPosition(
      target: LatLng(0, 0),
      zoom: 2,
    );
    _loadingLocation = true;
    _markers.clear();
    _circles.clear();
    _isLoadingMarker.value = false;
    _showFloatingCard.value = false;
    _isSheetDragged.value = false;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
