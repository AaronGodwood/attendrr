// lib/models/user_profile.dart

import 'user.dart';
import 'streak.dart';
import 'points.dart';
import 'attendance.dart';

/// Combined user profile with all related data
class UserProfile {
  final User user;
  final Streak streak;
  final Points points;
  final AttendanceStats? stats;
  final List<DailyAttendance>? attendanceHistory;

  const UserProfile({
    required this.user,
    required this.streak,
    required this.points,
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
      points: Points.fromJson(json['points'] as Map<String, dynamic>? ?? {
        'id': '',
        'user_id': json['id'],
        'total_points': 0,
        'weekly_points': 0,
        'monthly_points': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }),
    );
  }

  UserProfile copyWith({
    User? user,
    Streak? streak,
    Points? points,
    AttendanceStats? stats,
    List<DailyAttendance>? attendanceHistory,
  }) {
    return UserProfile(
      user: user ?? this.user,
      streak: streak ?? this.streak,
      points: points ?? this.points,
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
  int get totalPoints => points.totalPoints;
  int get weeklyPoints => points.weeklyPoints;
  int get streakFreezes => streak.streakFreezes;

  /// Check if user has connected their timetable
  bool get hasTimetableConnected => user.icalUrl != null;
}