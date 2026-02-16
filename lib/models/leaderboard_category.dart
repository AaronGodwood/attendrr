import 'package:flutter/material.dart';

enum LeaderboardCategory {
  weeklyPoints,
  totalPoints,
  currentStreak,
  attendanceRate;

  String get label {
    switch (this) {
      case weeklyPoints:
        return 'Weekly Points';
      case totalPoints:
        return 'Total Points';
      case currentStreak:
        return 'Current Streak';
      case attendanceRate:
        return 'Attendance';
    }
  }

  String get unit {
    switch (this) {
      case weeklyPoints:
        return 'pts';
      case totalPoints:
        return 'pts';
      case currentStreak:
        return 'days';
      case attendanceRate:
        return '%';
    }
  }

  IconData get icon {
    switch (this) {
      case weeklyPoints:
        return Icons.trending_up;
      case totalPoints:
        return Icons.stars;
      case currentStreak:
        return Icons.local_fire_department;
      case attendanceRate:
        return Icons.check_circle_outline;
    }
  }
}
