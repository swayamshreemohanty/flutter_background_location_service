// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: use_build_context_synchronously

import 'package:geolocator/geolocator.dart';

class LocationServiceRepository {
  LocationServiceRepository();

  Future<Position> fetchLocationByDeviceGPS() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled don't continue
        // accessing the position and request users of the
        // App to enable the location services.
        throw ('Location services are disabled.');
      } else {
        permission = await Geolocator.checkPermission();

        if (permission == LocationPermission.always) {
          return await Geolocator.getCurrentPosition();
        } else {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            throw ('Location permissions are denied');
          } else if (permission == LocationPermission.deniedForever) {
            // Permissions are denied forever, handle appropriately.
            throw ('Location permissions are permanently denied, we cannot request permissions.');
          } else if (permission == LocationPermission.whileInUse) {
            permission = await Geolocator.requestPermission();
            // Permissions are denied forever, handle appropriately.
            throw ('Set the location permissions to Always.');
          } else {
            if (permission == LocationPermission.always) {
              return await Geolocator.getCurrentPosition();
            } else {
              throw ('Try again.');
            }
          }
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}
