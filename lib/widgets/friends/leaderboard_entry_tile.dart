import 'package:flutter/material.dart';
import '../../models/leaderboard_entry.dart';

class LeaderboardEntryTile extends StatelessWidget {
  final LeaderboardEntry entry;

  const LeaderboardEntryTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: entry.isCurrentUser ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      child: ListTile(
        leading: SizedBox(
          width: 40,
          child: Center(
            child: entry.medal != null
                ? Text(entry.medal!, style: const TextStyle(fontSize: 24))
                : Text(
              '#${entry.rank}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: entry.isCurrentUser ? Theme.of(context).primaryColor : Colors.grey,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: entry.avatarUrl != null ? NetworkImage(entry.avatarUrl!) : null,
              child: entry.avatarUrl == null ? Text(entry.initials, style: const TextStyle(fontSize: 12)) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry.username,
                style: TextStyle(
                  fontWeight: entry.isCurrentUser ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${entry.totalPoints}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('points', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}