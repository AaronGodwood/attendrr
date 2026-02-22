import 'package:attendr/models/attendance.dart';
import 'package:attendr/providers/profile_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileProvider weekly perfect attendance reward helpers', () {
    test(
      'qualifies when weekly attended equals weekly total and total > 0',
      () {
        const stats = AttendanceStats(
          weeklyAttended: 4,
          weeklyTotal: 4,
          monthlyAttended: 10,
          monthlyTotal: 12,
          overallAttended: 20,
          overallTotal: 25,
        );

        expect(ProfileProvider.isWeeklyPerfectAttendance(stats), isTrue);
      },
    );

    test('does not qualify when weekly total is zero', () {
      const stats = AttendanceStats(
        weeklyAttended: 0,
        weeklyTotal: 0,
        monthlyAttended: 0,
        monthlyTotal: 0,
        overallAttended: 0,
        overallTotal: 0,
      );

      expect(ProfileProvider.isWeeklyPerfectAttendance(stats), isFalse);
    });

    test('does not qualify when weekly attendance is not perfect', () {
      const stats = AttendanceStats(
        weeklyAttended: 3,
        weeklyTotal: 4,
        monthlyAttended: 8,
        monthlyTotal: 12,
        overallAttended: 16,
        overallTotal: 25,
      );

      expect(ProfileProvider.isWeeklyPerfectAttendance(stats), isFalse);
    });

    test('week key resolves to Monday date', () {
      // Wednesday -> same ISO-like week Monday.
      final key = ProfileProvider.weekKey(DateTime(2026, 2, 25));
      expect(key, '2026-02-23');
    });
  });
}
