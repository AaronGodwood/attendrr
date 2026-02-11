import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/friendship.dart';
import '../../theme/theme_extensions.dart';

class FriendCard extends StatelessWidget {
  final FriendWithStats friend;
  final VoidCallback onRemove;

  const FriendCard({super.key, required this.friend, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<TerraThemeExtension>();

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
        title: Text(friend.username, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Row(
          children: [
            Icon(Icons.local_fire_department, size: 14, color: ext?.warning),
            Text(' ${friend.currentStreak}  '),
            Icon(Icons.star, size: 14, color: ext?.medalGold),
            Text(' ${friend.totalPoints}'),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: onRemove,
              child: Row(
                children: [
                  Icon(Icons.person_remove, color: ext?.danger, size: 20),
                  const SizedBox(width: 8),
                  const Text('Remove'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
