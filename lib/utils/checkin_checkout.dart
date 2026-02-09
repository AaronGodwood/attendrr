import '../models/lecture.dart';

bool shouldAutoCheckout(DateTime now, Lecture? lecture) {
  if (lecture == null) return false;
  return now.isAfter(lecture.endTime);
}
