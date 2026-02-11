import 'package:flutter/material.dart';
import '../../models/lecture.dart';
import '../../theme/theme_extensions.dart';

class LectureCard extends StatelessWidget {
  final LectureWithAttendance lectureWithAttendance;

  const LectureCard({super.key, required this.lectureWithAttendance});

  @override
  Widget build(BuildContext context) {
    final lecture = lectureWithAttendance.lecture;
    final status = lectureWithAttendance.status;
    final theme = Theme.of(context);
    final ext = theme.extension<TerraThemeExtension>();

    return Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(status, lecture.color, ext),
        borderRadius: BorderRadius.circular(4),
        border: Border(
          left: BorderSide(color: lecture.color, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (status == LectureStatus.attended)
                Icon(Icons.check_circle, size: 12, color: ext?.success)
              else if (status == LectureStatus.missed)
                Icon(Icons.cancel, size: 12, color: ext?.danger),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  lecture.moduleCode,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            lecture.timeRange,
            style: TextStyle(fontSize: 9, color: ext?.textSecondary),
          ),
          if (lecture.location.isNotEmpty)
            Text(
              lecture.location,
              style: TextStyle(fontSize: 8, color: ext?.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Color _getBackgroundColor(LectureStatus status, Color baseColor, TerraThemeExtension? ext) {
    switch (status) {
      case LectureStatus.attended:
        return (ext?.success ?? Colors.green).withAlpha(38);
      case LectureStatus.missed:
        return (ext?.danger ?? Colors.red).withAlpha(38);
      case LectureStatus.inProgress:
        return baseColor.withAlpha(77);
      case LectureStatus.upcoming:
        return baseColor.withAlpha(26);
    }
  }
}
