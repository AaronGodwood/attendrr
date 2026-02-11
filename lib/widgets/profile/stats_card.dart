import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/theme_extensions.dart';

class StatsCard extends StatelessWidget {
  final Streak streak;
  final Points points;

  const StatsCard({super.key, required this.streak, required this.points});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<TerraThemeExtension>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              icon: Icons.local_fire_department,
              iconColor: ext?.warning ?? Colors.orange,
              value: '${streak.currentStreak}',
              label: 'Day Streak',
            ),
            _StatItem(
              icon: Icons.star,
              iconColor: ext?.medalGold ?? Colors.amber,
              value: '${points.totalPoints}',
              label: 'Points',
            ),
            _StatItem(
              icon: Icons.ac_unit,
              iconColor: ext?.tierIntermediate ?? Colors.blue,
              value: '${streak.streakFreezes}',
              label: 'Freezes',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatItem({
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
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: ext?.textSecondary)),
      ],
    );
  }
}
