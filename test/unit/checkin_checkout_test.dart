import 'package:flutter_test/flutter_test.dart';
import 'package:attendr/models/lecture.dart';
import 'package:attendr/utils/checkin_checkout.dart';

void main() {
  group('UT-05 Check-in auto checkout', () {
    test('UT-05a: returns false before lecture end', () {
      final lecture = _lecture(end: DateTime(2026, 2, 9, 10, 5));
      final now = DateTime(2026, 2, 9, 10, 4, 59);
      expect(shouldAutoCheckout(now, lecture), isFalse);
    });

    test('UT-05b: returns true after lecture end (5 past)', () {
      final lecture = _lecture(end: DateTime(2026, 2, 9, 10, 5));
      final now = DateTime(2026, 2, 9, 10, 5, 1);
      expect(shouldAutoCheckout(now, lecture), isTrue);
    });

    test('UT-05c: returns false with null lecture', () {
      final now = DateTime(2026, 2, 9, 10, 6);
      expect(shouldAutoCheckout(now, null), isFalse);
    });
  });
}

Lecture _lecture({required DateTime end}) {
  return Lecture(
    id: 'lec-1',
    timetableId: 'tt-1',
    title: 'Test Lecture',
    moduleCode: 'CM1001',
    location: '1 West',
    latitude: 51.379924,
    longitude: -2.328749,
    startTime: end.subtract(const Duration(hours: 1)),
    endTime: end,
    createdAt: end,
    updatedAt: end,
  );
}
