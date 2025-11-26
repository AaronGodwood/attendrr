// Lecture entity
class Lecture {
  final String id;
  final String title;
  final String location;
  final DateTime startTime;
  final DateTime endTime;

  Lecture({
    required this.id,
    required this.title,
    required this.location,
    required this.startTime,
    required this.endTime,
  });
}
