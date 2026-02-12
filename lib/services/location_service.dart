import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService instance = LocationService._();
  LocationService._();

  Future<bool> checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return false;
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<Position?> getCurrentPosition({
    bool skipPermissionCheck = false,
  }) async {
    try {
      if (!skipPermissionCheck) {
        final hasPermission = await checkPermissions();
        if (!hasPermission) return null;
      }

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
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return LocationResult(
        verified: false,
        distance: null,
        error:
            'Location services are disabled. Please enable location services.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return LocationResult(
        verified: false,
        distance: null,
        error:
            'Location permission is permanently denied. Enable it in app settings.',
      );
    }
    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      return LocationResult(
        verified: false,
        distance: null,
        error: 'Location permission is required to verify attendance.',
      );
    }

    final position = await getCurrentPosition(skipPermissionCheck: true);

    if (position == null) {
      return LocationResult(
        verified: false,
        distance: null,
        error: 'Could not get location. Check GPS signal and try again.',
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
