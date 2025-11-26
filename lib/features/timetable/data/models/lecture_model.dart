// Lecture model
class LectureModel {
  final String id;
  final String title;
  final String location;
  final DateTime startTime;
  final DateTime endTime;

  LectureModel({
    required this.id,
    required this.title,
    required this.location,
    required this.startTime,
    required this.endTime,
  });

  factory LectureModel.fromJson(Map<String, dynamic> json) {
    return LectureModel(
      id: json['id'],
      title: json['title'],
      location: json['location'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
    };
  }
}
