import 'package:flutter/material.dart';
import '../../models/models.dart';

class StatsCard extends StatelessWidget {
  final Streak streak;
  final Points points;

  const StatsCard({super.key, required this.streak, required this.points});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              icon: Icons.local_fire_department,
              iconColor: Colors.orange,
              value: '${streak.currentStreak}',
              label: 'Day Streak',
            ),
            _StatItem(
              icon: Icons.star,
              iconColor: Colors.amber,
              value: '${points.totalPoints}',
              label: 'Points',
            ),
            _StatItem(
              icon: Icons.ac_unit,
              iconColor: Colors.blue,
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
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}