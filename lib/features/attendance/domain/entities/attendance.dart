// Attendance entity
class Attendance {
  final String id;
  final String lectureId;
  final String userId;
  final DateTime timestamp;
  final bool present;

  Attendance({
    required this.id,
    required this.lectureId,
    required this.userId,
    required this.timestamp,
    required this.present,
  });
}
