// lib/models/user_profile.dart

import 'user.dart';
import 'streak.dart';
import 'attendance.dart';

/// Combined user profile with all related data
class UserProfile {
  final User user;
  final Streak streak;
  final AttendanceStats? stats;
  final List<DailyAttendance>? attendanceHistory;

  const UserProfile({
    required this.user,
    required this.streak,
    this.stats,
    this.attendanceHistory,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      user: User.fromJson(json),
      streak: Streak.fromJson(json['streaks'] as Map<String, dynamic>? ?? {
        'id': '',
        'user_id': json['id'],
        'current_streak': 0,
        'longest_streak': 0,
        'streak_freezes': 3,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }),
    );
  }

  UserProfile copyWith({
    User? user,
    Streak? streak,
    AttendanceStats? stats,
    List<DailyAttendance>? attendanceHistory,
  }) {
    return UserProfile(
      user: user ?? this.user,
      streak: streak ?? this.streak,
      stats: stats ?? this.stats,
      attendanceHistory: attendanceHistory ?? this.attendanceHistory,
    );
  }

  // Convenience accessors
  String get username => user.username;
  String get email => user.email;
  String? get avatarUrl => user.avatarUrl;
  int get currentStreak => streak.currentStreak;
  int get longestStreak => streak.longestStreak;

  /// Check if user has connected their timetable
  bool get hasTimetableConnected => user.icalUrl != null;
}