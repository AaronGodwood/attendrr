import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum ShopItemType {
  streakFreeze,
  weeklyPointsBoost;

  String get label {
    switch (this) {
      case streakFreeze:
        return 'Streak Freeze';
      case weeklyPointsBoost:
        return 'Weekly Points Boost';
    }
  }

  String get description {
    switch (this) {
      case streakFreeze:
        return 'Protect your streak when you miss a day. '
            'One freeze is consumed automatically when you would lose your streak.';
      case weeklyPointsBoost:
        return 'Boosts points earned by 10% for the rest of the week.';
    }
  }

  IconData get icon {
    switch (this) {
      case streakFreeze:
        return Icons.ac_unit;
      case weeklyPointsBoost:
        return Icons.trending_up;
    }
  }
}

class ShopItem extends Equatable {
  final ShopItemType type;
  final int cost;
  final int? userQuantity;

  const ShopItem({required this.type, required this.cost, this.userQuantity});

  String get name => type.label;
  String get description => type.description;
  IconData get icon => type.icon;

  ShopItem copyWith({int? userQuantity}) {
    return ShopItem(
      type: type,
      cost: cost,
      userQuantity: userQuantity ?? this.userQuantity,
    );
  }

  @override
  List<Object?> get props => [type, cost, userQuantity];
}
