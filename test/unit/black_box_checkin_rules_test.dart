import 'package:flutter_test/flutter_test.dart';
import 'package:attendr/models/lecture.dart';
import 'package:attendr/utils/checkin_rules.dart';

void main() {
  group('UT-BB-01 Black-box equivalence and boundary tests for check-in', () {
    final lecture = _lecture(
      start: DateTime(2026, 2, 9, 10, 0),
      end: DateTime(2026, 2, 9, 11, 0),
    );

    test('equivalence class: valid time and valid distance allows check-in', () {
      final now = DateTime(2026, 2, 9, 10, 15);
      expect(canCheckInNow(now, lecture, distanceMeters: 25), isTrue);
    });

    test('equivalence class: valid time but invalid distance rejects check-in', () {
      final now = DateTime(2026, 2, 9, 10, 15);
      expect(canCheckInNow(now, lecture, distanceMeters: 250), isFalse);
    });

    test('boundary: exactly at early-window start is allowed', () {
      final now = DateTime(2026, 2, 9, 9, 50);
      expect(canCheckInNow(now, lecture, distanceMeters: 10), isTrue);
    });

    test('boundary: one second before early-window start is rejected', () {
      final now = DateTime(2026, 2, 9, 9, 49, 59);
      expect(canCheckInNow(now, lecture, distanceMeters: 10), isFalse);
    });

    test('boundary: exactly at lecture end is still allowed', () {
      final now = DateTime(2026, 2, 9, 11, 0, 0);
      expect(canCheckInNow(now, lecture, distanceMeters: 10), isTrue);
    });

    test('boundary: one second after lecture end is rejected', () {
      final now = DateTime(2026, 2, 9, 11, 0, 1);
      expect(canCheckInNow(now, lecture, distanceMeters: 10), isFalse);
    });
  });
}

Lecture _lecture({required DateTime start, required DateTime end}) {
  return Lecture(
    id: 'lec-bb-1',
    timetableId: 'tt-bb-1',
    title: 'Black Box Lecture',
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
