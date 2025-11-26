// Timetable model
class TimetableModel {
  final String id;
  final List<dynamic> lectures;

  TimetableModel({required this.id, required this.lectures});

  factory TimetableModel.fromJson(Map<String, dynamic> json) {
    return TimetableModel(
      id: json['id'],
      lectures: json['lectures'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lectures': lectures,
    };
  }
}
