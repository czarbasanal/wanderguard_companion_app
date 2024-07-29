import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import '../models/companion.model.dart';
import '../controllers/companion_data_controller.dart';

class LocationService {
  static void initialize() {
    GetIt.instance.registerSingleton<LocationService>(LocationService());
  }

  static LocationService get instance => GetIt.instance<LocationService>();

  Future<Position> getCurrentLocation() async {
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

  Future<void> updateCompanionLocation(Position position) async {
    try {
      Companion? companion =
          CompanionDataController.instance.companionModelNotifier.value;
      if (companion != null) {
        companion.updateCurrentLocation(
            GeoPoint(position.latitude, position.longitude));
        await FirebaseFirestore.instance
            .collection('companions')
            .doc(companion.companionAcctId)
            .update({
          'currentLocation': GeoPoint(position.latitude, position.longitude),
          'updatedAt': DateTime.now(),
        });
      }
    } catch (e) {
      throw 'Failed to update location: $e';
    }
  }
}
