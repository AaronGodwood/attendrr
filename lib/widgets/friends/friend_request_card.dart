import 'package:flutter/material.dart';
import '../../models/friendship.dart';
import '../../theme/theme_extensions.dart';

class FriendRequestCard extends StatelessWidget {
  final FriendRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const FriendRequestCard({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<TerraThemeExtension>();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: request.senderAvatarUrl != null ? NetworkImage(request.senderAvatarUrl!) : null,
              child: request.senderAvatarUrl == null ? Text(request.initials) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.senderUsername,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    request.timeAgo,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ext?.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.check_circle, color: ext?.success),
              onPressed: onAccept,
            ),
            IconButton(
              icon: Icon(Icons.cancel, color: ext?.danger),
              onPressed: onReject,
            ),
          ],
        ),
      ),
    );
  }
}
