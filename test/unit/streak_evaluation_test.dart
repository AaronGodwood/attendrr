import 'package:flutter_test/flutter_test.dart';
import 'package:attendr/models/models.dart';

void main() {
  group('StreakEvaluation model', () {
    test('fromJson parses all fields correctly', () {
      final json = {
        'current_streak': 5,
        'longest_streak': 10,
        'streak_freezes': 2,
        'last_attendance_date': '2026-02-10',
        'freezes_consumed': 1,
        'streak_broken': false,
      };

      final eval = StreakEvaluation.fromJson(json);

      expect(eval.currentStreak, 5);
      expect(eval.longestStreak, 10);
      expect(eval.streakFreezes, 2);
      expect(eval.lastAttendanceDate, DateTime.parse('2026-02-10'));
      expect(eval.freezesConsumed, 1);
      expect(eval.streakBroken, false);
    });

    test('fromJson handles null/missing fields with defaults', () {
      final eval = StreakEvaluation.fromJson({});

      expect(eval.currentStreak, 0);
      expect(eval.longestStreak, 0);
      expect(eval.streakFreezes, 0);
      expect(eval.lastAttendanceDate, isNull);
      expect(eval.freezesConsumed, 0);
      expect(eval.streakBroken, false);
    });

    test('hadChanges returns true when freezes were consumed', () {
      const eval = StreakEvaluation(
        currentStreak: 5,
        longestStreak: 5,
        streakFreezes: 1,
        freezesConsumed: 2,
        streakBroken: false,
      );

      expect(eval.hadChanges, true);
    });

    test('hadChanges returns true when streak was broken', () {
      const eval = StreakEvaluation(
        currentStreak: 0,
        longestStreak: 5,
        streakFreezes: 0,
        freezesConsumed: 0,
        streakBroken: true,
      );

      expect(eval.hadChanges, true);
    });

    test('hadChanges returns false when nothing changed', () {
      const eval = StreakEvaluation(
        currentStreak: 5,
        longestStreak: 5,
        streakFreezes: 3,
        freezesConsumed: 0,
        streakBroken: false,
      );

      expect(eval.hadChanges, false);
    });
  });

  group('Streak model - lastEvaluatedDate', () {
    test('fromJson parses lastEvaluatedDate', () {
      final json = {
        'id': 'streak-1',
        'user_id': 'user-1',
        'current_streak': 5,
        'longest_streak': 10,
        'streak_freezes': 3,
        'last_attendance_date': '2026-02-10',
        'last_evaluated_date': '2026-02-11',
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-02-11T00:00:00Z',
      };

      final streak = Streak.fromJson(json);

      expect(streak.lastEvaluatedDate, DateTime.parse('2026-02-11'));
    });

    test('fromJson handles null lastEvaluatedDate', () {
      final json = {
        'id': 'streak-1',
        'user_id': 'user-1',
        'current_streak': 5,
        'longest_streak': 10,
        'streak_freezes': 3,
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-02-11T00:00:00Z',
      };

      final streak = Streak.fromJson(json);

      expect(streak.lastEvaluatedDate, isNull);
    });

    test('toJson includes lastEvaluatedDate', () {
      final streak = Streak(
        id: 'streak-1',
        userId: 'user-1',
        currentStreak: 5,
        longestStreak: 10,
        streakFreezes: 3,
        lastEvaluatedDate: DateTime.parse('2026-02-11'),
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2026-02-11T00:00:00Z'),
      );

      final json = streak.toJson();

      expect(json['last_evaluated_date'], isNotNull);
    });

    test('copyWith preserves lastEvaluatedDate', () {
      final streak = Streak(
        id: 'streak-1',
        userId: 'user-1',
        currentStreak: 5,
        longestStreak: 10,
        streakFreezes: 3,
        lastEvaluatedDate: DateTime.parse('2026-02-11'),
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2026-02-11T00:00:00Z'),
      );

      final copied = streak.copyWith(currentStreak: 6);

      expect(copied.currentStreak, 6);
      expect(copied.lastEvaluatedDate, DateTime.parse('2026-02-11'));
    });
  });
}
