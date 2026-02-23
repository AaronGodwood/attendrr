import 'package:attendr/models/attendance.dart';
import 'package:attendr/models/models.dart' as app_models;
import 'package:attendr/models/points.dart';
import 'package:attendr/models/streak.dart';
import 'package:attendr/models/streak_evaluation.dart';
import 'package:attendr/pages/profile_page.dart';
import 'package:attendr/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

class FakeProfileProvider extends ChangeNotifier implements ProfileProvider {
  FakeProfileProvider({required this.user, required this.points});

  @override
  app_models.User? user;

  @override
  Points? points;

  @override
  Streak? streak;

  @override
  AttendanceStats? stats;

  @override
  List<DailyAttendance>? history = const [];

  @override
  StreakEvaluation? lastEvaluation;

  bool loadCalled = false;
  bool rewardMessageCleared = false;

  @override
  bool get isLoading => false;

  @override
  bool get isUploading => false;

  @override
  String? get error => null;

  @override
  String? milestoneRewardMessage =
      'Level-up reward unlocked: Streak Freeze, Weekly Points Boost';

  @override
  Future<void> loadProfile() async {
    loadCalled = true;
  }

  @override
  void clearEvaluation() {}

  @override
  void clearMilestoneRewardMessage() {
    rewardMessageCleared = true;
    milestoneRewardMessage = null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'AT-Profile-01 milestone trophies and level-up reward message are shown',
    (tester) async {
      final now = DateTime(2026, 2, 22);
      final provider = FakeProfileProvider(
        user: app_models.User(
          id: 'it-user-1',
          email: 'it@example.com',
          username: 'IntegrationUser',
          createdAt: now,
          updatedAt: now,
        ),
        points: Points(
          id: 'it-points-1',
          userId: 'it-user-1',
          totalPoints: 2200,
          weeklyPoints: 80,
          monthlyPoints: 320,
          weeklyBoostMultiplier: 1.0,
          weeklyBoostExpiresAt: null,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<ProfileProvider>.value(
          value: provider,
          child: const MaterialApp(home: ProfilePage()),
        ),
      );

      await tester.pumpAndSettle();

      expect(provider.loadCalled, isTrue);
      expect(find.text('2200 XP'), findsOneWidget);

      // Unlocked trophy chips at Expert tier.
      expect(find.text('Rising Scholar Trophy'), findsOneWidget);
      expect(find.text('Momentum Trophy'), findsOneWidget);
      expect(find.text('Expert Trophy'), findsOneWidget);

      // Next trophy guidance.
      expect(
        find.textContaining('Next trophy: Master Trophy at 5000 XP'),
        findsOneWidget,
      );

      // Level-up reward notification shown and acknowledged by provider.
      expect(find.textContaining('Level-up reward unlocked:'), findsOneWidget);
      expect(provider.rewardMessageCleared, isTrue);
    },
  );
}
