import 'package:flutter/foundation.dart';
import '../repositories/user_repository.dart';
import '../repositories/attendance_repository.dart';
import '../models/models.dart';

class ProfileProvider extends ChangeNotifier {
  final _userRepo = UserRepository.instance;
  final _attendanceRepo = AttendanceRepository.instance;

  User? _user;
  Streak? _streak;
  Points? _points;
  AttendanceStats? _stats;
  List<DailyAttendance>? _history;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  Streak? get streak => _streak;
  Points? get points => _points;
  AttendanceStats? get stats => _stats;
  List<DailyAttendance>? get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final profile = await _userRepo.getFullProfile();
      _user = profile.user;
      _streak = profile.streak;
      _points = profile.points;
      _stats = await _attendanceRepo.getStats();
      _history = await _attendanceRepo.getHistory(30);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateUsername(String username) async {
    try {
      await _userRepo.updateProfile(username: username);
      await loadProfile();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> refresh() => loadProfile();
}