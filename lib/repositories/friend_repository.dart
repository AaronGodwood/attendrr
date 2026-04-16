import 'base_repository.dart';
import '../models/models.dart';

class FriendRepository extends BaseRepository {
  static final FriendRepository instance = FriendRepository._();
  FriendRepository._();

  /// Returns the IDs of users the current user has added as friends.
  Future<List<String>> getFriendIds() async {
    requireAuth();
    final response = await client
        .from('friendships')
        .select('friend_id')
        .eq('user_id', currentUserId!);
    return (response as List)
        .map((row) => row['friend_id'] as String)
        .toList();
  }

  Future<bool> isFriend(String friendId) async {
    requireAuth();
    final response = await client
        .from('friendships')
        .select('id')
        .eq('user_id', currentUserId!)
        .eq('friend_id', friendId)
        .maybeSingle();
    return response != null;
  }

  Future<void> addFriend(String friendId) async {
    requireAuth();
    await client.from('friendships').insert({
      'user_id': currentUserId!,
      'friend_id': friendId,
    });
  }

  Future<void> removeFriend(String friendId) async {
    requireAuth();
    await client
        .from('friendships')
        .delete()
        .eq('user_id', currentUserId!)
        .eq('friend_id', friendId);
  }
}
