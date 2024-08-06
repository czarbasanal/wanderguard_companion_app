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

class BackupCompanionHomeScreenState with ChangeNotifier {
  static void initialize() {
    GetIt.instance.registerSingleton<BackupCompanionHomeScreenState>(
        BackupCompanionHomeScreenState());
    print('BackupCompanionHomeScreenState initialized');
  }

  static BackupCompanionHomeScreenState get instance =>
      GetIt.instance<BackupCompanionHomeScreenState>();

  CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 2,
  );
  GoogleMapController? _mapController;

  bool _loadingLocation = true;
  bool _showCardCloseIcon = false;
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
  bool get showCardCloseIcon => _showCardCloseIcon;

  void setInitialPosition(CameraPosition position) {
    _initialPosition = position;
    notifyListeners();
  }

  void setLoadingLocation(bool loading) {
    _loadingLocation = loading;
    print('Loading location set to: $loading');
    notifyListeners();
  }

  void setMarkers(Set<Marker> markers) {
    _markers = markers;
    print('Markers updated: $markers');
    notifyListeners();
  }

  void setCircles(Set<Circle> circles) {
    _circles = circles;
    notifyListeners();
  }

  void setLoadingMarker(bool loading) {
    _isLoadingMarker.value = loading;
    print('Loading marker set to: $loading');
  }

  void setSelectedPatient(Patient? patient) {
    PatientDataController.instance.setPatient(patient);
    print('Selected patient set to: $patient');
  }

  void setShowFloatingCard(bool show) {
    _showFloatingCard.value = show;
    print('Show floating card set to: $show');
  }

  void setShowCloseIcon(bool show) {
    _showCardCloseIcon = show;
    print('Show close icon set to: $show');
    notifyListeners();
  }

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    print('Map controller set');
  }

  Future<void> moveCamera(LatLng position) async {
    if (_mapController != null) {
      await _mapController?.animateCamera(
        CameraUpdate.newLatLng(position),
      );
      print('Camera moved to: $position');
    } else {
      print('Map controller is not initialized');
    }
  }

  Future<void> addMarker(
      LatLng position, String patientAcctId, String imageUrl) async {
    setLoadingMarker(true);
    try {
      BitmapDescriptor markerIcon;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? customMarkerString =
          prefs.getString('custom_marker_$patientAcctId');

      if (customMarkerString != null) {
        Uint8List markerBytes = base64Decode(customMarkerString);
        markerIcon = BitmapDescriptor.fromBytes(markerBytes);
      } else {
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
      print('Marker added at: $position for patient: $patientAcctId');
    } catch (e) {
      print("Error creating marker: $e");
    } finally {
      setLoadingMarker(false);
    }
  }

  void addCircle(Circle circle) {
    setCircles({...circles, circle});
    print('Circle added: $circle');
  }

  void clearCircles() {
    setCircles({});
    print('Circles cleared');
  }

  void clearMarkers() {
    setMarkers({});
    print('Markers cleared');
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
    print('State reset');
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
