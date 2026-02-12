import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/leaderboard_entry.dart';
import '../../theme/theme_extensions.dart';
import '../../widgets/common/gradient_text.dart';

class LeaderboardEntryTile extends StatelessWidget {
  final LeaderboardEntry entry;

  const LeaderboardEntryTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<TerraThemeExtension>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: entry.isCurrentUser ? 2 : 0,
      child: Container(
        decoration: BoxDecoration(
          gradient:
              entry.isCurrentUser
                  ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.15),
                      theme.colorScheme.primary.withValues(alpha: 0.05),
                    ],
                  )
                  : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow:
              entry.isCurrentUser
                  ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                  : null,
        ),
        child: ListTile(
          onTap:
              entry.isCurrentUser
                  ? null
                  : () {
                    context.push(
                      '/friends/user/${entry.userId}/${Uri.encodeComponent(entry.username)}',
                    );
                  },
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: SizedBox(
            width: 48,
            child: Center(
              child:
                  entry.medal != null
                      ? Text(entry.medal!, style: const TextStyle(fontSize: 24))
                      : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              entry.isCurrentUser
                                  ? theme.colorScheme.primary.withValues(
                                    alpha: 0.2,
                                  )
                                  : (ext?.surfaceTint ??
                                      theme
                                          .colorScheme
                                          .surfaceContainerHighest),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '#${entry.rank}',
                            maxLines: 1,
                            softWrap: false,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color:
                                  entry.isCurrentUser
                                      ? theme.colorScheme.primary
                                      : ext?.textSecondary,
                            ),
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
                  boxShadow:
                      entry.isCurrentUser
                          ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                          : null,
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      entry.avatarUrl != null
                          ? NetworkImage(entry.avatarUrl!)
                          : null,
                  child:
                      entry.avatarUrl == null
                          ? Text(
                            entry.initials,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entry.username,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight:
                        entry.isCurrentUser ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              entry.isCurrentUser
                  ? GradientText(
                    entry.displayValue,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    gradient: ext?.pointsGradient,
                  )
                  : Text(
                    entry.displayValue,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ext?.textSecondary,
                    ),
                  ),
              Text(
                entry.displayUnit,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: ext?.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
