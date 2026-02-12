import 'package:equatable/equatable.dart';

class LeaderboardEntry extends Equatable {
  final int rank;
  final String userId;
  final String username;
  final String? avatarUrl;
  final int totalPoints;
  final int weeklyPoints;
  final int currentStreak;
  final double attendanceRate;
  final bool isCurrentUser;
  final String displayValue;
  final String displayUnit;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.totalPoints,
    this.weeklyPoints = 0,
    this.currentStreak = 0,
    this.attendanceRate = 0,
    this.isCurrentUser = false,
    this.displayValue = '0',
    this.displayUnit = 'pts',
  });

  factory LeaderboardEntry.fromJson(
    Map<String, dynamic> json,
    int rank,
    String? currentUserId,
  ) {
    final profile = json['profiles'] as Map<String, dynamic>? ?? json;
    final streaks = json['streaks'] as Map<String, dynamic>?;

    final userId = profile['id'] as String? ?? json['user_id'] as String;

    return LeaderboardEntry(
      rank: rank,
      userId: userId,
      username: profile['username'] as String? ?? 'Unknown',
      avatarUrl: profile['avatar_url'] as String?,
      totalPoints: json['total_points'] as int? ?? 0,
      weeklyPoints: json['weekly_points'] as int? ?? 0,
      currentStreak: streaks?['current_streak'] as int? ??
          json['current_streak'] as int? ??
          0,
      attendanceRate: (json['attendance_rate'] as num?)?.toDouble() ?? 0,
      isCurrentUser: userId == currentUserId,
      displayValue: '${json['total_points'] ?? 0}',
      displayUnit: 'pts',
    );
  }

  LeaderboardEntry copyWith({
    int? rank,
    String? userId,
    String? username,
    String? avatarUrl,
    int? totalPoints,
    int? weeklyPoints,
    int? currentStreak,
    double? attendanceRate,
    bool? isCurrentUser,
    String? displayValue,
    String? displayUnit,
  }) {
    return LeaderboardEntry(
      rank: rank ?? this.rank,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalPoints: totalPoints ?? this.totalPoints,
      weeklyPoints: weeklyPoints ?? this.weeklyPoints,
      currentStreak: currentStreak ?? this.currentStreak,
      attendanceRate: attendanceRate ?? this.attendanceRate,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      displayValue: displayValue ?? this.displayValue,
      displayUnit: displayUnit ?? this.displayUnit,
    );
  }

  String get initials => username.isNotEmpty ? username[0].toUpperCase() : '?';
  bool get isPodium => rank <= 3;

  String? get medal {
    switch (rank) {
      case 1:
        return '\u{1F947}';
      case 2:
        return '\u{1F948}';
      case 3:
        return '\u{1F949}';
      default:
        return null;
    }
  }

  @override
  List<Object?> get props => [
    rank,
    userId,
    username,
    avatarUrl,
    totalPoints,
    weeklyPoints,
    currentStreak,
    attendanceRate,
    isCurrentUser,
    displayValue,
    displayUnit,
  ];
}
