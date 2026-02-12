import 'base_repository.dart';
import '../models/models.dart';

class LeaderboardRepository extends BaseRepository {
  static final LeaderboardRepository instance = LeaderboardRepository._();
  LeaderboardRepository._();

  /// Unified entry point for all leaderboard queries.
  Future<List<LeaderboardEntry>> getLeaderboard({
    required LeaderboardCategory category,
    required bool global,
    int limit = 50,
  }) async {
    final filterIds = global ? null : await _getFriendIds();

    switch (category) {
      case LeaderboardCategory.totalPoints:
        return _getPointsLeaderboard(
          orderBy: 'total_points',
          limit: limit,
          filterIds: filterIds,
          displayUnit: 'pts',
          valueKey: 'total_points',
        );
      case LeaderboardCategory.weeklyPoints:
        return _getPointsLeaderboard(
          orderBy: 'weekly_points',
          limit: limit,
          filterIds: filterIds,
          displayUnit: 'pts',
          valueKey: 'weekly_points',
        );
      case LeaderboardCategory.currentStreak:
        return _getStreakLeaderboard(limit: limit, filterIds: filterIds);
      case LeaderboardCategory.attendanceRate:
        return _getAttendanceRateLeaderboard(
          limit: limit,
          userIds: filterIds,
        );
    }
  }

  // Keep for backward compat
  Future<List<LeaderboardEntry>> getGlobalLeaderboard({int limit = 50}) async {
    return getLeaderboard(
      category: LeaderboardCategory.totalPoints,
      global: true,
      limit: limit,
    );
  }

  Future<List<LeaderboardEntry>> getFriendsLeaderboard() async {
    return getLeaderboard(
      category: LeaderboardCategory.totalPoints,
      global: false,
    );
  }

  Future<int> getUserRank() async {
    requireAuth();
    final rank = await client.rpc(
      'get_user_rank',
      params: {'p_user_id': currentUserId!},
    );
    return rank as int? ?? 0;
  }

  // ─── Internal helpers ───────────────────────────────────────

  Future<List<String>> _getFriendIds() async {
    requireAuth();
    final friendships = await client
        .from('friendships')
        .select('user_id, friend_id')
        .or('user_id.eq.$currentUserId,friend_id.eq.$currentUserId')
        .eq('status', 'accepted');

    final friendIds = <String>{currentUserId!};
    for (final f in friendships as List) {
      friendIds.add(f['user_id'] as String);
      friendIds.add(f['friend_id'] as String);
    }
    return friendIds.toList();
  }

  Future<List<LeaderboardEntry>> _getPointsLeaderboard({
    required String orderBy,
    required int limit,
    required String displayUnit,
    required String valueKey,
    List<String>? filterIds,
  }) async {
    var query = client
        .from('points')
        .select('*, profiles!inner(id, username, avatar_url)');

    if (filterIds != null) {
      query = query.inFilter('user_id', filterIds);
    }

    final response = await query.order(orderBy, ascending: false).limit(limit);

    return (response as List).asMap().entries.map((e) {
      final entry = LeaderboardEntry.fromJson(e.value, e.key + 1, currentUserId);
      return entry.copyWith(
        displayValue: '${e.value[valueKey] ?? 0}',
        displayUnit: displayUnit,
      );
    }).toList();
  }

  Future<List<LeaderboardEntry>> _getStreakLeaderboard({
    required int limit,
    List<String>? filterIds,
  }) async {
    var query = client
        .from('streaks')
        .select('*, profiles!inner(id, username, avatar_url)');

    if (filterIds != null) {
      query = query.inFilter('user_id', filterIds);
    }

    final response = await query
        .order('current_streak', ascending: false)
        .limit(limit);

    return (response as List).asMap().entries.map((e) {
      final json = e.value as Map<String, dynamic>;
      final profile = json['profiles'] as Map<String, dynamic>? ?? json;
      final userId = profile['id'] as String? ?? json['user_id'] as String;
      final streak = json['current_streak'] as int? ?? 0;

      return LeaderboardEntry(
        rank: e.key + 1,
        userId: userId,
        username: profile['username'] as String? ?? 'Unknown',
        avatarUrl: profile['avatar_url'] as String?,
        totalPoints: 0,
        currentStreak: streak,
        isCurrentUser: userId == currentUserId,
        displayValue: '$streak',
        displayUnit: 'days',
      );
    }).toList();
  }

  Future<List<LeaderboardEntry>> _getAttendanceRateLeaderboard({
    required int limit,
    List<String>? userIds,
  }) async {
    final response = await client.rpc(
      'get_attendance_rate_leaderboard',
      params: {
        'p_user_ids': userIds,
        'p_limit': limit,
      },
    );

    return (response as List).asMap().entries.map((e) {
      final json = e.value as Map<String, dynamic>;
      final userId = json['user_id'] as String;
      final rate = (json['attendance_rate'] as num?)?.toDouble() ?? 0;

      return LeaderboardEntry(
        rank: e.key + 1,
        userId: userId,
        username: json['username'] as String? ?? 'Unknown',
        avatarUrl: json['avatar_url'] as String?,
        totalPoints: 0,
        attendanceRate: rate,
        isCurrentUser: userId == currentUserId,
        displayValue: rate.toStringAsFixed(1),
        displayUnit: '%',
      );
    }).toList();
  }
}
