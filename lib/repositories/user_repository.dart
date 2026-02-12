import 'base_repository.dart';
import '../models/models.dart';

class UserRepository extends BaseRepository {
  static final UserRepository instance = UserRepository._();
  UserRepository._();

  Future<User> getCurrentUser() async {
    requireAuth();
    final response =
        await client
            .from('profiles')
            .select()
            .eq('id', currentUserId!)
            .single();
    return User.fromJson(response);
  }

  Future<Streak> getCurrentStreak() async {
    requireAuth();
    final response =
        await client
            .from('streaks')
            .select()
            .eq('user_id', currentUserId!)
            .single();
    return Streak.fromJson(response);
  }

  Future<Points> getCurrentPoints() async {
    requireAuth();
    final response =
        await client
            .from('points')
            .select()
            .eq('user_id', currentUserId!)
            .single();
    return Points.fromJson(response);
  }

  Future<({User user, Streak streak, Points points})> getFullProfile() async {
    requireAuth();
    final results = await Future.wait([
      getCurrentUser(),
      getCurrentStreak(),
      getCurrentPoints(),
    ]);
    return (
      user: results[0] as User,
      streak: results[1] as Streak,
      points: results[2] as Points,
    );
  }

  Future<void> updateProfile({
    String? username,
    String? avatarUrl,
    String? universityId,
    String? icalUrl,
  }) async {
    requireAuth();
    final updates = <String, dynamic>{};
    if (username != null) updates['username'] = username;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (universityId != null) updates['university_id'] = universityId;
    if (icalUrl != null) updates['ical_url'] = icalUrl;
    if (updates.isEmpty) return;

    await client.from('profiles').update(updates).eq('id', currentUserId!);
  }

  Future<List<User>> searchUsers(String query) async {
    requireAuth();
    final response = await client
        .from('profiles')
        .select()
        .ilike('username', '%$query%')
        .neq('id', currentUserId!)
        .limit(20);
    return (response as List).map((json) => User.fromJson(json)).toList();
  }

  // Methods to get other users' profiles
  Future<User> getUserProfile(String userId) async {
    requireAuth();
    final response =
        await client.from('profiles').select().eq('id', userId).single();
    return User.fromJson(response);
  }

  Future<Streak> getUserStreak(String userId) async {
    requireAuth();
    final response =
        await client
            .from('streaks')
            .select()
            .eq('user_id', userId)
            .maybeSingle();

    // If no streak record exists, return a default streak
    if (response == null) {
      return Streak.empty(userId);
    }

    return Streak.fromJson(response);
  }

  Future<StreakEvaluation> evaluateStreak() async {
    requireAuth();
    final result = await client.rpc(
      'evaluate_streak',
      params: {'p_user_id': currentUserId!},
    );
    return StreakEvaluation.fromJson(result as Map<String, dynamic>);
  }

  Future<Points> getUserPoints(String userId) async {
    requireAuth();
    final response =
        await client
            .from('points')
            .select()
            .eq('user_id', userId)
            .maybeSingle();

    // If no points record exists, return default points
    if (response == null) {
      return Points.empty(userId);
    }

    return Points.fromJson(response);
  }
}
