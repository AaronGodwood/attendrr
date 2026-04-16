import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:attendr/models/models.dart';
import 'package:attendr/widgets/profile/streak_card.dart';
import 'package:attendr/widgets/profile/attendance_chart.dart';
import 'package:attendr/widgets/profile/attendance_ring_card.dart';
import 'package:attendr/widgets/profile/profile_skeleton.dart';
import 'package:attendr/widgets/common/skeleton_loader.dart';
import 'package:attendr/widgets/settings/ical_setup_dialog.dart';
import 'package:attendr/widgets/checkin/checkin_skeleton.dart';
import 'package:attendr/widgets/timetable/timetable_skeleton.dart';
import 'package:provider/provider.dart';
import 'package:attendr/providers/timetable_provider.dart';

class MockTimetableProvider extends ChangeNotifier
    implements TimetableProvider {
  @override
  String? get error => null;

  @override
  DateTime get selectedWeek => DateTime.now();

  @override
  bool get isLoading => false;

  @override
  List<LectureWithAttendance> get lectures => const [];

  @override
  Map<int, List<LectureWithAttendance>> get lecturesByDay => const {};

  @override
  Future<bool> syncFromIcal(String url) async => true;

  @override
  SyncResult? get lastSyncResult => null;

  @override
  Future<void> loadWeek([DateTime? week]) async {}

  @override
  void goToToday() {}

  @override
  void nextWeek() {}

  @override
  void previousWeek() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('Profile widgets render with sample data', (tester) async {
    final now = DateTime.now();
    final streak = Streak(
      id: 's1',
      userId: 'u1',
      currentStreak: 12,
      longestStreak: 15,
      streakFreezes: 2,
      lastAttendanceDate: now,
      createdAt: now,
      updatedAt: now,
    );

    const stats = AttendanceStats(
      weeklyAttended: 3,
      weeklyTotal: 5,
      monthlyAttended: 12,
      monthlyTotal: 20,
      overallAttended: 40,
      overallTotal: 60,
    );

    final data = List.generate(
      30,
      (i) => DailyAttendance(
        date: now.subtract(Duration(days: 29 - i)),
        count: i.isEven ? 1 : 0,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                StreakCard(streak: streak),
                const AttendanceRingCard(stats: stats),
                AttendanceChart(data: data),
                const ProfileSkeleton(),
                const SkeletonLoader(width: 100, height: 10),
                const CheckInSkeleton(),
                const SizedBox(height: 300, child: TimetableSkeleton()),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Day Streak'), findsOneWidget);
    expect(find.text('Attendance'), findsOneWidget);
    expect(find.text('Last 30 Days'), findsOneWidget);
  });

  testWidgets('iCal setup dialog renders and validates empty url', (
    tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<TimetableProvider>.value(
            value: MockTimetableProvider(),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: ICalSetupDialog())),
      ),
    );

    await tester.tap(find.text('Import'));
    await tester.pump();

    expect(find.text('Please enter a URL'), findsOneWidget);
  });
}
