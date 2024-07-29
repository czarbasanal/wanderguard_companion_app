import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wanderguard_companion_app/utils/custom_marker_generator.dart';

class SharedPreferenceService {
  static void initialize() {
    GetIt.instance
        .registerSingleton<SharedPreferenceService>(SharedPreferenceService());
  }

  static SharedPreferenceService get instance =>
      GetIt.instance<SharedPreferenceService>();

  Future<void> saveMarkers(List<Marker> markers) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> markerData = markers.map((marker) {
      return '${marker.position.latitude},${marker.position.longitude},${marker.markerId.value},${marker.infoWindow.title}';
    }).toList();
    await prefs.setStringList('markers', markerData);
  }

  Future<List<Marker>> loadMarkers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? markerData = prefs.getStringList('markers');
    if (markerData == null) return [];

    List<Marker> markers = [];
    for (String data in markerData) {
      List<String> parts = data.split(',');
      double lat = double.parse(parts[0]);
      double lng = double.parse(parts[1]);
      String markerId = parts[2];
      String imageUrl = parts[3];
      BitmapDescriptor icon = await createCustomMarker(imageUrl);
      markers.add(Marker(
        markerId: MarkerId(markerId),
        position: LatLng(lat, lng),
        icon: icon,
      ));
    }
    return markers;
  }

  Future<bool> isMarkerExists(String markerId) async {
    List<Marker> savedMarkers =
        await SharedPreferenceService.instance.loadMarkers();
    return savedMarkers.any((marker) => marker.markerId.value == markerId);
  }
}
