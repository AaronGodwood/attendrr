import 'package:flutter_test/flutter_test.dart';
import 'package:attendr/models/models.dart';

void main() {
  group('Data Model Tests (Goal 4 - Data Storage)', () {

    test('User model correctly parses JSON data', () {
      final json = {
        'id': 'user-123',
        'email': 'test@bath.ac.uk',
        'username': 'student1',
        'university_id': '12345',
        'created_at': '2023-01-01T12:00:00Z',
        'updated_at': '2023-01-01T12:00:00Z',
      };

      final user = User.fromJson(json);

      expect(user.id, 'user-123');
      expect(user.email, 'test@bath.ac.uk');
      expect(user.initials, 'S');
    });

    test('Lecture model correctly calculates active status', () {
      final now = DateTime.now();
      final lecture = Lecture(
        id: 'lec-1',
        timetableId: 'time-1',
        title: 'Software Engineering',
        moduleCode: 'CM3001',
        location: '1 West',
        latitude: 0,
        longitude: 0,
        startTime: now.subtract(const Duration(minutes: 30)),
        endTime: now.add(const Duration(minutes: 20)),
        createdAt: now,
        updatedAt: now,
      );

      expect(lecture.isActive, true, reason: "Lecture should be active during its time window");
      expect(lecture.isPast, false);
    });
  });
}