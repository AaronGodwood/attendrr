DateTime nextCheckInRefreshTime(DateTime now) {
  const minutes = [0, 5, 15, 30, 45];
  for (final m in minutes) {
    if (now.minute < m || (now.minute == m && now.second == 0)) {
      return DateTime(now.year, now.month, now.day, now.hour, m, 0);
    }
  }

  return DateTime(now.year, now.month, now.day, now.hour + 1, 0, 0);
}
