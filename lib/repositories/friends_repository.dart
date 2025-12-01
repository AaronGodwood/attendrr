import 'base_repository.dart';
import '../models/models.dart';

class FriendsRepository extends BaseRepository {
  static final FriendsRepository instance = FriendsRepository._();
  FriendsRepository._();

  Future<List<FriendWithStats>> getFriends() async {
    requireAuth();

    final response = await client
        .from('friendships')
        .select('''
          id,
          user_id,
          friend_id,
          profiles!friendships_friend_id_fkey(id, username, avatar_url),
          user:profiles!friendships_user_id_fkey(id, username, avatar_url)
        ''')
        .or('user_id.eq.$currentUserId,friend_id.eq.$currentUserId')
        .eq('status', 'accepted');

    final friends = <FriendWithStats>[];

    for (final f in response as List) {
      final isUserSide = f['user_id'] == currentUserId;
      final friendProfile = isUserSide ? f['profiles'] : f['user'];
      final friendId = friendProfile['id'] as String;

      // Get friend's stats
      final streakRes = await client.from('streaks').select('current_streak').eq('user_id', friendId).maybeSingle();
      final pointsRes = await client.from('points').select('total_points').eq('user_id', friendId).maybeSingle();

      friends.add(FriendWithStats(
        id: friendId,
        username: friendProfile['username'] as String,
        avatarUrl: friendProfile['avatar_url'] as String?,
        currentStreak: streakRes?['current_streak'] as int? ?? 0,
        totalPoints: pointsRes?['total_points'] as int? ?? 0,
        friendshipId: f['id'] as String,
      ));
    }

    return friends;
  }

  Future<List<FriendRequest>> getPendingRequests() async {
    requireAuth();

    final response = await client
        .from('friendships')
        .select('*, profiles!friendships_user_id_fkey(id, username, avatar_url)')
        .eq('friend_id', currentUserId!)
        .eq('status', 'pending');

    return (response as List).map((json) => FriendRequest.fromJson({
      ...json,
      'sender': json['profiles'],
    })).toList();
  }

  Future<void> sendRequest(String friendId) async {
    requireAuth();

    final existing = await client
        .from('friendships')
        .select('id')
        .or('and(user_id.eq.$currentUserId,friend_id.eq.$friendId),and(user_id.eq.$friendId,friend_id.eq.$currentUserId)')
        .maybeSingle();

    if (existing != null) {
      throw Exception('Friend request already exists');
    }

    await client.from('friendships').insert({
      'user_id': currentUserId!,
      'friend_id': friendId,
      'status': 'pending',
    });
  }

  Future<void> acceptRequest(String friendshipId) async {
    await client
        .from('friendships')
        .update({'status': 'accepted'})
        .eq('id', friendshipId)
        .eq('friend_id', currentUserId!);
  }

  Future<void> rejectRequest(String friendshipId) async {
    await client
        .from('friendships')
        .update({'status': 'rejected'})
        .eq('id', friendshipId)
        .eq('friend_id', currentUserId!);
  }

  Future<void> removeFriend(String friendshipId) async {
    await client.from('friendships').delete().eq('id', friendshipId);
  }
}