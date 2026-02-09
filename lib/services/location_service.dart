import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService instance = LocationService._();
  LocationService._();

  Future<bool> checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      return null;
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  Future<LocationResult> verifyLocation(
    double targetLat,
    double targetLon, {
    double maxDistance = 100,
  }) async {
    final position = await getCurrentPosition();

    if (position == null) {
      return LocationResult(
        verified: false,
        distance: null,
        error: 'Could not get location',
      );
    }

    final distance = calculateDistance(
      position.latitude,
      position.longitude,
      targetLat,
      targetLon,
    );

    return LocationResult(
      verified: distance <= maxDistance,
      distance: distance,
      position: position,
    );
  }
}

class LocationResult {
  final bool verified;
  final double? distance;
  final Position? position;
  final String? error;

  LocationResult({
    required this.verified,
    this.distance,
    this.position,
    this.error,
  });
}
