import 'package:flutter/material.dart';
import '../../models/lecture.dart';

class LectureCard extends StatelessWidget {
  final LectureWithAttendance lectureWithAttendance;

  const LectureCard({super.key, required this.lectureWithAttendance});

  @override
  Widget build(BuildContext context) {
    final lecture = lectureWithAttendance.lecture;
    final status = lectureWithAttendance.status;

    return Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(status, lecture.color),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: lecture.color, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (status == LectureStatus.attended)
                const Icon(Icons.check_circle, size: 12, color: Colors.green)
              else if (status == LectureStatus.missed)
                const Icon(Icons.cancel, size: 12, color: Colors.red),
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
            style: TextStyle(fontSize: 9, color: Colors.grey[600]),
          ),
          if (lecture.location.isNotEmpty)
            Text(
              lecture.location,
              style: TextStyle(fontSize: 8, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Color _getBackgroundColor(LectureStatus status, Color baseColor) {
    switch (status) {
      case LectureStatus.attended:
        return Colors.green.withAlpha(38);
      case LectureStatus.missed:
        return Colors.red.withAlpha(38);
      case LectureStatus.inProgress:
        return baseColor.withAlpha(77);
      case LectureStatus.upcoming:
        return baseColor.withAlpha(26);
    }
  }
}
