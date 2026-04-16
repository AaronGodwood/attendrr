import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/theme_extensions.dart';

/// Version A: plain numeric attendance and streak stats — no gamification context.
class RawStatsCard extends StatelessWidget {
  final AttendanceStats stats;
  final Streak? streak;

  const RawStatsCard({super.key, required this.stats, this.streak});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<TerraThemeExtension>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Stats',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _StatRow(
              label: 'This Week',
              attended: stats.weeklyAttended,
              total: stats.weeklyTotal,
              percent: stats.weeklyPercent,
              ext: ext,
            ),
            const Divider(height: 20),
            _StatRow(
              label: 'This Month',
              attended: stats.monthlyAttended,
              total: stats.monthlyTotal,
              percent: stats.monthlyPercent,
              ext: ext,
            ),
            const Divider(height: 20),
            _StatRow(
              label: 'Overall',
              attended: stats.overallAttended,
              total: stats.overallTotal,
              percent: stats.overallPercent,
              ext: ext,
            ),
            if (streak != null) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NumberTile(
                    value: '${streak!.currentStreak}',
                    label: 'Current Streak',
                    ext: ext,
                  ),
                  _NumberTile(
                    value: '${streak!.longestStreak}',
                    label: 'Longest Streak',
                    ext: ext,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final int attended;
  final int total;
  final int percent;
  final TerraThemeExtension? ext;

  const _StatRow({
    required this.label,
    required this.attended,
    required this.total,
    required this.percent,
    required this.ext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: ext?.textSecondary,
          ),
        ),
        Text(
          '$attended / $total  ($percent%)',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _NumberTile extends StatelessWidget {
  final String value;
  final String label;
  final TerraThemeExtension? ext;

  const _NumberTile({
    required this.value,
    required this.label,
    required this.ext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: ext?.textSecondary,
          ),
        ),
      ],
    );
  }
}
