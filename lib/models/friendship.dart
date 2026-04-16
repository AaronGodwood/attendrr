import 'package:equatable/equatable.dart';

class Friendship extends Equatable {
  final String id;
  final String userId;
  final String friendId;
  final DateTime createdAt;

  const Friendship({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.createdAt,
  });

  factory Friendship.fromJson(Map<String, dynamic> json) {
    return Friendship(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      friendId: json['friend_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, userId, friendId];
}
