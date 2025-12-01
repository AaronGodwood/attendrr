import 'base_repository.dart';
import '../models/models.dart';

class LeaderboardRepository extends BaseRepository {
  static final LeaderboardRepository instance = LeaderboardRepository._();
  LeaderboardRepository._();

  Future<List<LeaderboardEntry>> getGlobalLeaderboard({int limit = 50}) async {
    final response = await client
        .from('points')
        .select('*, profiles!inner(id, username, avatar_url)')
        .order('total_points', ascending: false)
        .limit(limit);

    return (response as List).asMap().entries.map((e) {
      return LeaderboardEntry.fromJson(e.value, e.key + 1, currentUserId);
    }).toList();
  }

  Future<List<LeaderboardEntry>> getFriendsLeaderboard() async {
    requireAuth();

    // Get friend IDs
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

    final response = await client
        .from('points')
        .select('*, profiles!inner(id, username, avatar_url)')
        .inFilter('user_id', friendIds.toList())
        .order('total_points', ascending: false);

    return (response as List).asMap().entries.map((e) {
      return LeaderboardEntry.fromJson(e.value, e.key + 1, currentUserId);
    }).toList();
  }

  Future<int> getUserRank() async {
    requireAuth();
    final rank = await client.rpc('get_user_rank', params: {'p_user_id': currentUserId!});
    return rank as int? ?? 0;
  }
}