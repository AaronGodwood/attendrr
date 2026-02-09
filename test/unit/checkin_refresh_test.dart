import 'package:flutter_test/flutter_test.dart';
import 'package:attendr/utils/checkin_refresh.dart';

void main() {
  group('UT-02 Check-in refresh schedule', () {
    test('UT-02a: returns next slot within the hour', () {
      final now = DateTime(2026, 2, 9, 10, 2, 12);
      final next = nextCheckInRefreshTime(now);
      expect(next, DateTime(2026, 2, 9, 10, 5, 0));
    });

    test('UT-02b: returns exact slot when on boundary', () {
      final now = DateTime(2026, 2, 9, 10, 15, 0);
      final next = nextCheckInRefreshTime(now);
      expect(next, DateTime(2026, 2, 9, 10, 15, 0));
    });

    test('UT-02d: targets :05 when just before', () {
      final now = DateTime(2026, 2, 9, 10, 4, 59);
      final next = nextCheckInRefreshTime(now);
      expect(next, DateTime(2026, 2, 9, 10, 5, 0));
    });

    test('UT-02c: rolls to next hour after :45', () {
      final now = DateTime(2026, 2, 9, 10, 46, 10);
      final next = nextCheckInRefreshTime(now);
      expect(next, DateTime(2026, 2, 9, 11, 0, 0));
    });
  });
}
