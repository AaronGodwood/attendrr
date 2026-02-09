// lib/repositories/lecture_repository.dart

import 'base_repository.dart';
import '../models/lecture.dart';

class LectureRepository extends BaseRepository {
  static final LectureRepository instance = LectureRepository._();
  LectureRepository._();

  /// Gets all lectures for current user
  Future<List<Lecture>> getAllLectures() async {
    requireAuth();

    final timetable =
        await client
            .from('timetables')
            .select('id')
            .eq('user_id', currentUserId!)
            .single();

    final response = await client
        .from('lectures')
        .select()
        .eq('timetable_id', timetable['id'])
        .order('start_time');

    return (response as List).map((json) => Lecture.fromJson(json)).toList();
  }

  /// Gets lectures for a specific week
  Future<List<Lecture>> getLecturesForWeek(DateTime weekStart) async {
    requireAuth();

    final weekEnd = weekStart.add(Duration(days: 7));

    final timetable =
        await client
            .from('timetables')
            .select('id')
            .eq('user_id', currentUserId!)
            .single();

    final response = await client
        .from('lectures')
        .select()
        .eq('timetable_id', timetable['id'])
        .gte('start_time', weekStart.toIso8601String())
        .lt('start_time', weekEnd.toIso8601String())
        .order('start_time');

    return (response as List).map((json) => Lecture.fromJson(json)).toList();
  }

  /// Gets lectures with attendance status for a week
  Future<List<LectureWithAttendance>> getLecturesWithAttendance(
    DateTime weekStart,
  ) async {
    requireAuth();

    final weekEnd = weekStart.add(Duration(days: 7));

    final timetable =
        await client
            .from('timetables')
            .select('id')
            .eq('user_id', currentUserId!)
            .single();

    final response = await client
        .from('lectures')
        .select('''
          *,
          attendance!left(id, check_in_time, points_earned)
        ''')
        .eq('timetable_id', timetable['id'])
        .gte('start_time', weekStart.toIso8601String())
        .lt('start_time', weekEnd.toIso8601String())
        .order('start_time');

    return (response as List).map((json) {
      final lecture = Lecture.fromJson(json);
      final attendanceList = json['attendance'] as List?;
      final attended = attendanceList != null && attendanceList.isNotEmpty;

      return LectureWithAttendance(
        lecture: lecture,
        attended: attended,
        attendanceId: attended ? attendanceList.first['id'] : null,
      );
    }).toList();
  }

  /// Gets the current active lecture (if any)
  Future<Lecture?> getCurrentLecture() async {
    requireAuth();

    final now = DateTime.now();

    final timetable =
        await client
            .from('timetables')
            .select('id')
            .eq('user_id', currentUserId!)
            .single();

    final response =
        await client
            .from('lectures')
            .select()
            .eq('timetable_id', timetable['id'])
            .lte('start_time', now.toIso8601String())
            .gte('end_time', now.toIso8601String())
            .maybeSingle();

    if (response == null) return null;
    return Lecture.fromJson(response);
  }

  /// Gets the next upcoming lecture
  Future<Lecture?> getNextLecture() async {
    requireAuth();

    final now = DateTime.now();

    final timetable =
        await client
            .from('timetables')
            .select('id')
            .eq('user_id', currentUserId!)
            .single();

    final response =
        await client
            .from('lectures')
            .select()
            .eq('timetable_id', timetable['id'])
            .gt('start_time', now.toIso8601String())
            .order('start_time')
            .limit(1)
            .maybeSingle();

    if (response == null) return null;
    return Lecture.fromJson(response);
  }

  /// Gets today's lectures
  Future<List<Lecture>> getTodaysLectures() async {
    requireAuth();

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    final timetable =
        await client
            .from('timetables')
            .select('id')
            .eq('user_id', currentUserId!)
            .single();

    final response = await client
        .from('lectures')
        .select()
        .eq('timetable_id', timetable['id'])
        .gte('start_time', startOfDay.toIso8601String())
        .lt('start_time', endOfDay.toIso8601String())
        .order('start_time');

    return (response as List).map((json) => Lecture.fromJson(json)).toList();
  }
}

class LectureWithAttendance {
  final Lecture lecture;
  final bool attended;
  final String? attendanceId;

  LectureWithAttendance({
    required this.lecture,
    required this.attended,
    this.attendanceId,
  });
}
