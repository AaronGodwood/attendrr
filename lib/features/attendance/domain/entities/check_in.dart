// Check-in entity
class CheckIn {
  final String lectureId;
  final DateTime timestamp;
  final double latitude;
  final double longitude;

  CheckIn({
    required this.lectureId,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
  });
}
