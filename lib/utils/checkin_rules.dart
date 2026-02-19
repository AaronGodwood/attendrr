import '../models/lecture.dart';

const int defaultMaxCheckInPoints = 10;
const Duration defaultEarlyCheckInWindow = Duration(minutes: 10);

bool canCheckInNow(
  DateTime now,
  Lecture? lecture, {
  double? distanceMeters,
  double maxDistanceMeters = 100,
  Duration earlyWindow = defaultEarlyCheckInWindow,
}) {
  if (lecture == null) return false;
  if (!isWithinCheckInWindow(now, lecture, earlyWindow: earlyWindow)) {
    return false;
  }

  if (!lecture.hasValidCoordinates) return true;
  if (distanceMeters == null) return false;
  if (distanceMeters < 0) return false;
  return distanceMeters <= maxDistanceMeters;
}

bool isWithinCheckInWindow(
  DateTime now,
  Lecture? lecture, {
  Duration earlyWindow = defaultEarlyCheckInWindow,
}) {
  if (lecture == null) return false;
  final startWindow = lecture.startTime.subtract(earlyWindow);
  return (now.isAfter(startWindow) || now.isAtSameMomentAs(startWindow)) &&
      (now.isBefore(lecture.endTime) || now.isAtSameMomentAs(lecture.endTime));
}

int calculateCheckInPoints(
  DateTime now,
  Lecture lecture, {
  int maxPoints = defaultMaxCheckInPoints,
}) {
  final totalMinutes = lecture.endTime.difference(lecture.startTime).inMinutes;
  if (totalMinutes <= 0) return 0;

  if (now.isBefore(lecture.startTime) ||
      now.isAtSameMomentAs(lecture.startTime)) {
    return maxPoints;
  }

  if (now.isAfter(lecture.endTime)) return 0;

  final remainingMinutes = lecture.endTime.difference(now).inMinutes;
  final ratio = remainingMinutes / totalMinutes;
  final points = (ratio * maxPoints).round();
  if (points < 0) return 0;
  if (points > maxPoints) return maxPoints;
  return points;
}

int calculateAttendancePoints(
  DateTime checkoutTime,
  Lecture lecture,
  DateTime checkInTime, {
  int maxPoints = defaultMaxCheckInPoints,
}) {
  if (checkoutTime.isBefore(lecture.startTime)) return 0;

  final lectureStart = lecture.startTime;
  final lectureEnd = lecture.endTime;
  if (!checkoutTime.isBefore(lectureEnd)) {
    checkoutTime = lectureEnd;
  }

  var effectiveStart =
      checkInTime.isAfter(lectureStart) ? checkInTime : lectureStart;
  if (!effectiveStart.isBefore(lectureEnd)) return 0;

  final totalMinutes = lectureEnd.difference(lectureStart).inMinutes;
  if (totalMinutes <= 0) return 0;

  final attendedMinutes = checkoutTime
      .difference(effectiveStart)
      .inMinutes
      .clamp(0, totalMinutes);
  final ratio = attendedMinutes / totalMinutes;
  final points = (ratio * maxPoints).round();
  if (points < 0) return 0;
  if (points > maxPoints) return maxPoints;
  return points;
}
