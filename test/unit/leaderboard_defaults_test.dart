import 'package:flutter_test/flutter_test.dart';
import 'package:attendr/providers/friends_provider.dart';
import 'package:attendr/models/leaderboard_category.dart';

void main() {
  test('UT-07 Leaderboard defaults to weekly points', () {
    final provider = FriendsProvider();
    expect(provider.category, LeaderboardCategory.weeklyPoints);
  });
}
