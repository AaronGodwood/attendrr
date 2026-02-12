import 'package:equatable/equatable.dart';

class Purchase extends Equatable {
  final String id;
  final String userId;
  final String itemType;
  final int itemCost;
  final DateTime createdAt;

  const Purchase({
    required this.id,
    required this.userId,
    required this.itemType,
    required this.itemCost,
    required this.createdAt,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      itemType: json['item_type'] as String,
      itemCost: json['item_cost'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, userId, itemType, itemCost, createdAt];
}
