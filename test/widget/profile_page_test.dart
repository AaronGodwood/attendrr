import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:attendr/pages/profile_page.dart';
import 'package:attendr/providers/profile_provider.dart';
import 'package:attendr/models/user.dart' as app_models;
import 'package:attendr/models/points.dart';
import 'package:attendr/models/streak.dart';
import 'package:attendr/models/attendance.dart';
import 'package:attendr/models/streak_evaluation.dart';

class MockProfileProvider extends ChangeNotifier implements ProfileProvider {
  MockProfileProvider({required this.user, required this.points});

  @override
  app_models.User? user;

  @override
  Points? points;

  @override
  Streak? streak;

  @override
  AttendanceStats? stats;

  @override
  List<DailyAttendance>? history;

  @override
  StreakEvaluation? lastEvaluation;

  @override
  bool get isLoading => false;

  @override
  bool get isUploading => false;

  @override
  String? get error => null;

  @override
  Future<void> loadProfile() async {}

  @override
  void clearEvaluation() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('WT-08 Profile shows coin balance', (tester) async {
    final now = DateTime(2025, 1, 1);
    final user = app_models.User(
      id: 'user-1',
      email: 'test@example.com',
      username: 'tester',
      createdAt: now,
      updatedAt: now,
    );
    final points = Points(
      id: 'points-1',
      userId: 'user-1',
      totalPoints: 120,
      weeklyPoints: 30,
      monthlyPoints: 60,
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<ProfileProvider>.value(
        value: MockProfileProvider(user: user, points: points),
        child: const MaterialApp(home: ProfilePage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('120 coins'), findsOneWidget);
  });
}
