import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/friendship.dart';

class FriendCard extends StatelessWidget {
  final FriendWithStats friend;
  final VoidCallback onRemove;

  const FriendCard({super.key, required this.friend, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () {
          context.push('/friends/user/${friend.id}/${Uri.encodeComponent(friend.username)}');
        },
        leading: CircleAvatar(
          backgroundImage: friend.avatarUrl != null ? NetworkImage(friend.avatarUrl!) : null,
          child: friend.avatarUrl == null ? Text(friend.initials) : null,
        ),
        title: Text(friend.username, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(
          children: [
            const Icon(Icons.local_fire_department, size: 14, color: Colors.orange),
            Text(' ${friend.currentStreak}  '),
            const Icon(Icons.star, size: 14, color: Colors.amber),
            Text(' ${friend.totalPoints}'),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: onRemove,
              child: const Row(
                children: [
                  Icon(Icons.person_remove, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Remove'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}