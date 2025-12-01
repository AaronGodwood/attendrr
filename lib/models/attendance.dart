import 'package:equatable/equatable.dart';
import 'lecture.dart';

class Attendance extends Equatable {
  final String id;
  final String userId;
  final String lectureId;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final bool locationVerified;
  final double? distanceMeters;
  final int pointsEarned;
  final DateTime createdAt;
  final Lecture? lecture;

  const Attendance({
    required this.id,
    required this.userId,
    required this.lectureId,
    required this.checkInTime,
    this.checkOutTime,
    required this.locationVerified,
    this.distanceMeters,
    required this.pointsEarned,
    required this.createdAt,
    this.lecture,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      lectureId: json['lecture_id'] as String,
      checkInTime: DateTime.parse(json['check_in_time'] as String),
      checkOutTime: json['check_out_time'] != null
          ? DateTime.parse(json['check_out_time'] as String)
          : null,
      locationVerified: json['location_verified'] as bool? ?? false,
      distanceMeters: (json['distance_meters'] as num?)?.toDouble(),
      pointsEarned: json['points_earned'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      lecture: json['lectures'] != null
          ? Lecture.fromJson(json['lectures'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'lecture_id': lectureId,
    'check_in_time': checkInTime.toIso8601String(),
    'check_out_time': checkOutTime?.toIso8601String(),
    'location_verified': locationVerified,
    'distance_meters': distanceMeters,
    'points_earned': pointsEarned,
    'created_at': createdAt.toIso8601String(),
  };

  Map<String, dynamic> toInsertJson() => {
    'user_id': userId,
    'lecture_id': lectureId,
    'check_in_time': checkInTime.toIso8601String(),
    'location_verified': locationVerified,
    'distance_meters': distanceMeters,
    'points_earned': pointsEarned,
  };

  Attendance copyWith({
    String? id,
    String? userId,
    String? lectureId,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    bool? locationVerified,
    double? distanceMeters,
    int? pointsEarned,
    DateTime? createdAt,
    Lecture? lecture,
  }) {
    return Attendance(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lectureId: lectureId ?? this.lectureId,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      locationVerified: locationVerified ?? this.locationVerified,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      createdAt: createdAt ?? this.createdAt,
      lecture: lecture ?? this.lecture,
    );
  }

  bool get isActive => checkOutTime == null;

  Duration get sessionDuration {
    final end = checkOutTime ?? DateTime.now();
    return end.difference(checkInTime);
  }

  @override
  List<Object?> get props => [
    id, userId, lectureId, checkInTime, checkOutTime,
    locationVerified, distanceMeters, pointsEarned, createdAt
  ];
}

class AttendanceStats {
  final int weeklyAttended;
  final int weeklyTotal;
  final int monthlyAttended;
  final int monthlyTotal;
  final int overallAttended;
  final int overallTotal;

  const AttendanceStats({
    required this.weeklyAttended,
    required this.weeklyTotal,
    required this.monthlyAttended,
    required this.monthlyTotal,
    required this.overallAttended,
    required this.overallTotal,
  });

  factory AttendanceStats.empty() => const AttendanceStats(
    weeklyAttended: 0, weeklyTotal: 0,
    monthlyAttended: 0, monthlyTotal: 0,
    overallAttended: 0, overallTotal: 0,
  );

  double get weeklyRate => weeklyTotal > 0 ? weeklyAttended / weeklyTotal : 0;
  double get monthlyRate => monthlyTotal > 0 ? monthlyAttended / monthlyTotal : 0;
  double get overallRate => overallTotal > 0 ? overallAttended / overallTotal : 0;

  int get weeklyPercent => (weeklyRate * 100).round();
  int get monthlyPercent => (monthlyRate * 100).round();
  int get overallPercent => (overallRate * 100).round();
}

class DailyAttendance {
  final DateTime date;
  final int count;

  const DailyAttendance({required this.date, required this.count});
}