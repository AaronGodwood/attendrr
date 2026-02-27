import 'package:flutter_test/flutter_test.dart';
import 'package:attendr/models/building.dart';
import 'package:attendr/models/lecture.dart';
import 'package:attendr/utils/checkin_rules.dart';
import 'package:attendr/utils/location_lookup.dart';

void main() {
  group('UT-PERF Core logic performance regression guards', () {
    setUpAll(() {
      // Seed LocationLookup with representative data so resolve() has a real
      // alias table to search through, matching production behaviour.
      LocationLookup.seed([
        const Building(
          name: '1 West',
          latitude: 51.379924,
          longitude: -2.328749,
          aliases: ['1 West', '1 west', '1W', '1w'],
        ),
        const Building(
          name: '1 South',
          latitude: 51.37791,
          longitude: -2.33031,
          aliases: ['1 South', '1 south', '1S', '1s'],
        ),
        const Building(
          name: '1 West North',
          latitude: 51.38046,
          longitude: -2.32856,
          aliases: ['1 West North', '1 west north', '1WN', '1wn'],
        ),
        const Building(
          name: '2 East',
          latitude: 51.37825,
          longitude: -2.32558,
          aliases: ['2 East', '2 east', '2E', '2e'],
        ),
        const Building(
          name: '3 East',
          latitude: 51.37825,
          longitude: -2.32558,
          aliases: ['3 East', '3 east', '3E', '3e'],
        ),
        const Building(
          name: '4 East',
          latitude: 51.37825,
          longitude: -2.32558,
          aliases: ['4 East', '4 east', '4E', '4e'],
        ),
        const Building(
          name: '8 West',
          latitude: 51.3795,
          longitude: -2.33193,
          aliases: ['8 West', '8 west', '8W', '8w'],
        ),
        const Building(
          name: '10 West',
          latitude: 51.3795,
          longitude: -2.33193,
          aliases: ['10 West', '10 west', '10W', '10w'],
        ),
        const Building(
          name: 'Chancellors Building',
          latitude: 51.37900,
          longitude: -2.32800,
          aliases: ['Chancellors Building', 'chancellors building', 'CB'],
        ),
        const Building(
          name: 'Library',
          latitude: 51.37950,
          longitude: -2.32750,
          aliases: ['Library', 'library', 'Lib'],
        ),
      ]);
    });
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
