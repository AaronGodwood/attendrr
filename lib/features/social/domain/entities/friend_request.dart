// Friend request entity
class FriendRequest {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String status;
  final DateTime createdAt;

  FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.status,
    required this.createdAt,
  });
}
