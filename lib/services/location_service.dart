import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationException implements Exception {
  const LocationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LocationService {
  /// Requests location permissions and returns a valid current position.
  static Future<Position> requestPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const LocationException(
          'Turn on device location services to select a delivery location.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw const LocationException(
          'Location permission was denied. Allow location access to select a delivery location.',
        );
      }
      if (permission == LocationPermission.deniedForever) {
        throw const LocationException(
          'Location permission is blocked. Enable it in device settings to select a delivery location.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 20));
      if (!position.latitude.isFinite ||
          !position.longitude.isFinite ||
          position.latitude < -90 ||
          position.latitude > 90 ||
          position.longitude < -180 ||
          position.longitude > 180) {
        throw const LocationException(
          'The device returned invalid coordinates. Try selecting the location again.',
        );
      }
      return position;
    } on LocationException {
      rethrow;
    } on TimeoutException {
      throw const LocationException(
        'Could not determine your location in time. Check location services and try again.',
      );
    } on Exception {
      throw const LocationException(
        'Could not determine your location. Check location permission and services, then try again.',
      );
    }
  }

  /// Nullable compatibility wrapper for existing customer location flows.
  static Future<Position?> requestPermissionAndGetLocation() async {
    try {
      return await requestPosition();
    } on LocationException {
      return null;
    }
  }

  /// Converts a latitude/longitude pair into a human-readable address.
  static Future<String?> getAddressFromCoordinates(
    double lat,
    double lng,
  ) async {
    try {
      List<Placemark> placemarks = await Geocoding().placemarkFromCoordinates(
        lat,
        lng,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final List<String> addressParts = [];

        if (place.name != null && place.name!.isNotEmpty) {
          addressParts.add(place.name!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          addressParts.add(place.postalCode!);
        }

        return addressParts.join(', ');
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Converts an address string into latitude/longitude coordinates.
  static Future<Location?> getCoordinatesFromAddress(
    String addressString,
  ) async {
    try {
      List<Location> locations = await Geocoding().locationFromAddress(
        addressString,
      );
      if (locations.isNotEmpty) {
        return locations.first;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
