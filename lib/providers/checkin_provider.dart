import 'package:flutter/foundation.dart';
import '../repositories/timetable_repository.dart';
import '../repositories/attendance_repository.dart';
import '../services/location_service.dart';
import '../models/models.dart';

enum CheckInState { loading, noLecture, readyToCheckIn, tooFarAway, checkingIn, checkedIn, error }

class CheckInProvider extends ChangeNotifier {
  final _timetableRepo = TimetableRepository.instance;
  final _attendanceRepo = AttendanceRepository.instance;
  final _locationService = LocationService.instance;

  CheckInState _state = CheckInState.loading;
  Lecture? _currentLecture;
  Lecture? _nextLecture;
  Attendance? _activeAttendance;
  double? _distance;
  String? _error;

  CheckInState get state => _state;
  Lecture? get currentLecture => _currentLecture;
  Lecture? get nextLecture => _nextLecture;
  Attendance? get activeAttendance => _activeAttendance;
  double? get distance => _distance;
  String? get error => _error;

  Duration? get timeUntilNext => _nextLecture?.timeUntilStart;
  Duration? get timeRemaining => _currentLecture?.timeRemaining;

  Future<void> loadState() async {
    _state = CheckInState.loading;
    notifyListeners();

    try {
      // Check for active attendance first
      _activeAttendance = await _attendanceRepo.getActiveAttendance();
      if (_activeAttendance != null) {
        _currentLecture = _activeAttendance!.lecture;
        _state = CheckInState.checkedIn;
        notifyListeners();
        return;
      }

      // Check for current lecture
      _currentLecture = await _timetableRepo.getCurrentLecture();

      if (_currentLecture != null) {
        await _checkLocation();
      } else {
        _nextLecture = await _timetableRepo.getNextLecture();
        _state = CheckInState.noLecture;
      }

      notifyListeners();
    } catch (e) {
      _state = CheckInState.error;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> _checkLocation() async {
    if (!_currentLecture!.hasValidCoordinates) {
      _state = CheckInState.readyToCheckIn;
      _distance = null;
      return;
    }

    final result = await _locationService.verifyLocation(
      _currentLecture!.latitude,
      _currentLecture!.longitude,
    );

    _distance = result.distance;
    _state = result.verified ? CheckInState.readyToCheckIn : CheckInState.tooFarAway;
  }

  Future<void> checkIn({bool forceWithoutLocation = false}) async {
    if (_currentLecture == null) return;

    _state = CheckInState.checkingIn;
    notifyListeners();

    try {
      final locationVerified = _distance != null && _distance! <= 100;

      _activeAttendance = await _attendanceRepo.checkIn(
        lectureId: _currentLecture!.id,
        locationVerified: locationVerified || forceWithoutLocation,
        distanceMeters: _distance,
      );

      _state = CheckInState.checkedIn;
      notifyListeners();
    } catch (e) {
      _state = CheckInState.error;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> checkOut() async {
    if (_activeAttendance == null) return;

    try {
      await _attendanceRepo.checkOut(_activeAttendance!.id);
      _activeAttendance = null;
      await loadState();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> refresh() => loadState();
}