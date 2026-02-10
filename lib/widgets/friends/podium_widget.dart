import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../models/leaderboard_entry.dart';

class PodiumWidget extends StatelessWidget {
  final List<LeaderboardEntry> topThree;

  const PodiumWidget({super.key, required this.topThree});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          colors: isDark
              ? [
                  const Color(0xFF1A1A2E),
                  const Color(0xFF16213E),
                ]
              : [
                  const Color(0xFFF5F7FA),
                  const Color(0xFFE8EAF6),
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
                    color: const Color(0xFFC0C0C0), // Silver
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
                    color: const Color(0xFFFFD700), // Gold
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
                    color: const Color(0xFFCD7F32), // Bronze
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  '👑',
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
                              color: Colors.white,
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
          style: TextStyle(
            fontSize: rank == 1 ? 16 : 14,
            fontWeight: rank == 1 ? FontWeight.bold : FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),

        // Points with gradient
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: rank == 1
                ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                : rank == 2
                    ? [const Color(0xFFC0C0C0), const Color(0xFFAAAAAA)]
                    : [const Color(0xFFCD7F32), const Color(0xFFB87333)],
          ).createShader(bounds),
          child: Text(
            '${entry.totalPoints}',
            style: TextStyle(
              fontSize: rank == 1 ? 24 : 20,
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
                  colors: rank == 1
                      ? [
                          const Color(0xFFFFD700).withValues(alpha: 0.8),
                          const Color(0xFFFFA500).withValues(alpha: 0.6),
                        ]
                      : rank == 2
                          ? [
                              const Color(0xFFC0C0C0).withValues(alpha: 0.7),
                              const Color(0xFFAAAAAA).withValues(alpha: 0.5),
                            ]
                          : [
                              const Color(0xFFCD7F32).withValues(alpha: 0.7),
                              const Color(0xFFB87333).withValues(alpha: 0.5),
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
