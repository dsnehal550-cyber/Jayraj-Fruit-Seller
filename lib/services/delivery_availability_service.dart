import 'package:geolocator/geolocator.dart';

class DeliveryAvailabilityService {
  // Real seller coordinates are NOT available yet (backend not implemented).
  // Do NOT hard-code fake seller coordinates here.
  static const double? _sellerLatitude = null;
  static const double? _sellerLongitude = null;

  static const double _maxDeliveryDistanceMeters = 15000.0; // 15 km

  /// Checks if delivery is available.
  /// Returns a record with `isAvailable` and `message`.
  static Future<({bool isAvailable, String message})> checkDeliveryAvailability({
    required double customerLat,
    required double customerLng,
  }) async {
    final sLat = _sellerLatitude;
    final sLng = _sellerLongitude;

    if (sLat == null || sLng == null) {
      // Backend not implemented, real seller coordinates are missing.
      return (
        isAvailable: false,
        message: 'Seller location not configured yet. Delivery verification requires real seller coordinates.',
      );
    }

    final distanceMeters = Geolocator.distanceBetween(
      sLat,
      sLng,
      customerLat,
      customerLng,
    );

    if (distanceMeters <= _maxDeliveryDistanceMeters) {
      return (
        isAvailable: true,
        message: 'Delivery available (Distance: ${(distanceMeters / 1000).toStringAsFixed(1)} km)',
      );
    } else {
      return (
        isAvailable: false,
        message: 'Delivery is unavailable at this address. The delivery limit is 15 km.',
      );
    }
  }
}
