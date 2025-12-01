import 'package:equatable/equatable.dart';

enum FriendshipStatus { pending, accepted, rejected }

class Friendship extends Equatable {
  final String id;
  final String userId;
  final String friendId;
  final FriendshipStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Friendship({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Friendship.fromJson(Map<String, dynamic> json) {
    return Friendship(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      friendId: json['friend_id'] as String,
      status: _parseStatus(json['status'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static FriendshipStatus _parseStatus(String? status) {
    switch (status) {
      case 'accepted': return FriendshipStatus.accepted;
      case 'rejected': return FriendshipStatus.rejected;
      default: return FriendshipStatus.pending;
    }
  }

  String get statusString {
    switch (status) {
      case FriendshipStatus.accepted: return 'accepted';
      case FriendshipStatus.rejected: return 'rejected';
      default: return 'pending';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'friend_id': friendId,
    'status': statusString,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  bool get isPending => status == FriendshipStatus.pending;
  bool get isAccepted => status == FriendshipStatus.accepted;

  @override
  List<Object?> get props => [id, userId, friendId, status, createdAt, updatedAt];
}

class FriendWithStats {
  final String id;
  final String username;
  final String? avatarUrl;
  final int currentStreak;
  final int totalPoints;
  final String friendshipId;

  const FriendWithStats({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.currentStreak,
    required this.totalPoints,
    required this.friendshipId,
  });

  String get initials => username.isNotEmpty ? username[0].toUpperCase() : '?';
}

class FriendRequest {
  final String id;
  final String senderId;
  final String senderUsername;
  final String? senderAvatarUrl;
  final DateTime createdAt;

  const FriendRequest({
    required this.id,
    required this.senderId,
    required this.senderUsername,
    this.senderAvatarUrl,
    required this.createdAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] as Map<String, dynamic>? ?? json['profiles'] as Map<String, dynamic>?;
    return FriendRequest(
      id: json['id'] as String,
      senderId: sender?['id'] as String? ?? json['user_id'] as String,
      senderUsername: sender?['username'] as String? ?? 'Unknown',
      senderAvatarUrl: sender?['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String get initials => senderUsername.isNotEmpty ? senderUsername[0].toUpperCase() : '?';

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}