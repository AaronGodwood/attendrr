// Attendance model
class AttendanceModel {
  final String id;
  final String lectureId;
  final String userId;
  final DateTime timestamp;
  final bool present;

  AttendanceModel({
    required this.id,
    required this.lectureId,
    required this.userId,
    required this.timestamp,
    required this.present,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'],
      lectureId: json['lecture_id'],
      userId: json['user_id'],
      timestamp: DateTime.parse(json['timestamp']),
      present: json['present'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lecture_id': lectureId,
      'user_id': userId,
      'timestamp': timestamp.toIso8601String(),
      'present': present,
    };
  }
}
