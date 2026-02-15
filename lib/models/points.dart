import 'package:equatable/equatable.dart';

enum PointsTier { newcomer, beginner, intermediate, expert, master, legendary }

class Points extends Equatable {
  final String id;
  final String userId;
  final int totalPoints;
  final int weeklyPoints;
  final int monthlyPoints;
  final double weeklyBoostMultiplier;
  final DateTime? weeklyBoostExpiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Points({
    required this.id,
    required this.userId,
    required this.totalPoints,
    required this.weeklyPoints,
    required this.monthlyPoints,
    required this.weeklyBoostMultiplier,
    required this.weeklyBoostExpiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Points.fromJson(Map<String, dynamic> json) {
    return Points(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      totalPoints: json['total_points'] as int? ?? 0,
      weeklyPoints: json['weekly_points'] as int? ?? 0,
      monthlyPoints: json['monthly_points'] as int? ?? 0,
      weeklyBoostMultiplier:
          (json['weekly_boost_multiplier'] as num?)?.toDouble() ?? 1.0,
      weeklyBoostExpiresAt:
          json['weekly_boost_expires_at'] != null
              ? DateTime.parse(json['weekly_boost_expires_at'] as String)
              : null,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : DateTime.now(),
    );
  }

  factory Points.empty(String userId) => Points(
    id: '',
    userId: userId,
    totalPoints: 0,
    weeklyPoints: 0,
    monthlyPoints: 0,
    weeklyBoostMultiplier: 1.0,
    weeklyBoostExpiresAt: null,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'total_points': totalPoints,
    'weekly_points': weeklyPoints,
    'monthly_points': monthlyPoints,
    'weekly_boost_multiplier': weeklyBoostMultiplier,
    'weekly_boost_expires_at': weeklyBoostExpiresAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  Points copyWith({
    String? id,
    String? userId,
    int? totalPoints,
    int? weeklyPoints,
    int? monthlyPoints,
    double? weeklyBoostMultiplier,
    DateTime? weeklyBoostExpiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Points(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      totalPoints: totalPoints ?? this.totalPoints,
      weeklyPoints: weeklyPoints ?? this.weeklyPoints,
      monthlyPoints: monthlyPoints ?? this.monthlyPoints,
      weeklyBoostMultiplier:
          weeklyBoostMultiplier ?? this.weeklyBoostMultiplier,
      weeklyBoostExpiresAt: weeklyBoostExpiresAt ?? this.weeklyBoostExpiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get weeklyBoostActive {
    if (weeklyBoostExpiresAt == null) return false;
    return weeklyBoostMultiplier > 1.0 &&
        weeklyBoostExpiresAt!.isAfter(DateTime.now());
  }

  PointsTier get tier {
    if (totalPoints >= 10000) return PointsTier.legendary;
    if (totalPoints >= 5000) return PointsTier.master;
    if (totalPoints >= 2000) return PointsTier.expert;
    if (totalPoints >= 500) return PointsTier.intermediate;
    if (totalPoints >= 100) return PointsTier.beginner;
    return PointsTier.newcomer;
  }

  String get tierName {
    switch (tier) {
      case PointsTier.legendary:
        return 'Legendary';
      case PointsTier.master:
        return 'Master';
      case PointsTier.expert:
        return 'Expert';
      case PointsTier.intermediate:
        return 'Intermediate';
      case PointsTier.beginner:
        return 'Beginner';
      case PointsTier.newcomer:
        return 'Newcomer';
    }
  }

  int get pointsToNextTier {
    switch (tier) {
      case PointsTier.newcomer:
        return 100 - totalPoints;
      case PointsTier.beginner:
        return 500 - totalPoints;
      case PointsTier.intermediate:
        return 2000 - totalPoints;
      case PointsTier.expert:
        return 5000 - totalPoints;
      case PointsTier.master:
        return 10000 - totalPoints;
      case PointsTier.legendary:
        return 0;
    }
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    totalPoints,
    weeklyPoints,
    monthlyPoints,
    weeklyBoostMultiplier,
    weeklyBoostExpiresAt,
    createdAt,
    updatedAt,
  ];
}
