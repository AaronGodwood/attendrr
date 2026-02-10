import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:attendr/models/lecture.dart';
import 'package:attendr/providers/timetable_provider.dart';
import 'package:attendr/pages/timetable_page.dart';

class MockTimetableProvider extends ChangeNotifier
    implements TimetableProvider {
  MockTimetableProvider(this._lectures);

  final List<LectureWithAttendance> _lectures;

  @override
  DateTime get selectedWeek => DateTime.now();
  @override
  bool get isLoading => false;
  @override
  String? get error => null;
  @override
  List<LectureWithAttendance> get lectures => _lectures;
  @override
  Map<int, List<LectureWithAttendance>> get lecturesByDay => {};
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
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WT-03 Timetable interactions', () {
    testWidgets('WT-03a: day selector is horizontally scrollable', (
      tester,
    ) async {
      final lecture = _buildLecture('lec-1');
      await tester.pumpWidget(
        ChangeNotifierProvider<TimetableProvider>.value(
          value: MockTimetableProvider([lecture]),
          child: const MaterialApp(home: TimetablePage()),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is ListView && widget.scrollDirection == Axis.horizontal,
        ),
        findsOneWidget,
      );
    });

    testWidgets('WT-03b: tapping a lecture shows details', (tester) async {
      final lecture = _buildLecture('lec-1');

      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ChangeNotifierProvider<TimetableProvider>.value(
          value: MockTimetableProvider([lecture]),
          child: const MaterialApp(home: TimetablePage()),
        ),
      );

      await tester.pumpAndSettle();

      final lectureFinder = find.byKey(const Key('lecture_lec-1'));
      await tester.ensureVisible(lectureFinder);
      await tester.tap(lectureFinder);
      await tester.pumpAndSettle();

      expect(find.text('CM1001 • Test Lecture'), findsOneWidget);
      expect(find.textContaining('Status:'), findsOneWidget);
    });
  });
}

LectureWithAttendance _buildLecture(String id) {
  final now = DateTime.now();
  final startHour = (now.hour < 7 || now.hour > 21) ? 10 : now.hour;
  final start = DateTime(now.year, now.month, now.day, startHour, 0);
  final end = start.add(const Duration(hours: 1));

  final lecture = Lecture(
    id: id,
    timetableId: 'tt-1',
    title: 'Test Lecture',
    moduleCode: 'CM1001',
    location: '1 West',
    latitude: 51.379924,
    longitude: -2.328749,
    startTime: start,
    endTime: end,
    createdAt: now,
    updatedAt: now,
  );

  return LectureWithAttendance(
    lecture: lecture,
    attended: false,
    attendanceId: null,
    pointsEarned: null,
  );
}
