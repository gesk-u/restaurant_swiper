import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Fetches the current device coordinates (latitude and longitude)
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check if the physical hardware location service is toggled on
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled on this device.');
      return null;
    }

    // 2. Check the app's current security permission state
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Prompt the native device dialog window to request access permission
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions were denied by the user.');
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      print('Permissions are permanently denied; we cannot request access.');
      return null;
    } 

    // 3. Permissions are officially granted! Fetch and return the high-precision GPS data coordinates
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );
  }
}