import 'package:flutter/material.dart';
import '../../models/leaderboard_entry.dart';

class PodiumWidget extends StatelessWidget {
  final List<LeaderboardEntry> topThree;

  const PodiumWidget({super.key, required this.topThree});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale =
            constraints.hasBoundedHeight
                ? (constraints.maxHeight / 250).clamp(0.75, 1.0)
                : 1.0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (topThree.length > 1)
              _buildPodiumStep(
                context,
                topThree[1],
                2,
                150,
                scale,
              ), // 2nd place
            if (topThree.isNotEmpty)
              _buildPodiumStep(
                context,
                topThree[0],
                1,
                200,
                scale,
              ), // 1st place
            if (topThree.length > 2)
              _buildPodiumStep(
                context,
                topThree[2],
                3,
                100,
                scale,
              ), // 3rd place
          ],
        );
      },
    );
  }

  Widget _buildPodiumStep(
    BuildContext context,
    LeaderboardEntry entry,
    int rank,
    double height,
    double scale,
  ) {
    final avatarRadius = 30 * scale;
    final podiumHeight = height * scale;
    final textScale = scale.clamp(0.8, 1.0);
    final nameWidth = 92.0 * scale;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '#$rank',
          style: TextStyle(
            fontSize: 24 * textScale,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8 * scale),
        CircleAvatar(
          radius: avatarRadius,
          child: Text(
            entry.initials,
            style: TextStyle(fontSize: 16 * textScale),
          ),
        ),
        SizedBox(height: 8 * scale),
        SizedBox(
          width: nameWidth,
          child: Text(
            entry.username,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14 * textScale,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        Text(
          '${entry.totalPoints} pts',
          style: TextStyle(fontSize: 12 * textScale),
        ),
        SizedBox(height: 8 * scale),
        Container(
          height: podiumHeight,
          width: 80 * scale,
          decoration: BoxDecoration(
            color: _getPodiumColor(rank),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Color _getPodiumColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[400]!;
      default:
        return Colors.transparent;
    }
  }
}
