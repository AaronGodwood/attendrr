import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../models/leaderboard_entry.dart';
import '../../theme/theme_extensions.dart';
import '../../widgets/common/gradient_text.dart';

class PodiumWidget extends StatelessWidget {
  final List<LeaderboardEntry> topThree;

  const PodiumWidget({super.key, required this.topThree});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<TerraThemeExtension>();

    // Ensure we have exactly 3 entries (fill with nulls if needed)
    final first = topThree.isNotEmpty ? topThree[0] : null;
    final second = topThree.length > 1 ? topThree[1] : null;
    final third = topThree.length > 2 ? topThree[2] : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            (ext?.surfaceTint ?? theme.colorScheme.surfaceContainerHighest),
          ],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Winners row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 2nd place
              if (second != null)
                Expanded(
                  child: _buildPodiumPlayer(
                    context,
                    second,
                    rank: 2,
                    height: 140,
                    color: ext?.medalSilver ?? const Color(0xFFB8A898),
                  ),
                ),
              const SizedBox(width: 8),
              // 1st place
              if (first != null)
                Expanded(
                  child: _buildPodiumPlayer(
                    context,
                    first,
                    rank: 1,
                    height: 180,
                    color: ext?.medalGold ?? const Color(0xFFE8D5B7),
                  ),
                ),
              const SizedBox(width: 8),
              // 3rd place
              if (third != null)
                Expanded(
                  child: _buildPodiumPlayer(
                    context,
                    third,
                    rank: 3,
                    height: 120,
                    color: ext?.medalBronze ?? const Color(0xFFC67B4E),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPlayer(
    BuildContext context,
    LeaderboardEntry entry, {
    required int rank,
    required double height,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final ext = theme.extension<TerraThemeExtension>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Crown for 1st place
        if (rank == 1)
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1500),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -10 * math.sin(value * math.pi)),
                child: const Text(
                  '\u{1F451}',
                  style: TextStyle(fontSize: 32),
                ),
              );
            },
          ),
        const SizedBox(height: 8),

        // Avatar with glow
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: GestureDetector(
                onTap: entry.isCurrentUser
                    ? null
                    : () {
                        context.push('/friends/user/${entry.userId}/${Uri.encodeComponent(entry.username)}');
                      },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: rank == 1 ? 5 : 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: rank == 1 ? 40 : 32,
                    backgroundColor: color,
                    backgroundImage: entry.avatarUrl != null
                        ? NetworkImage(entry.avatarUrl!)
                        : null,
                    child: entry.avatarUrl == null
                        ? Text(
                            entry.initials,
                            style: TextStyle(
                              fontSize: rank == 1 ? 24 : 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),

        // Username
        Text(
          entry.username,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: rank == 1 ? 16 : 14,
            fontWeight: rank == 1 ? FontWeight.bold : FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),

        // Value with gradient
        GradientText(
          entry.displayValue,
          style: TextStyle(
            fontSize: rank == 1 ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
          gradient: ext?.pointsGradient,
        ),
        Text(
          entry.displayUnit,
          style: theme.textTheme.labelSmall?.copyWith(
            color: ext?.textSecondary,
          ),
        ),
        const SizedBox(height: 12),

        // Podium base
        TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 600 + (rank * 100)),
          tween: Tween(begin: 0.0, end: height),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Container(
              height: value,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0.8),
                    color.withValues(alpha: 0.4),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  entry.medal ?? '',
                  style: TextStyle(
                    fontSize: rank == 1 ? 48 : 36,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
