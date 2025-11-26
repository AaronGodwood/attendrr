class AppLockService {
  bool _isLocked = false;
  String? _lockReason;
  DateTime? _lockExpiryTime;

  bool get isLocked {
    if (_isLocked && _lockExpiryTime != null) {
      if (DateTime.now().isAfter(_lockExpiryTime!)) {
        unlock();
        return false;
      }
    }
    return _isLocked;
  }

  String? get lockReason => _lockReason;
  DateTime? get lockExpiryTime => _lockExpiryTime;

  void lock(String reason, {Duration? duration}) {
    _isLocked = true;
    _lockReason = reason;
    if (duration != null) {
      _lockExpiryTime = DateTime.now().add(duration);
    }
  }

  void unlock() {
    _isLocked = false;
    _lockReason = null;
    _lockExpiryTime = null;
  }

  Duration? getRemainingLockTime() {
    if (_lockExpiryTime == null) return null;
    final remaining = _lockExpiryTime!.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }
}
