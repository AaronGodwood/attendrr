import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/theme_extensions.dart';

class AttendanceRingCard extends StatelessWidget {
  final AttendanceStats stats;

  const AttendanceRingCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _AttendanceRing(
                  label: 'Weekly',
                  percent: stats.weeklyPercent,
                  rate: stats.weeklyRate,
                  attended: stats.weeklyAttended,
                  total: stats.weeklyTotal,
                ),
                _AttendanceRing(
                  label: 'Monthly',
                  percent: stats.monthlyPercent,
                  rate: stats.monthlyRate,
                  attended: stats.monthlyAttended,
                  total: stats.monthlyTotal,
                ),
                _AttendanceRing(
                  label: 'Overall',
                  percent: stats.overallPercent,
                  rate: stats.overallRate,
                  attended: stats.overallAttended,
                  total: stats.overallTotal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceRing extends StatelessWidget {
  final String label;
  final int percent;
  final double rate;
  final int attended;
  final int total;

  const _AttendanceRing({
    required this.label,
    required this.percent,
    required this.rate,
    required this.attended,
    required this.total,
  });

  Color _ringColor(TerraThemeExtension? ext) {
    if (percent >= 80) return ext?.success ?? Colors.green;
    if (percent >= 60) return ext?.warning ?? Colors.orange;
    return ext?.danger ?? Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<TerraThemeExtension>();
    final color = _ringColor(ext);

    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: rate.clamp(0.0, 1.0)),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) {
            return SizedBox(
              width: 80,
              height: 80,
              child: CustomPaint(
                painter: _RingPainter(
                  progress: value,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.15),
                ),
                child: Center(
                  child: Text(
                    '$percent%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '$attended/$total',
          style: theme.textTheme.bodySmall?.copyWith(
            color: ext?.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 8) / 2;
    const strokeWidth = 8.0;

    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
