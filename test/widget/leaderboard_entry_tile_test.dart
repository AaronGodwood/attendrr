import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:attendr/models/leaderboard_entry.dart';
import 'package:attendr/widgets/friends/leaderboard_entry_tile.dart';

void main() {
  group('WT-06 Leaderboard entry tile', () {
    testWidgets('WT-06a: rank badge fits #10 on one line', (tester) async {
      const entry = LeaderboardEntry(
        rank: 10,
        userId: 'u10',
        username: 'Ten',
        totalPoints: 10,
        displayValue: '10',
        displayUnit: 'pts',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LeaderboardEntryTile(entry: entry),
          ),
        ),
      );

      expect(find.text('#10'), findsOneWidget);
      expect(find.byType(FittedBox), findsWidgets);

      final sizedBoxFinder = find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.width == 48,
      );
      expect(sizedBoxFinder, findsOneWidget);
    });
  });
}
