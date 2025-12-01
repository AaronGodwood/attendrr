class AppConstants {
  // Location
  static const double checkInRadiusMeters = 100.0;

  // Points
  static const int fullCheckInPoints = 10;
  static const int reducedCheckInPoints = 5;

  // Streaks
  static const int initialStreakFreezes = 3;

  // Sync
  static const int syncIntervalHours = 12;

  // Pagination
  static const int leaderboardPageSize = 50;

  // Validation
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  static const int minPasswordLength = 6;

  // Deep links
  static const String deepLinkScheme = 'io.supabase.lecturetracker';
  static const String loginCallback = '$deepLinkScheme://login-callback';
  static const String resetPasswordCallback = '$deepLinkScheme://reset-password';
}

class StorageKeys {
  static const String themeMode = 'theme_mode';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String reminderMinutes = 'reminder_minutes';
}