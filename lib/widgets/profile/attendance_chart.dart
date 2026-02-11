import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/attendance.dart';
import '../../theme/theme_extensions.dart';

class AttendanceChart extends StatelessWidget {
  final List<DailyAttendance> data;

  const AttendanceChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<TerraThemeExtension>();
    final primaryColor = theme.colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last 30 Days',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _summaryText(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: ext?.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            // Line chart — attendance trend
            SizedBox(
              height: 140,
              child: _buildLineChart(context, primaryColor, ext),
            ),
            const SizedBox(height: 24),
            Text(
              'Daily Breakdown',
              style: theme.textTheme.labelLarge?.copyWith(
                color: ext?.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            // Bar chart — daily counts
            SizedBox(
              height: 60,
              child: _buildBarChart(context, primaryColor, ext),
            ),
          ],
        ),
      ),
    );
  }

  String _summaryText() {
    if (data.isEmpty) return 'No data';
    final totalAttended = data.where((d) => d.count > 0).length;
    return '$totalAttended of ${data.length} days attended';
  }

  Widget _buildLineChart(BuildContext context, Color primaryColor, TerraThemeExtension? ext) {
    if (data.isEmpty) {
      return const Center(child: Text('No data yet'));
    }

    // Build cumulative attendance rate spots
    final spots = <FlSpot>[];
    int runningAttended = 0;
    for (int i = 0; i < data.length; i++) {
      if (data[i].count > 0) runningAttended++;
      final rate = (i + 1) > 0 ? (runningAttended / (i + 1)) * 100 : 0.0;
      spots.add(FlSpot(i.toDouble(), rate));
    }

    final gridColor = Theme.of(context).colorScheme.outline;
    final labelColor = ext?.textSecondary;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) => FlLine(
            color: gridColor.withValues(alpha: 0.15),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (data.length / 4).ceilToDouble(),
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    DateFormat('d/M').format(data[idx].date),
                    style: TextStyle(fontSize: 9, color: labelColor),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 50,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: TextStyle(fontSize: 9, color: labelColor),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: primaryColor,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  primaryColor.withValues(alpha: 0.25),
                  primaryColor.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) {
              return spots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toInt()}%',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context, Color primaryColor, TerraThemeExtension? ext) {
    final maxY = data.isEmpty
        ? 1.0
        : data.map((d) => d.count.toDouble()).reduce((a, b) => a > b ? a : b) + 1;
    final emptyBarColor = ext?.surfaceTint ?? Theme.of(context).colorScheme.outline.withValues(alpha: 0.3);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(enabled: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.count.toDouble(),
                color: entry.value.count > 0 ? primaryColor : emptyBarColor,
                width: 5,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
