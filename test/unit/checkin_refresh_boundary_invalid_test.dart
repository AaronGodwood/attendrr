import 'package:flutter_test/flutter_test.dart';
import 'package:attendr/utils/checkin_refresh.dart';

void main() {
  group('UT-INV-02 Check-in refresh boundary and border timing', () {
    test('returns next slot when one second after boundary', () {
      final now = DateTime(2026, 2, 9, 10, 15, 1);
      final next = nextCheckInRefreshTime(now);
      expect(next, DateTime(2026, 2, 9, 10, 30, 0));
    });

    test('rolls to next hour at 59:59', () {
      final now = DateTime(2026, 2, 9, 10, 59, 59);
      final next = nextCheckInRefreshTime(now);
      expect(next, DateTime(2026, 2, 9, 11, 0, 0));
    });

    test('returns current hour :00 when exactly on :00:00', () {
      final now = DateTime(2026, 2, 9, 10, 0, 0);
      final next = nextCheckInRefreshTime(now);
      expect(next, DateTime(2026, 2, 9, 10, 0, 0));
    });
  });
}
