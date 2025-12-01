import 'base_repository.dart';
import '../models/models.dart';
import '../services/ical_service.dart';

class TimetableRepository extends BaseRepository {
  static final TimetableRepository instance = TimetableRepository._();
  TimetableRepository._();

  final _icalService = ICalService.instance;

  Future<Timetable> getUserTimetable() async {
    requireAuth();
    final response = await client
        .from('timetables')
        .select()
        .eq('user_id', currentUserId!)
        .single();
    return Timetable.fromJson(response);
  }

  Future<List<Lecture>> getAllLectures() async {
    requireAuth();
    final timetable = await getUserTimetable();
    final response = await client
        .from('lectures')
        .select()
        .eq('timetable_id', timetable.id)
        .order('start_time');
    return (response as List).map((json) => Lecture.fromJson(json)).toList();
  }

  Future<List<LectureWithAttendance>> getLecturesForWeek(DateTime weekStart) async {
    requireAuth();
    final weekEnd = weekStart.add(const Duration(days: 7));
    final timetable = await getUserTimetable();

    final response = await client
        .from('lectures')
        .select('*, attendance!left(id, points_earned)')
        .eq('timetable_id', timetable.id)
        .gte('start_time', weekStart.toIso8601String())
        .lt('start_time', weekEnd.toIso8601String())
        .order('start_time');

    return (response as List).map((json) => LectureWithAttendance.fromJson(json)).toList();
  }

  Future<Lecture?> getCurrentLecture() async {
    requireAuth();
    final now = DateTime.now();
    final timetable = await getUserTimetable();

    final response = await client
        .from('lectures')
        .select()
        .eq('timetable_id', timetable.id)
        .lte('start_time', now.toIso8601String())
        .gte('end_time', now.toIso8601String())
        .maybeSingle();

    return response != null ? Lecture.fromJson(response) : null;
  }

  Future<Lecture?> getNextLecture() async {
    requireAuth();
    final now = DateTime.now();
    final timetable = await getUserTimetable();

    final response = await client
        .from('lectures')
        .select()
        .eq('timetable_id', timetable.id)
        .gt('start_time', now.toIso8601String())
        .order('start_time')
        .limit(1)
        .maybeSingle();

    return response != null ? Lecture.fromJson(response) : null;
  }

  Future<SyncResult> syncFromIcal(String icalUrl) async {
    requireAuth();

    final allEvents = await _icalService.fetchAndParse(icalUrl);
    final lectures = _icalService.filterLectures(allEvents);
    final timetable = await getUserTimetable();

    await client.from('profiles').update({'ical_url': icalUrl}).eq('id', currentUserId!);

    int added = 0, updated = 0;

    for (final event in lectures) {
      final lectureData = event.toLectureJson(timetable.id);

      final existing = await client
          .from('lectures')
          .select('id')
          .eq('timetable_id', timetable.id)
          .eq('external_id', event.uid)
          .maybeSingle();

      if (existing != null) {
        await client.from('lectures').update(lectureData).eq('id', existing['id']);
        updated++;
      } else {
        await client.from('lectures').insert(lectureData);
        added++;
      }
    }

    await client.from('timetables').update({
      'last_synced_at': DateTime.now().toIso8601String(),
      'source': 'ical',
    }).eq('id', timetable.id);

    return SyncResult(total: allEvents.length, lectures: lectures.length, added: added, updated: updated);
  }
}

class SyncResult {
  final int total;
  final int lectures;
  final int added;
  final int updated;

  SyncResult({required this.total, required this.lectures, required this.added, required this.updated});

  @override
  String toString() => 'Synced $lectures lectures ($added new, $updated updated)';
}