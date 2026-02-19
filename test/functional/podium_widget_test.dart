import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:attendr/models/leaderboard_entry.dart';
import 'package:attendr/widgets/friends/podium_widget.dart';

void main() {
  group('WT-04 Podium layout', () {
    testWidgets('WT-04a: podium does not enforce fixed height', (tester) async {
      final entries = [
        const LeaderboardEntry(
          rank: 1,
          userId: 'u1',
          username: 'VeryLongUsernameHere',
          totalPoints: 120,
          displayValue: '120',
          displayUnit: 'pts',
        ),
        const LeaderboardEntry(
          rank: 2,
          userId: 'u2',
          username: 'Alice',
          totalPoints: 100,
          displayValue: '100',
          displayUnit: 'pts',
        ),
        const LeaderboardEntry(
          rank: 3,
          userId: 'u3',
          username: 'Bob',
          totalPoints: 90,
          displayValue: '90',
          displayUnit: 'pts',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PodiumWidget(topThree: entries),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final fixedHeightBox = find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == 250,
      );
      expect(fixedHeightBox, findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
