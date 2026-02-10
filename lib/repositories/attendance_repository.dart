import 'base_repository.dart';
import '../models/models.dart';

class AttendanceRepository extends BaseRepository {
  static final AttendanceRepository instance = AttendanceRepository._();
  AttendanceRepository._();

  Future<Attendance?> getActiveAttendance() async {
    requireAuth();
    final response =
        await client
            .from('attendance')
            .select('*, lectures(*)')
            .eq('user_id', currentUserId!)
            .isFilter('check_out_time', null)
            .maybeSingle();
    return response != null ? Attendance.fromJson(response) : null;
  }

  Future<Attendance> checkIn({
    required String lectureId,
    required bool locationVerified,
    double? distanceMeters,
    required int pointsEarned,
  }) async {
    requireAuth();

    final response =
        await client
            .from('attendance')
            .insert({
              'user_id': currentUserId!,
              'lecture_id': lectureId,
              'check_in_time': DateTime.now().toIso8601String(),
              'location_verified': locationVerified,
              'distance_meters': distanceMeters,
              'points_earned': pointsEarned,
            })
            .select()
            .single();

    // Update points and streak
    await client.rpc(
      'add_points',
      params: {'p_user_id': currentUserId!, 'p_points': pointsEarned},
    );
    await client.rpc('update_streak', params: {'p_user_id': currentUserId!});

    return Attendance.fromJson(response);
  }

  Future<void> updatePoints({
    required String attendanceId,
    required int pointsEarned,
  }) async {
    await client
        .from('attendance')
        .update({'points_earned': pointsEarned})
        .eq('id', attendanceId);
  }

  Future<void> adjustUserPoints(int delta) async {
    if (delta == 0) return;
    await client.rpc(
      'add_points',
      params: {'p_user_id': currentUserId!, 'p_points': delta},
    );
  }

  Future<void> checkOut(String attendanceId) async {
    await client
        .from('attendance')
        .update({'check_out_time': DateTime.now().toIso8601String()})
        .eq('id', attendanceId);
  }

  Future<AttendanceStats> getStats() async {
    requireAuth();
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday));
    final monthStart = DateTime(now.year, now.month, 1);

    final timetable =
        await client
            .from('timetables')
            .select('id')
            .eq('user_id', currentUserId!)
            .single();

    final allAttendance = await client
        .from('attendance')
        .select('check_in_time')
        .eq('user_id', currentUserId!);

    final pastLectures = await client
        .from('lectures')
        .select('id, start_time')
        .eq('timetable_id', timetable['id'])
        .lte('end_time', now.toIso8601String());

    final attendanceList = allAttendance as List;
    final lectureList = pastLectures as List;

    int weeklyAttended = 0, monthlyAttended = 0;
    int weeklyTotal = 0, monthlyTotal = 0;

    for (final a in attendanceList) {
      final date = DateTime.parse(a['check_in_time']);
      if (date.isAfter(weekStart)) weeklyAttended++;
      if (date.isAfter(monthStart)) monthlyAttended++;
    }

    for (final l in lectureList) {
      final date = DateTime.parse(l['start_time']);
      if (date.isAfter(weekStart)) weeklyTotal++;
      if (date.isAfter(monthStart)) monthlyTotal++;
    }

    return AttendanceStats(
      weeklyAttended: weeklyAttended,
      weeklyTotal: weeklyTotal,
      monthlyAttended: monthlyAttended,
      monthlyTotal: monthlyTotal,
      overallAttended: attendanceList.length,
      overallTotal: lectureList.length,
    );
  }

  Future<List<DailyAttendance>> getHistory(int days) async {
    requireAuth();
    final startDate = DateTime.now().subtract(Duration(days: days));

    final response = await client
        .from('attendance')
        .select('check_in_time')
        .eq('user_id', currentUserId!)
        .gte('check_in_time', startDate.toIso8601String());

    final Map<String, int> byDate = {};
    for (final r in response as List) {
      final date = DateTime.parse(r['check_in_time']);
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      byDate[key] = (byDate[key] ?? 0) + 1;
    }

    final result = <DailyAttendance>[];
    for (int i = days - 1; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      result.add(DailyAttendance(date: date, count: byDate[key] ?? 0));
    }
    return result;
  }

  // Methods to get other users' stats and history
  Future<AttendanceStats> getUserStats(String userId) async {
    requireAuth();
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday));
    final monthStart = DateTime(now.year, now.month, 1);

    // Check if user has a timetable
    final timetableResponse =
        await client
            .from('timetables')
            .select('id')
            .eq('user_id', userId)
            .maybeSingle();

    // If no timetable, return empty stats
    if (timetableResponse == null) {
      return AttendanceStats(
        weeklyAttended: 0,
        weeklyTotal: 0,
        monthlyAttended: 0,
        monthlyTotal: 0,
        overallAttended: 0,
        overallTotal: 0,
      );
    }

    final allAttendance = await client
        .from('attendance')
        .select('check_in_time')
        .eq('user_id', userId);

    final pastLectures = await client
        .from('lectures')
        .select('id, start_time')
        .eq('timetable_id', timetableResponse['id'])
        .lte('end_time', now.toIso8601String());

    final attendanceList = allAttendance as List;
    final lectureList = pastLectures as List;

    int weeklyAttended = 0, monthlyAttended = 0;
    int weeklyTotal = 0, monthlyTotal = 0;

    for (final a in attendanceList) {
      final date = DateTime.parse(a['check_in_time']);
      if (date.isAfter(weekStart)) weeklyAttended++;
      if (date.isAfter(monthStart)) monthlyAttended++;
    }

    for (final l in lectureList) {
      final date = DateTime.parse(l['start_time']);
      if (date.isAfter(weekStart)) weeklyTotal++;
      if (date.isAfter(monthStart)) monthlyTotal++;
    }

    return AttendanceStats(
      weeklyAttended: weeklyAttended,
      weeklyTotal: weeklyTotal,
      monthlyAttended: monthlyAttended,
      monthlyTotal: monthlyTotal,
      overallAttended: attendanceList.length,
      overallTotal: lectureList.length,
    );
  }

  Future<List<DailyAttendance>> getUserHistory(String userId, int days) async {
    requireAuth();
    final startDate = DateTime.now().subtract(Duration(days: days));

    final response = await client
        .from('attendance')
        .select('check_in_time')
        .eq('user_id', userId)
        .gte('check_in_time', startDate.toIso8601String());

    final Map<String, int> byDate = {};
    for (final r in response as List) {
      final date = DateTime.parse(r['check_in_time']);
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      byDate[key] = (byDate[key] ?? 0) + 1;
    }

    final result = <DailyAttendance>[];
    for (int i = days - 1; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      result.add(DailyAttendance(date: date, count: byDate[key] ?? 0));
    }
    return result;
  }
}
