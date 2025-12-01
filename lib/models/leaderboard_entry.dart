import 'package:equatable/equatable.dart';

class LeaderboardEntry extends Equatable {
  final int rank;
  final String userId;
  final String username;
  final String? avatarUrl;
  final int totalPoints;
  final int weeklyPoints;
  final int currentStreak;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.totalPoints,
    this.weeklyPoints = 0,
    this.currentStreak = 0,
    this.isCurrentUser = false,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json, int rank, String? currentUserId) {
    final profile = json['profiles'] as Map<String, dynamic>? ?? json;
    final streaks = json['streaks'] as Map<String, dynamic>?;

    return LeaderboardEntry(
      rank: rank,
      userId: profile['id'] as String? ?? json['user_id'] as String,
      username: profile['username'] as String? ?? 'Unknown',
      avatarUrl: profile['avatar_url'] as String?,
      totalPoints: json['total_points'] as int? ?? 0,
      weeklyPoints: json['weekly_points'] as int? ?? 0,
      currentStreak: streaks?['current_streak'] as int? ?? 0,
      isCurrentUser: (profile['id'] ?? json['user_id']) == currentUserId,
    );
  }

  String get initials => username.isNotEmpty ? username[0].toUpperCase() : '?';
  bool get isPodium => rank <= 3;

  String? get medal {
    switch (rank) {
      case 1: return '🥇';
      case 2: return '🥈';
      case 3: return '🥉';
      default: return null;
    }
  }

  @override
  List<Object?> get props => [rank, userId, username, avatarUrl, totalPoints, weeklyPoints, currentStreak, isCurrentUser];
}