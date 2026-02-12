import 'dart:async';
import 'package:flutter/foundation.dart';
import '../repositories/timetable_repository.dart';
import '../repositories/attendance_repository.dart';
import '../services/location_service.dart';
import '../models/models.dart';
import '../utils/checkin_checkout.dart';
import '../utils/checkin_rules.dart';
import '../utils/constants.dart';

enum CheckInState {
  loading,
  noLecture,
  readyToCheckIn,
  tooFarAway,
  alreadyCheckedIn,
  checkingIn,
  checkedIn,
  error,
}

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
  Timer? _checkoutTimer;
  bool _alreadyCheckedIn = false;

  CheckInState get state => _state;
  Lecture? get currentLecture => _currentLecture;
  Lecture? get nextLecture => _nextLecture;
  Attendance? get activeAttendance => _activeAttendance;
  double? get distance => _distance;
  String? get error => _error;
  bool get alreadyCheckedIn => _alreadyCheckedIn;

  Duration? get timeUntilNext => _nextLecture?.timeUntilStart;
  Duration? get timeRemaining => _currentLecture?.timeRemaining;
  bool get isWithinWindow =>
      isWithinCheckInWindow(DateTime.now(), _currentLecture);
  int get projectedPoints =>
      _currentLecture == null
          ? 0
          : calculateCheckInPoints(DateTime.now(), _currentLecture!);

  bool get canCheckIn {
    return canCheckInNow(
          DateTime.now(),
          _currentLecture,
          distanceMeters: _distance,
          maxDistanceMeters: AppConstants.checkInRadiusMeters,
          earlyWindow: defaultEarlyCheckInWindow,
        ) &&
        !_alreadyCheckedIn;
  }

  @override
  void dispose() {
    _checkoutTimer?.cancel();
    super.dispose();
  }

  Future<void> loadState() async {
    _state = CheckInState.loading;
    _alreadyCheckedIn = false;
    _distance = null;
    _error = null;
    _nextLecture = null;
    notifyListeners();

    try {
      // Check for active attendance first
      _activeAttendance = await _attendanceRepo.getActiveAttendance();
      if (_activeAttendance != null) {
        _currentLecture = _activeAttendance!.lecture;
        _state = CheckInState.checkedIn;
        _startCheckoutTimer();
        notifyListeners();
        return;
      }

      // Check for current lecture
      _currentLecture = await _timetableRepo.getCurrentLecture();

      if (_currentLecture != null) {
        final existingAttendance = await _attendanceRepo
            .getAttendanceForLecture(_currentLecture!.id);
        if (existingAttendance != null) {
          _alreadyCheckedIn = true;
          _state = CheckInState.alreadyCheckedIn;
        } else {
          await _checkLocation();
        }
      } else {
        _nextLecture = await _timetableRepo.getNextLecture();
        if (_nextLecture != null &&
            (_nextLecture!.timeUntilStart ?? const Duration(days: 1)) <=
                defaultEarlyCheckInWindow) {
          _currentLecture = _nextLecture;
          _nextLecture = null;
          final existingAttendance = await _attendanceRepo
              .getAttendanceForLecture(_currentLecture!.id);
          if (existingAttendance != null) {
            _alreadyCheckedIn = true;
            _state = CheckInState.alreadyCheckedIn;
          } else {
            await _checkLocation();
          }
        } else {
          _state = CheckInState.noLecture;
        }
      }

      notifyListeners();
    } catch (e) {
      _state = CheckInState.error;
      _error = e.toString();
      notifyListeners();
    }
  }

  void _startCheckoutTimer() {
    _checkoutTimer?.cancel();
    _checkoutTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (shouldAutoCheckout(DateTime.now(), _currentLecture)) {
        checkOut();
      }
    });
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
    _state =
        result.verified ? CheckInState.readyToCheckIn : CheckInState.tooFarAway;
  }

  Future<void> checkIn() async {
    if (_currentLecture == null) return;
    if (!canCheckIn) {
      _state = CheckInState.error;
      _error =
          'Check-in is only available within the lecture window at the lecture location.';
      notifyListeners();
      return;
    }

    _state = CheckInState.checkingIn;
    notifyListeners();

    try {
      final locationVerified =
          _currentLecture!.hasValidCoordinates &&
          _distance != null &&
          _distance! <= AppConstants.checkInRadiusMeters;
      final points = calculateCheckInPoints(DateTime.now(), _currentLecture!);
      _activeAttendance = await _attendanceRepo.checkIn(
        lectureId: _currentLecture!.id,
        locationVerified: locationVerified,
        distanceMeters: _distance,
        pointsEarned: points,
      );

      _state = CheckInState.checkedIn;
      _startCheckoutTimer();
      notifyListeners();
    } catch (e) {
      _state = CheckInState.error;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> checkOut() async {
    if (_activeAttendance == null) return;

    _checkoutTimer?.cancel();
    try {
      final lecture = _activeAttendance!.lecture;
      if (lecture != null) {
        final newPoints = calculateAttendancePoints(
          DateTime.now(),
          lecture,
          _activeAttendance!.checkInTime,
        );
        final previousPoints = _activeAttendance!.pointsEarned;
        if (newPoints != previousPoints) {
          await _attendanceRepo.updatePoints(
            attendanceId: _activeAttendance!.id,
            pointsEarned: newPoints,
          );
          await _attendanceRepo.adjustUserPoints(newPoints - previousPoints);
        }
      }
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
