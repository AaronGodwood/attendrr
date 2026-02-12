import 'package:equatable/equatable.dart';

enum StreakStatus { none, building, strong, impressive, legendary, personalBest }

class Streak extends Equatable {
  final String id;
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final int streakFreezes;
  final DateTime? lastAttendanceDate;
  final DateTime? lastEvaluatedDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Streak({
    required this.id,
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    required this.streakFreezes,
    this.lastAttendanceDate,
    this.lastEvaluatedDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Streak.fromJson(Map<String, dynamic> json) {
    return Streak(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      streakFreezes: json['streak_freezes'] as int? ?? 3,
      lastAttendanceDate: json['last_attendance_date'] != null
          ? DateTime.parse(json['last_attendance_date'] as String)
          : null,
      lastEvaluatedDate: json['last_evaluated_date'] != null
          ? DateTime.parse(json['last_evaluated_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  factory Streak.empty(String userId) => Streak(
    id: '',
    userId: userId,
    currentStreak: 0,
    longestStreak: 0,
    streakFreezes: 3,
    lastAttendanceDate: null,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'current_streak': currentStreak,
    'longest_streak': longestStreak,
    'streak_freezes': streakFreezes,
    'last_attendance_date': lastAttendanceDate?.toIso8601String(),
    'last_evaluated_date': lastEvaluatedDate?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  Streak copyWith({
    String? id,
    String? userId,
    int? currentStreak,
    int? longestStreak,
    int? streakFreezes,
    DateTime? lastAttendanceDate,
    DateTime? lastEvaluatedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Streak(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      streakFreezes: streakFreezes ?? this.streakFreezes,
      lastAttendanceDate: lastAttendanceDate ?? this.lastAttendanceDate,
      lastEvaluatedDate: lastEvaluatedDate ?? this.lastEvaluatedDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get canUseFreeze => streakFreezes > 0;
  bool get isPersonalBest => currentStreak >= longestStreak && currentStreak > 0;

  bool get isAtRisk {
    if (currentStreak == 0) return false;
    if (lastAttendanceDate == null) return true;
    final today = DateTime.now();
    final lastDate = lastAttendanceDate!;
    return !(lastDate.year == today.year && lastDate.month == today.month && lastDate.day == today.day);
  }

  StreakStatus get status {
    if (currentStreak == 0) return StreakStatus.none;
    if (isPersonalBest && currentStreak > 7) return StreakStatus.personalBest;
    if (currentStreak >= 30) return StreakStatus.legendary;
    if (currentStreak >= 14) return StreakStatus.impressive;
    if (currentStreak >= 7) return StreakStatus.strong;
    return StreakStatus.building;
  }

  @override
  List<Object?> get props => [
    id, userId, currentStreak, longestStreak, streakFreezes,
    lastAttendanceDate, lastEvaluatedDate, createdAt, updatedAt
  ];
}