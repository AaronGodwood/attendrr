import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:attendr/models/models.dart' as app_models;
import 'package:attendr/providers/auth_provider.dart';
import 'package:attendr/providers/profile_provider.dart';
import 'package:attendr/providers/timetable_provider.dart';
import 'package:attendr/providers/checkin_provider.dart';
import 'package:attendr/providers/friends_provider.dart';
import 'package:attendr/router/app_router.dart';
import 'package:attendr/services/location_service.dart';

class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  bool get isAuthenticated => true;
  @override
  AuthStatus get status => AuthStatus.authenticated;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockProfileProvider extends ChangeNotifier implements ProfileProvider {
  @override
  bool get isLoading => false;
  @override
  String? get error => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockTimetableProvider extends ChangeNotifier implements TimetableProvider {
  @override
  DateTime get selectedWeek => DateTime.now();
  @override
  bool get isLoading => false;
  @override
  String? get error => null;
  @override
  List<app_models.LectureWithAttendance> get lectures => const [];
  @override
  Map<int, List<app_models.LectureWithAttendance>> get lecturesByDay => const {};
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

class MockFriendsProvider extends ChangeNotifier implements FriendsProvider {
  @override
  bool get isLoading => false;
  @override
  String? get error => null;
  @override
  List<app_models.FriendWithStats> get friends => const [];
  @override
  List<app_models.FriendRequest> get requests => const [];
  @override
  List<app_models.LeaderboardEntry> get leaderboard => const [];
  @override
  bool get showGlobal => true;
  @override
  Future<void> loadFriends() async {}
  @override
  Future<void> loadLeaderboard() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('IT-Location: obtains a device position', (tester) async {
    final auth = MockAuthProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
          ChangeNotifierProvider<ProfileProvider>.value(value: MockProfileProvider()),
          ChangeNotifierProvider<TimetableProvider>.value(value: MockTimetableProvider()),
          ChangeNotifierProvider<CheckInProvider>(create: (_) => CheckInProvider()),
          ChangeNotifierProvider<FriendsProvider>.value(value: MockFriendsProvider()),
        ],
        child: MaterialApp.router(
          routerConfig: AppRouter.router(auth),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final position = await LocationService.instance.getCurrentPosition();
    expect(
      position,
      isNotNull,
      reason:
          'Location is null. Make sure simulator is booted, permissions granted, '
          'and a simulated location is set (use scripts/grant_ios_location.sh).',
    );
  });
}
