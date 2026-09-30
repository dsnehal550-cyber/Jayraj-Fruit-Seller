import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Requests location permissions and returns the current position.
  static Future<Position?> requestPermissionAndGetLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (_) {
      return null;
    }
  }

  /// Converts a latitude/longitude pair into a human-readable address.
  static Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await Geocoding().placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final List<String> addressParts = [];
        
        if (place.name != null && place.name!.isNotEmpty) addressParts.add(place.name!);
        if (place.subLocality != null && place.subLocality!.isNotEmpty) addressParts.add(place.subLocality!);
        if (place.locality != null && place.locality!.isNotEmpty) addressParts.add(place.locality!);
        if (place.postalCode != null && place.postalCode!.isNotEmpty) addressParts.add(place.postalCode!);
        
        return addressParts.join(', ');
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Converts an address string into latitude/longitude coordinates.
  static Future<Location?> getCoordinatesFromAddress(String addressString) async {
    try {
      List<Location> locations = await Geocoding().locationFromAddress(addressString);
      if (locations.isNotEmpty) {
        return locations.first;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
