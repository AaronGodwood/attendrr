import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/theme_extensions.dart';
import '../common/gradient_text.dart';

class StreakCard extends StatelessWidget {
  final Streak streak;

  const StreakCard({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<TerraThemeExtension>();
    final statusColor = _statusColor(streak.status, ext);

    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              statusColor.withValues(alpha: 0.1),
              statusColor.withValues(alpha: 0.02),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                // Fire icon + streak count
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(scale: value, child: child);
                  },
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: ext?.streakGradient ?? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.7)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.local_fire_department, color: Colors.white, size: 24),
                        Text(
                          '${streak.currentStreak}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Status + details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GradientText(
                            '${streak.currentStreak} Day Streak',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            gradient: ext?.streakGradient,
                          ),
                          if (streak.isPersonalBest) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: ext?.medalGold ?? Colors.amber,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'BEST!',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _StatusBadge(status: streak.status, color: statusColor),
                          if (streak.isAtRisk) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: ext?.warningContainer ?? Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.warning_amber_rounded, size: 12, color: ext?.warning),
                                  const SizedBox(width: 2),
                                  Text(
                                    'At Risk',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: ext?.warning),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatColumn(
                  icon: Icons.emoji_events,
                  iconColor: ext?.medalGold ?? Colors.amber,
                  value: '${streak.longestStreak}',
                  label: 'Longest',
                ),
                _StatColumn(
                  icon: Icons.ac_unit,
                  iconColor: ext?.tierIntermediate ?? Colors.blue,
                  value: '${streak.streakFreezes}',
                  label: 'Freezes',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(StreakStatus status, TerraThemeExtension? ext) {
    switch (status) {
      case StreakStatus.none:
        return ext?.textDisabled ?? Colors.grey;
      case StreakStatus.building:
        return ext?.success ?? Colors.green;
      case StreakStatus.strong:
        return ext?.tierIntermediate ?? Colors.blue;
      case StreakStatus.impressive:
        return ext?.tierExpert ?? Colors.purple;
      case StreakStatus.legendary:
        return ext?.tierLegendary ?? Colors.amber.shade700;
      case StreakStatus.personalBest:
        return ext?.tierLegendary ?? Colors.amber.shade700;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final StreakStatus status;
  final Color color;

  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    if (status == StreakStatus.none) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  String _statusLabel(StreakStatus status) {
    switch (status) {
      case StreakStatus.none:
        return '';
      case StreakStatus.building:
        return 'Building';
      case StreakStatus.strong:
        return 'Strong';
      case StreakStatus.impressive:
        return 'Impressive';
      case StreakStatus.legendary:
        return 'Legendary';
      case StreakStatus.personalBest:
        return 'Personal Best';
    }
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatColumn({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<TerraThemeExtension>();

    return Column(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: ext?.textSecondary)),
      ],
    );
  }
}
