import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:attendr/models/models.dart' as app_models;
import 'package:attendr/providers/auth_provider.dart';
import 'package:attendr/providers/profile_provider.dart';
import 'package:attendr/providers/timetable_provider.dart';
import 'package:attendr/providers/checkin_provider.dart';
import 'package:attendr/providers/friends_provider.dart';
import 'package:attendr/router/app_router.dart';
import 'package:attendr/pages/timetable_page.dart';
import 'package:attendr/pages/checkin_page.dart';
import 'package:attendr/pages/friends_page.dart';
import 'package:attendr/pages/profile_page.dart';

// --- MOCK PROVIDERS ---

class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  bool get isAuthenticated => true;
  @override
  AuthStatus get status => AuthStatus.authenticated;
  @override
  sb.User? get user => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockTimetableProvider extends ChangeNotifier
    implements TimetableProvider {
  @override
  DateTime get selectedWeek => DateTime.now();
  @override
  bool get isLoading => false;
  @override
  String? get error => null;
  @override
  List<app_models.LectureWithAttendance> get lectures => [];
  @override
  Map<int, List<app_models.LectureWithAttendance>> get lecturesByDay => {};
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

class MockProfileProvider extends ChangeNotifier implements ProfileProvider {
  @override
  bool get isLoading => false;
  @override
  bool get isUploading => false;
  @override
  String? get error => null;
  @override
  app_models.User? get user => app_models.User(
    id: 'test-user',
    email: 'test@test.com',
    username: 'TestUser',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  @override
  app_models.Streak? get streak => null;
  @override
  app_models.Points? get points => null;
  @override
  app_models.AttendanceStats? get stats => null;
  @override
  List<app_models.DailyAttendance>? get history => [];
  @override
  app_models.StreakEvaluation? get lastEvaluation => null;
  @override
  Future<void> loadProfile() async {}
  @override
  void clearEvaluation() {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockCheckInProvider extends ChangeNotifier implements CheckInProvider {
  @override
  CheckInState get state => CheckInState.noLecture;
  @override
  String? get error => null;
  @override
  app_models.Lecture? get currentLecture => null;
  @override
  app_models.Lecture? get nextLecture => null;
  @override
  app_models.Attendance? get activeAttendance => null;
  @override
  double? get distance => null;
  @override
  Duration? get timeUntilNext => null;
  @override
  Duration? get timeRemaining => null;
  @override
  Future<void> loadState() async {}
  @override
  Future<void> refresh() async {}
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class MockFriendsProvider extends ChangeNotifier implements FriendsProvider {
  @override
  bool get isLoading => false;
  @override
  String? get error => null;
  @override
  List<app_models.FriendWithStats> get friends => [];
  @override
  List<app_models.FriendRequest> get requests => [];
  @override
  List<app_models.LeaderboardEntry> get leaderboard => [];
  @override
  bool get showGlobal => true;
  @override
  Future<void> loadFriends() async {}
  @override
  Future<void> loadLeaderboard() async {}
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

// --- TEST MAIN ---

void main() {
  testWidgets('Navigation Structure Test (Goal 2)', (
    WidgetTester tester,
  ) async {
    final mockAuth = MockAuthProvider();

    final router = AppRouter.router(mockAuth);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuth),
          ChangeNotifierProvider<ProfileProvider>.value(
            value: MockProfileProvider(),
          ),
          ChangeNotifierProvider<TimetableProvider>.value(
            value: MockTimetableProvider(),
          ),
          ChangeNotifierProvider<CheckInProvider>.value(
            value: MockCheckInProvider(),
          ),
          ChangeNotifierProvider<FriendsProvider>.value(
            value: MockFriendsProvider(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await _pumpUntilFound(
      tester,
      anyOf: [find.byType(TimetablePage)],
      timeout: const Duration(seconds: 3),
    );

    expect(find.byType(TimetablePage), findsOneWidget);

    router.go('/checkin');
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(CheckInPage, skipOffstage: false), findsOneWidget);

    router.go('/friends');
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(FriendsPage, skipOffstage: false), findsOneWidget);

    router.go('/profile');
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(ProfilePage, skipOffstage: false), findsOneWidget);
  });
}

Future<void> _pumpUntilFound(
  WidgetTester tester, {
  required List<Finder> anyOf,
  required Duration timeout,
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    for (final finder in anyOf) {
      if (finder.evaluate().isNotEmpty) return;
    }
  }
}
