import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/leaderboard_entry.dart';

class LeaderboardEntryTile extends StatelessWidget {
  final LeaderboardEntry entry;

  const LeaderboardEntryTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: entry.isCurrentUser ? 4 : 1,
      child: Container(
        decoration: BoxDecoration(
          gradient: entry.isCurrentUser
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Theme.of(context).primaryColor.withValues(alpha: 0.15),
                          Theme.of(context).primaryColor.withValues(alpha: 0.05),
                        ]
                      : [
                          Theme.of(context).primaryColor.withValues(alpha: 0.08),
                          Theme.of(context).primaryColor.withValues(alpha: 0.02),
                        ],
                )
              : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: entry.isCurrentUser
              ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: ListTile(
          onTap: entry.isCurrentUser
              ? null
              : () {
                  context.push('/friends/user/${entry.userId}/${Uri.encodeComponent(entry.username)}');
                },
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: SizedBox(
            width: 40,
            child: Center(
              child: entry.medal != null
                  ? Text(entry.medal!, style: const TextStyle(fontSize: 24))
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: entry.isCurrentUser
                              ? [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context).primaryColor.withValues(alpha: 0.7),
                                ]
                              : [
                                  Colors.grey.shade300,
                                  Colors.grey.shade400,
                                ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#${entry.rank}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: entry.isCurrentUser ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                    ),
            ),
          ),
          title: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: entry.isCurrentUser
                      ? [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: entry.avatarUrl != null ? NetworkImage(entry.avatarUrl!) : null,
                  child: entry.avatarUrl == null
                      ? Text(entry.initials, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entry.username,
                  style: TextStyle(
                    fontWeight: entry.isCurrentUser ? FontWeight.bold : FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: entry.isCurrentUser
                      ? [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withValues(alpha: 0.7),
                        ]
                      : [Colors.grey.shade700, Colors.grey.shade600],
                ).createShader(bounds),
                child: Text(
                  '${entry.totalPoints}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                'points',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}