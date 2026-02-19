import 'package:flutter_test/flutter_test.dart';
import 'package:attendr/models/lecture.dart';
import 'package:attendr/utils/checkin_rules.dart';
import 'package:attendr/utils/location_lookup.dart';

void main() {
  group('UT-PERF Core logic performance regression guards', () {
    test('UT-PERF-01 calculateCheckInPoints stays within baseline runtime', () {
      final lecture = _lecture(
        start: DateTime(2026, 2, 9, 10, 0),
        end: DateTime(2026, 2, 9, 11, 0),
      );

      final stopwatch = Stopwatch()..start();
      var checksum = 0;

      for (var i = 0; i < 50000; i++) {
        final now = DateTime(2026, 2, 9, 10, i % 60);
        checksum += calculateCheckInPoints(now, lecture);
      }

      stopwatch.stop();
      expect(checksum, greaterThan(0));
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(4000),
        reason: 'Performance regression in calculateCheckInPoints',
      );
    });

    test('UT-PERF-02 canCheckInNow stays within baseline runtime', () {
      final lecture = _lecture(
        start: DateTime(2026, 2, 9, 10, 0),
        end: DateTime(2026, 2, 9, 11, 0),
      );

      final stopwatch = Stopwatch()..start();
      var allowedCount = 0;

      for (var i = 0; i < 50000; i++) {
        final now = DateTime(2026, 2, 9, 10, i % 60);
        if (canCheckInNow(now, lecture, distanceMeters: (i % 150).toDouble())) {
          allowedCount++;
        }
      }

      stopwatch.stop();
      expect(allowedCount, greaterThan(0));
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(4000),
        reason: 'Performance regression in canCheckInNow',
      );
    });

    test('UT-PERF-03 location resolution stays within baseline runtime', () {
      final stopwatch = Stopwatch()..start();
      var hits = 0;

      for (var i = 0; i < 20000; i++) {
        final query = i.isEven ? '1 West' : 'Unknown Building Name';
        final value = LocationLookup.resolve(query);
        if (value != null) hits++;
      }

      stopwatch.stop();
      expect(hits, greaterThan(0));
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(4000),
        reason: 'Performance regression in location alias resolution',
      );
    });
  });
}

Lecture _lecture({required DateTime start, required DateTime end}) {
  return Lecture(
    id: 'lec-perf-1',
    timetableId: 'tt-perf-1',
    title: 'Performance Lecture',
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
