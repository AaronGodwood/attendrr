import 'package:flutter/material.dart';

class AttendanceProvider extends ChangeNotifier {
  bool _isCheckedIn = false;

  bool get isCheckedIn => _isCheckedIn;

  Future<void> checkIn() async {
    // TODO: Implement check-in
    _isCheckedIn = true;
    notifyListeners();
  }

  Future<void> checkOut() async {
    // TODO: Implement check-out
    _isCheckedIn = false;
    notifyListeners();
  }
}
