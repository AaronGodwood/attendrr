import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/theme_extensions.dart';
import '../common/gradient_text.dart';

class TierProgressCard extends StatelessWidget {
  final Points points;

  const TierProgressCard({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<TerraThemeExtension>();
    final tierColor = _tierColor(points.tier, ext);
    final progress = _tierProgress(points);

    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              tierColor.withValues(alpha: 0.1),
              tierColor.withValues(alpha: 0.02),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [tierColor, tierColor.withValues(alpha: 0.7)]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_tierIcon(points.tier), color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        points.tierName,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                GradientText(
                  '${points.totalPoints} XP',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  gradient: ext?.pointsGradient,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 10,
                    backgroundColor: tierColor.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(tierColor),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              points.tier == PointsTier.legendary
                  ? 'Max tier reached!'
                  : '${points.pointsToNextTier} XP to next tier',
              style: theme.textTheme.bodySmall?.copyWith(
                color: ext?.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _PointsChip(label: 'This week', value: points.weeklyPoints, color: tierColor),
                const SizedBox(width: 8),
                _PointsChip(label: 'This month', value: points.monthlyPoints, color: tierColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _tierProgress(Points p) {
    switch (p.tier) {
      case PointsTier.newcomer:
        return p.totalPoints / 100;
      case PointsTier.beginner:
        return (p.totalPoints - 100) / 400;
      case PointsTier.intermediate:
        return (p.totalPoints - 500) / 1500;
      case PointsTier.expert:
        return (p.totalPoints - 2000) / 3000;
      case PointsTier.master:
        return (p.totalPoints - 5000) / 5000;
      case PointsTier.legendary:
        return 1.0;
    }
  }

  Color _tierColor(PointsTier tier, TerraThemeExtension? ext) {
    switch (tier) {
      case PointsTier.newcomer:
        return ext?.tierNewcomer ?? Colors.grey;
      case PointsTier.beginner:
        return ext?.tierBeginner ?? Colors.green;
      case PointsTier.intermediate:
        return ext?.tierIntermediate ?? Colors.blue;
      case PointsTier.expert:
        return ext?.tierExpert ?? Colors.purple;
      case PointsTier.master:
        return ext?.tierMaster ?? Colors.deepOrange;
      case PointsTier.legendary:
        return ext?.tierLegendary ?? Colors.amber.shade700;
    }
  }

  IconData _tierIcon(PointsTier tier) {
    switch (tier) {
      case PointsTier.newcomer:
        return Icons.emoji_events_outlined;
      case PointsTier.beginner:
        return Icons.trending_up;
      case PointsTier.intermediate:
        return Icons.bolt;
      case PointsTier.expert:
        return Icons.diamond_outlined;
      case PointsTier.master:
        return Icons.workspace_premium;
      case PointsTier.legendary:
        return Icons.auto_awesome;
    }
  }
}

class _PointsChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _PointsChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$value $label',
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
