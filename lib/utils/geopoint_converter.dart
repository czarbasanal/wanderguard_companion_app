import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';

class GeoPointConverter {
  static Future<String> geoPointToAddress(GeoPoint geoPoint) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        geoPoint.latitude,
        geoPoint.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
      }
    } catch (e) {
      print(e);
    }
    return 'Unknown location';
  }

  static Future<GeoPoint?> addressToGeoPoint(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        return GeoPoint(location.latitude, location.longitude);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}
