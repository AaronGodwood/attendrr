import 'package:flutter_test/flutter_test.dart';
import 'package:attendr/models/lecture.dart';
import 'package:attendr/utils/checkin_rules.dart';

void main() {
  group('UT-WB-01 White-box branch/condition tests for check-in rules', () {
    test('returns false when lecture is null', () {
      final now = DateTime(2026, 2, 9, 10, 0);
      expect(canCheckInNow(now, null, distanceMeters: 10), isFalse);
    });

    test('returns false when outside check-in time window', () {
      final lecture = _lecture(
        start: DateTime(2026, 2, 9, 10, 0),
        end: DateTime(2026, 2, 9, 11, 0),
      );

      final tooEarly = DateTime(2026, 2, 9, 9, 49);
      expect(canCheckInNow(tooEarly, lecture, distanceMeters: 10), isFalse);
    });

    test('returns true for no-coordinate lectures while within window', () {
      final lecture = _lecture(
        start: DateTime(2026, 2, 9, 10, 0),
        end: DateTime(2026, 2, 9, 11, 0),
      ).copyWith(latitude: 0, longitude: 0);

      final now = DateTime(2026, 2, 9, 10, 0);
      expect(canCheckInNow(now, lecture, distanceMeters: null), isTrue);
    });

    test('returns false when distance is missing for coordinate lectures', () {
      final lecture = _lecture(
        start: DateTime(2026, 2, 9, 10, 0),
        end: DateTime(2026, 2, 9, 11, 0),
      );

      final now = DateTime(2026, 2, 9, 10, 0);
      expect(canCheckInNow(now, lecture, distanceMeters: null), isFalse);
    });

    test('returns false when distance exceeds threshold', () {
      final lecture = _lecture(
        start: DateTime(2026, 2, 9, 10, 0),
        end: DateTime(2026, 2, 9, 11, 0),
      );

      final now = DateTime(2026, 2, 9, 10, 0);
      expect(canCheckInNow(now, lecture, distanceMeters: 101), isFalse);
    });

    test('returns true when distance is exactly at threshold', () {
      final lecture = _lecture(
        start: DateTime(2026, 2, 9, 10, 0),
        end: DateTime(2026, 2, 9, 11, 0),
      );

      final now = DateTime(2026, 2, 9, 10, 0);
      expect(canCheckInNow(now, lecture, distanceMeters: 100), isTrue);
    });
  });
}

Lecture _lecture({required DateTime start, required DateTime end}) {
  return Lecture(
    id: 'lec-wb-1',
    timetableId: 'tt-wb-1',
    title: 'White Box Lecture',
    moduleCode: 'CM3001',
    location: '1 West',
    latitude: 51.379924,
    longitude: -2.328749,
    startTime: start,
    endTime: end,
    createdAt: start,
    updatedAt: start,
  );
}
