import 'package:flutter/material.dart';

enum LeaderboardCategory {
  totalPoints,
  weeklyPoints,
  currentStreak,
  attendanceRate;

  String get label {
    switch (this) {
      case totalPoints:
        return 'Total Points';
      case weeklyPoints:
        return 'Weekly Points';
      case currentStreak:
        return 'Current Streak';
      case attendanceRate:
        return 'Attendance';
    }
  }

  String get unit {
    switch (this) {
      case totalPoints:
        return 'pts';
      case weeklyPoints:
        return 'pts';
      case currentStreak:
        return 'days';
      case attendanceRate:
        return '%';
    }
  }

  IconData get icon {
    switch (this) {
      case totalPoints:
        return Icons.stars;
      case weeklyPoints:
        return Icons.trending_up;
      case currentStreak:
        return Icons.local_fire_department;
      case attendanceRate:
        return Icons.check_circle_outline;
    }
  }
}
