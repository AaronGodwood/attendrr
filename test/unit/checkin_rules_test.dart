import 'package:flutter_test/flutter_test.dart';
import 'package:attendr/models/lecture.dart';
import 'package:attendr/utils/checkin_rules.dart';

void main() {
  group('UT-06 Check-in rules', () {
    test('UT-06a: within window allows 10 minutes early', () {
      final lecture = _lecture(
        start: DateTime(2026, 2, 9, 10, 0),
        end: DateTime(2026, 2, 9, 11, 0),
      );
      final now = DateTime(2026, 2, 9, 9, 50);
      expect(isWithinCheckInWindow(now, lecture), isTrue);
    });

    test('UT-06b: outside window is rejected', () {
      final lecture = _lecture(
        start: DateTime(2026, 2, 9, 10, 0),
        end: DateTime(2026, 2, 9, 11, 0),
      );
      final now = DateTime(2026, 2, 9, 9, 40);
      expect(isWithinCheckInWindow(now, lecture), isFalse);
    });

    test('UT-06c: points are proportional to time remaining', () {
      final lecture = _lecture(
        start: DateTime(2026, 2, 9, 10, 0),
        end: DateTime(2026, 2, 9, 11, 0),
      );
      final now = DateTime(2026, 2, 9, 10, 30);
      expect(calculateCheckInPoints(now, lecture), 5);
    });

    test('UT-06d: points are max before start', () {
      final lecture = _lecture(
        start: DateTime(2026, 2, 9, 10, 0),
        end: DateTime(2026, 2, 9, 11, 0),
      );
      final now = DateTime(2026, 2, 9, 9, 55);
      expect(calculateCheckInPoints(now, lecture), 10);
    });

    test('UT-06e: can check in without coordinates during window', () {
      final lecture = _lecture(
        start: DateTime(2026, 2, 9, 10, 0),
        end: DateTime(2026, 2, 9, 11, 0),
      ).copyWith(latitude: 0, longitude: 0);
      final now = DateTime(2026, 2, 9, 9, 55);
      expect(
        canCheckInNow(
          now,
          lecture,
          distanceMeters: null,
          maxDistanceMeters: 100,
        ),
        isTrue,
      );
    });

    test('UT-06f: attendance points prorate by time spent', () {
      final lecture = _lecture(
        start: DateTime(2026, 2, 9, 10, 0),
        end: DateTime(2026, 2, 9, 11, 0),
      );
      final checkIn = DateTime(2026, 2, 9, 9, 55);
      final checkout = DateTime(2026, 2, 9, 10, 30);
      expect(calculateAttendancePoints(checkout, lecture, checkIn), 5);
    });
  });
}

Lecture _lecture({required DateTime start, required DateTime end}) {
  return Lecture(
    id: 'lec-1',
    timetableId: 'tt-1',
    title: 'Test Lecture',
    moduleCode: 'CM1001',
    location: '1 West',
    latitude: 51.379924,
    longitude: -2.328749,
    startTime: start,
    endTime: end,
    createdAt: start,
    updatedAt: start,
  );
}
