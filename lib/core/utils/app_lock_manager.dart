class AppLockManager {
  static bool _isLocked = false;
  static String? _lockedReason;

  static bool get isLocked => _isLocked;
  static String? get lockedReason => _lockedReason;

  static void lockApp(String reason) {
    _isLocked = true;
    _lockedReason = reason;
  }

  static void unlockApp() {
    _isLocked = false;
    _lockedReason = null;
  }
}
