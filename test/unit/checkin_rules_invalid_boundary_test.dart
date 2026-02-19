import 'package:flutter_test/flutter_test.dart';
import 'package:attendr/models/lecture.dart';
import 'package:attendr/utils/checkin_rules.dart';

void main() {
  group('UT-INV-01 Check-in rules invalid/border data', () {
    test(
      'calculateCheckInPoints returns 0 for invalid zero-duration lecture',
      () {
        final start = DateTime(2026, 2, 9, 10, 0);
        final lecture = _lecture(start: start, end: start);

        final now = DateTime(2026, 2, 9, 10, 0);
        expect(calculateCheckInPoints(now, lecture), 0);
      },
    );

    test('calculateAttendancePoints returns 0 when checkout before start', () {
      final lecture = _lecture(
        start: DateTime(2026, 2, 9, 10, 0),
        end: DateTime(2026, 2, 9, 11, 0),
      );

      final checkIn = DateTime(2026, 2, 9, 9, 30);
      final checkout = DateTime(2026, 2, 9, 9, 59, 59);
      expect(calculateAttendancePoints(checkout, lecture, checkIn), 0);
    });

    test(
      'calculateAttendancePoints returns 0 when check-in is after lecture end',
      () {
        final lecture = _lecture(
          start: DateTime(2026, 2, 9, 10, 0),
          end: DateTime(2026, 2, 9, 11, 0),
        );

        final checkIn = DateTime(2026, 2, 9, 11, 0, 1);
        final checkout = DateTime(2026, 2, 9, 11, 5);
        expect(calculateAttendancePoints(checkout, lecture, checkIn), 0);
      },
    );

    test('canCheckInNow rejects negative distance as invalid border input', () {
      final lecture = _lecture(
        start: DateTime(2026, 2, 9, 10, 0),
        end: DateTime(2026, 2, 9, 11, 0),
      );

      final now = DateTime(2026, 2, 9, 10, 0);
      expect(canCheckInNow(now, lecture, distanceMeters: -0.1), isFalse);
    });
  });
}

Lecture _lecture({required DateTime start, required DateTime end}) {
  return Lecture(
    id: 'lec-inv-1',
    timetableId: 'tt-inv-1',
    title: 'Invalid Border Lecture',
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
