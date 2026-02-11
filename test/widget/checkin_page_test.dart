import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:attendr/models/models.dart';
import 'package:attendr/pages/checkin_page.dart';
import 'package:attendr/providers/checkin_provider.dart';

class MockCheckInProvider extends ChangeNotifier implements CheckInProvider {
  MockCheckInProvider({
    required this.mockState,
    required this.mockLecture,
    required this.mockAttendance,
  });

  CheckInState mockState;
  final Lecture? mockLecture;
  Attendance? mockAttendance;

  @override
  CheckInState get state => mockState;
  @override
  Lecture? get currentLecture => mockLecture;
  @override
  Lecture? get nextLecture => null;
  @override
  Attendance? get activeAttendance => mockAttendance;
  @override
  double? get distance => null;
  @override
  String? get error => null;
  @override
  Duration? get timeUntilNext => null;
  @override
  Duration? get timeRemaining => mockLecture?.timeRemaining;
  @override
  Future<void> loadState() async {}
  @override
  Future<void> refresh() async {}
  @override
  Future<void> checkOut() async {
    if (mockAttendance == null) return;
    mockAttendance = mockAttendance!.copyWith(pointsEarned: 5);
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('WT-05 Check-in auto checkout UI', () {
    testWidgets('WT-05a: hides End Session Early after lecture ends', (
      tester,
    ) async {
      final lecture = _lecture(ended: true);
      final attendance = _attendance(lecture);

      await tester.pumpWidget(
        ChangeNotifierProvider<CheckInProvider>.value(
          value: MockCheckInProvider(
            mockState: CheckInState.checkedIn,
            mockLecture: lecture,
            mockAttendance: attendance,
          ),
          child: const MaterialApp(home: CheckInPage()),
        ),
      );

      await tester.pump();

      expect(find.text('End Session Early'), findsNothing);
    });

    testWidgets('WT-05b: shows End Session Early when lecture active', (
      tester,
    ) async {
      final lecture = _lecture(ended: false);
      final attendance = _attendance(lecture);

      await tester.pumpWidget(
        ChangeNotifierProvider<CheckInProvider>.value(
          value: MockCheckInProvider(
            mockState: CheckInState.checkedIn,
            mockLecture: lecture,
            mockAttendance: attendance,
          ),
          child: const MaterialApp(home: CheckInPage()),
        ),
      );

      await tester.pump();

      expect(find.text('End Session Early'), findsOneWidget);
    });

    testWidgets('WT-05c: early checkout updates points in UI', (tester) async {
      final lecture = _lecture(ended: false);
      final attendance = _attendance(lecture);

      await tester.pumpWidget(
        ChangeNotifierProvider<CheckInProvider>.value(
          value: MockCheckInProvider(
            mockState: CheckInState.checkedIn,
            mockLecture: lecture,
            mockAttendance: attendance,
          ),
          child: const MaterialApp(home: CheckInPage()),
        ),
      );

      await tester.pump();
      expect(find.text('+10 points'), findsOneWidget);

      await tester.tap(find.text('End Session Early'));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('End Session'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('+5 points'), findsOneWidget);
    });
  });
}

Lecture _lecture({required bool ended}) {
  final now = DateTime.now();
  final start = now.subtract(const Duration(minutes: 50));
  final end =
      ended
          ? now.subtract(const Duration(minutes: 1))
          : now.add(const Duration(minutes: 10));

  return Lecture(
    id: 'lec-1',
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
}

Attendance _attendance(Lecture lecture) {
  final now = DateTime.now();
  return Attendance(
    id: 'att-1',
    userId: 'user-1',
    lectureId: lecture.id,
    checkInTime: now.subtract(const Duration(minutes: 40)),
    checkOutTime: null,
    locationVerified: true,
    distanceMeters: 10,
    pointsEarned: 10,
    createdAt: now,
    lecture: lecture,
  );
}
