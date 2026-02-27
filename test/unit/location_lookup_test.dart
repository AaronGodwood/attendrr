import 'package:flutter_test/flutter_test.dart';
import 'package:attendr/models/building.dart';
import 'package:attendr/utils/location_lookup.dart';
import 'package:attendr/services/ical_service.dart';

void main() {
  group('UT-03 Location lookup', () {
    setUp(() {
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
      ]);
    });
    test('UT-03a: resolves known building by name', () {
      final building = LocationLookup.resolve('1 West');
      expect(building, isNotNull);
      expect(building!.latitude, greaterThan(51.37));
      expect(building.longitude, lessThan(-2.32));
    });

    test('UT-03b: resolves known building by alias', () {
      final building = LocationLookup.resolve('1W');
      expect(building, isNotNull);
      expect(building!.name, contains('1 West'));
    });

    test('UT-03c: applies coordinates when parsing iCal event', () {
      final event = ICalEvent(
        uid: 'event-1',
        summary: 'CM1001 - Test Lecture',
        description: null,
        location: '1 West',
        dtStart: DateTime(2026, 2, 9, 10, 0),
        dtEnd: DateTime(2026, 2, 9, 11, 0),
        rrule: null,
      );

      final json = event.toLectureJson('timetable-1');
      expect(json['latitude'], isNot(0.0));
      expect(json['longitude'], isNot(0.0));
    });
  });
}
