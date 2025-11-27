import 'package:flutter/material.dart';

class TimetableProvider extends ChangeNotifier {
  List<dynamic> _lectures = [];

  List<dynamic> get lectures => _lectures;

  Future<void> loadTimetable() async {
    // TODO: Implement timetable loading
    notifyListeners();
  }

  Future<void> syncTimetable() async {
    // TODO: Implement timetable sync
    notifyListeners();
  }
}
