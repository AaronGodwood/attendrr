import 'package:flutter/foundation.dart';
import '../repositories/timetable_repository.dart';
import '../models/models.dart';

class TimetableProvider extends ChangeNotifier {
  final _repo = TimetableRepository.instance;

  List<LectureWithAttendance> _lectures = [];
  DateTime _selectedWeek = _getWeekStart(DateTime.now());
  bool _isLoading = false;
  bool _isSyncing = false;
  String? _error;
  SyncResult? _lastSyncResult;

  List<LectureWithAttendance> get lectures => _lectures;
  DateTime get selectedWeek => _selectedWeek;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get error => _error;
  SyncResult? get lastSyncResult => _lastSyncResult;

  Map<int, List<LectureWithAttendance>> get lecturesByDay {
    final Map<int, List<LectureWithAttendance>> grouped = {};
    for (final lecture in _lectures) {
      final day = lecture.lecture.dayOfWeek;
      grouped.putIfAbsent(day, () => []).add(lecture);
    }
    return grouped;
  }

  Future<void> loadWeek([DateTime? week]) async {
    if (week != null) _selectedWeek = _getWeekStart(week);

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _lectures = await _repo.getLecturesForWeek(_selectedWeek);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> syncFromIcal(String icalUrl) async {
    _isSyncing = true;
    _error = null;
    notifyListeners();

    try {
      _lastSyncResult = await _repo.syncFromIcal(icalUrl);
      _isSyncing = false;
      await loadWeek();
      return true;
    } catch (e) {
      _isSyncing = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void nextWeek() => loadWeek(_selectedWeek.add(const Duration(days: 7)));
  void previousWeek() => loadWeek(_selectedWeek.subtract(const Duration(days: 7)));
  void goToToday() => loadWeek(DateTime.now());

  static DateTime _getWeekStart(DateTime date) {
    return DateTime(date.year, date.month, date.day - (date.weekday - 1));
  }
}