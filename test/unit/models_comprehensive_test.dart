import 'package:flutter_test/flutter_test.dart';
import 'package:attendr/models/models.dart';

void main() {
  group('Model behavior and serialization', () {
    test('Attendance model json, copyWith, and stats helpers', () {
      final lectureJson = {
        'id': 'l1',
        'timetable_id': 't1',
        'title': 'SE',
        'module_code': 'CM3001',
        'location': '1 West',
        'latitude': 1.0,
        'longitude': 2.0,
        'start_time': DateTime(2026, 1, 1, 10).toIso8601String(),
        'end_time': DateTime(2026, 1, 1, 11).toIso8601String(),
        'created_at': DateTime(2026, 1, 1).toIso8601String(),
        'updated_at': DateTime(2026, 1, 1).toIso8601String(),
      };
      final att = Attendance.fromJson({
        'id': 'a1',
        'user_id': 'u1',
        'lecture_id': 'l1',
        'check_in_time': DateTime(2026, 1, 1, 10).toIso8601String(),
        'location_verified': true,
        'distance_meters': 10.0,
        'points_earned': 8,
        'created_at': DateTime(2026, 1, 1).toIso8601String(),
        'lectures': lectureJson,
      });
      expect(att.toJson()['id'], 'a1');
      expect(att.toInsertJson()['lecture_id'], 'l1');
      expect(att.copyWith(pointsEarned: 9).pointsEarned, 9);
      expect(att.isActive, isTrue);
      expect(att.sessionDuration.inSeconds, greaterThanOrEqualTo(0));

      const stats = AttendanceStats(
        weeklyAttended: 2,
        weeklyTotal: 4,
        monthlyAttended: 3,
        monthlyTotal: 6,
        overallAttended: 5,
        overallTotal: 10,
      );
      expect(stats.weeklyPercent, 50);
      expect(stats.monthlyPercent, 50);
      expect(stats.overallPercent, 50);
      expect(AttendanceStats.empty().overallPercent, 0);
    });

    test('Lecture and LectureWithAttendance state behavior', () {
      final now = DateTime.now();
      final lecture = Lecture(
        id: 'l1',
        timetableId: 't1',
        title: 'SE',
        moduleCode: 'CM3001',
        location: '1 West',
        latitude: 51.3,
        longitude: -2.3,
        startTime: now.subtract(const Duration(minutes: 30)),
        endTime: now.add(const Duration(minutes: 30)),
        createdAt: now,
        updatedAt: now,
      );

      expect(lecture.isActive, isTrue);
      expect(lecture.isUpcoming, isFalse);
      expect(lecture.isPast, isFalse);
      expect(lecture.durationMinutes, 60);
      expect(lecture.timeRange, contains('-'));
      expect(lecture.hasValidCoordinates, isTrue);
      expect(lecture.dayOfWeek, inInclusiveRange(1, 7));
      expect(lecture.color, isNotNull);

      final json = lecture.toJson();
      expect(Lecture.fromJson(json).id, lecture.id);
      expect(lecture.toInsertJson()['module_code'], 'CM3001');
      expect(lecture.copyWith(title: 'New').title, 'New');

      final lwa = LectureWithAttendance.fromJson({
        ...json,
        'attendance': [
          {'id': 'a1', 'points_earned': 7},
        ],
      });
      expect(lwa.attended, isTrue);
      expect(lwa.status, LectureStatus.attended);

      final lwa2 = LectureWithAttendance(
        lecture: Lecture(
          id: 'l2',
          timetableId: 't2',
          title: 'Later',
          moduleCode: 'CM1000',
          location: 'Nowhere',
          latitude: 0,
          longitude: 0,
          startTime: DateTime(2999),
          endTime: DateTime(2999, 1, 1, 1),
          createdAt: DateTime(2999),
          updatedAt: DateTime(2999),
        ),
        attended: false,
      );
      expect(lwa2.status, LectureStatus.upcoming);
    });

    test('Timetable and User model behavior', () {
      final now = DateTime.now();

      final tt = Timetable.fromJson({
        'id': 'tt1',
        'user_id': 'u1',
        'name': 'Main',
        'source': 'ical',
        'last_synced_at':
            now.subtract(const Duration(hours: 13)).toIso8601String(),
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });
      expect(tt.sourceString, 'ical');
      expect(tt.needsSync, isTrue);
      expect(tt.copyWith(name: 'New').name, 'New');
      expect(
        Timetable.fromJson({
          'id': 'tt2',
          'user_id': 'u1',
          'name': 'M',
          'source': 'unknown',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        }).source,
        TimetableSource.manual,
      );

      final user = User.fromJson({
        'id': 'u1',
        'email': 'x@test.com',
        'username': 'x',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });
      expect(user.initials, 'X');
      expect(user.hasIcalConnected, isFalse);
      expect(user.copyWith(icalUrl: 'https://ical').hasIcalConnected, isTrue);
    });
  });
}
