import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class Lecture extends Equatable {
  final String id;
  final String timetableId;
  final String? externalId;
  final String title;
  final String moduleCode;
  final String location;
  final double latitude;
  final double longitude;
  final DateTime startTime;
  final DateTime endTime;
  final String? recurrenceRule;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Lecture({
    required this.id,
    required this.timetableId,
    this.externalId,
    required this.title,
    required this.moduleCode,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.startTime,
    required this.endTime,
    this.recurrenceRule,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Lecture.fromJson(Map<String, dynamic> json) {
    return Lecture(
      id: json['id'] as String,
      timetableId: json['timetable_id'] as String,
      externalId: json['external_id'] as String?,
      title: json['title'] as String,
      moduleCode: json['module_code'] as String,
      location: json['location'] as String,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      recurrenceRule: json['recurrence_rule'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'timetable_id': timetableId,
    'external_id': externalId,
    'title': title,
    'module_code': moduleCode,
    'location': location,
    'latitude': latitude,
    'longitude': longitude,
    'start_time': startTime.toIso8601String(),
    'end_time': endTime.toIso8601String(),
    'recurrence_rule': recurrenceRule,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  Map<String, dynamic> toInsertJson() => {
    'timetable_id': timetableId,
    'external_id': externalId,
    'title': title,
    'module_code': moduleCode,
    'location': location,
    'latitude': latitude,
    'longitude': longitude,
    'start_time': startTime.toIso8601String(),
    'end_time': endTime.toIso8601String(),
    'recurrence_rule': recurrenceRule,
  };

  Lecture copyWith({
    String? id,
    String? timetableId,
    String? externalId,
    String? title,
    String? moduleCode,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? startTime,
    DateTime? endTime,
    String? recurrenceRule,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Lecture(
      id: id ?? this.id,
      timetableId: timetableId ?? this.timetableId,
      externalId: externalId ?? this.externalId,
      title: title ?? this.title,
      moduleCode: moduleCode ?? this.moduleCode,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Computed properties
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  bool get isUpcoming => DateTime.now().isBefore(startTime);
  bool get isPast => DateTime.now().isAfter(endTime);

  Duration get duration => endTime.difference(startTime);
  int get durationMinutes => duration.inMinutes;

  String get timeRange {
    final start =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final end =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }

  int get dayOfWeek => startTime.weekday;

  bool get hasValidCoordinates => latitude != 0.0 && longitude != 0.0;

  Duration? get timeUntilStart =>
      isUpcoming ? startTime.difference(DateTime.now()) : null;
  Duration? get timeRemaining =>
      isActive ? endTime.difference(DateTime.now()) : null;

  Color get color {
    return TerraColors.moduleColors[moduleCode.hashCode.abs() % TerraColors.moduleColors.length];
  }

  @override
  List<Object?> get props => [
    id,
    timetableId,
    externalId,
    title,
    moduleCode,
    location,
    latitude,
    longitude,
    startTime,
    endTime,
    recurrenceRule,
    createdAt,
    updatedAt,
  ];
}

enum LectureStatus { upcoming, inProgress, attended, missed }

class LectureWithAttendance {
  final Lecture lecture;
  final bool attended;
  final String? attendanceId;
  final int? pointsEarned;

  const LectureWithAttendance({
    required this.lecture,
    required this.attended,
    this.attendanceId,
    this.pointsEarned,
  });

  factory LectureWithAttendance.fromJson(Map<String, dynamic> json) {
    final lecture = Lecture.fromJson(json);
    final attendanceList = json['attendance'] as List?;
    final hasAttendance = attendanceList != null && attendanceList.isNotEmpty;

    return LectureWithAttendance(
      lecture: lecture,
      attended: hasAttendance,
      attendanceId:
          hasAttendance ? attendanceList.first['id'] as String? : null,
      pointsEarned:
          hasAttendance ? attendanceList.first['points_earned'] as int? : null,
    );
  }

  LectureStatus get status {
    if (attended) return LectureStatus.attended;
    if (lecture.isPast) return LectureStatus.missed;
    if (lecture.isActive) return LectureStatus.inProgress;
    return LectureStatus.upcoming;
  }
}
