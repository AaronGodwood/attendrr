class StreakEvaluation {
  final int currentStreak;
  final int longestStreak;
  final int streakFreezes;
  final DateTime? lastAttendanceDate;
  final int freezesConsumed;
  final bool streakBroken;

  const StreakEvaluation({
    required this.currentStreak,
    required this.longestStreak,
    required this.streakFreezes,
    this.lastAttendanceDate,
    required this.freezesConsumed,
    required this.streakBroken,
  });

  factory StreakEvaluation.fromJson(Map<String, dynamic> json) {
    return StreakEvaluation(
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      streakFreezes: json['streak_freezes'] as int? ?? 0,
      lastAttendanceDate: json['last_attendance_date'] != null
          ? DateTime.parse(json['last_attendance_date'] as String)
          : null,
      freezesConsumed: json['freezes_consumed'] as int? ?? 0,
      streakBroken: json['streak_broken'] as bool? ?? false,
    );
  }

  bool get hadChanges => freezesConsumed > 0 || streakBroken;
}
