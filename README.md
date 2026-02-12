
# Attendr – Lecture Attendance Tracker

A gamified Flutter app for tracking university lecture attendance. Features include location-based check-in, streaks, points, leaderboards, friends, and iCal timetable import. Built with Flutter and Supabase, and deployed automatically to GitHub Pages.

---

## Features

- **Authentication**: Email/password and Google OAuth via Supabase
- **Timetable**: Import from iCal URL, week view calendar
- **Check-in**: Location-verified attendance with points and GPS validation
- **Gamification**: Streaks, points, achievements, leaderboards
- **Social**: Friends, friend requests, global and friends leaderboards
- **Notifications**: Reminders before lectures
- **Web & Mobile**: Runs on iOS, Android, and Web (deployed to GitHub Pages)

---

## Architecture

- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (PostgreSQL, Auth, Realtime, Storage)
- **State Management**: Provider
- **Navigation**: GoRouter
- **Location Services**: Geolocator
- **Local Storage**: SharedPreferences
- **Repository Pattern**: Clean separation of data, logic, and UI

---

## Getting Started

### Prerequisites

- Flutter 3.0+
- Supabase account
- iOS/Android/Web development environment

### 1. Clone & Install

```bash
git clone https://github.com/<your-username>/attendrr.git
cd attendrr
flutter pub get
```

### 2. Supabase Setup

1. Create a new Supabase project at [supabase.com](https://supabase.com)
2. Run the provided SQL files in order to set up tables, RLS, functions, and triggers.
3. Enable Google OAuth (optional) and copy your project credentials.

### 3. Configure Environment

Create a `.env` file in your project root:

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

### 4. Run

```bash
# iOS
flutter run -d ios

# Android
flutter run -d android

# Web
flutter run -d web
```

---

## Continuous Integration & Deployment

This project uses GitHub Actions for CI/CD:

- **Build**: Installs dependencies and checks that the project compiles.
- **Analyze**: Runs static analysis for code quality.
- **Test**: Runs all unit and widget tests.
- **Deploy**: Builds the Flutter web app and deploys it to GitHub Pages.

Every push or pull request to `main` triggers the pipeline. The latest web build is published to GitHub Pages at:

```
https://<your-github-username>.github.io/<your-repo-name>/
```

---

## Project Structure

```
lib/
  main.dart
  config/
  models/
  services/
  repositories/
  providers/
  pages/
  widgets/
  router/
  theme/
  utils/
```

---

## License

MIT License – see LICENSE file for details.

### Prerequisites

- Flutter 3.0+
- Supabase account
- iOS/Android development environment

### 1. Clone & Install

```bash
git clone https://github.com/yourusername/lecture_tracker.git
cd lecture_tracker
flutter pub get
```

### 2. Supabase Setup

1. Create a new Supabase project at [supabase.com](https://supabase.com)

2. Run the SQL files in order in the SQL Editor:
   - `001_schema.sql` - Tables and indexes
   - `002_rls.sql` - Row Level Security policies
   - `003_functions.sql` - RPC functions
   - `004_triggers.sql` - Automatic updates
   - `005_seed.sql` - Initial data (achievements)

3. Enable Google OAuth (optional):
   - Go to Authentication → Providers → Google
   - Add your Google Cloud OAuth credentials

4. Copy your project credentials:
   - Project URL: `https://xxxxx.supabase.co`
   - Anon Key: `eyJhbGc...`

### 3. Configure Environment

Create `lib/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String url = 'https://YOUR_PROJECT.supabase.co';
  static const String anonKey = 'YOUR_ANON_KEY';
}
```

Or use environment variables:

```bash
flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJ...
```

### 4. Run

```bash
# iOS
flutter run -d ios

# Android
flutter run -d android
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── config/
│   └── supabase_config.dart  # Supabase credentials
├── models/
│   ├── models.dart           # Barrel export
│   ├── user.dart
│   ├── lecture.dart
│   ├── attendance.dart
│   ├── streak.dart
│   ├── points.dart
│   ├── friendship.dart
│   └── leaderboard_entry.dart
├── services/
│   ├── auth_service.dart     # Supabase Auth wrapper
│   ├── location_service.dart # GPS/Geolocator
│   ├── ical_service.dart     # iCal parsing
│   └── notification_service.dart
├── repositories/
│   ├── base_repository.dart
│   ├── user_repository.dart
│   ├── timetable_repository.dart
│   ├── attendance_repository.dart
│   ├── friends_repository.dart
│   └── leaderboard_repository.dart
├── providers/
│   ├── auth_provider.dart
│   ├── profile_provider.dart
│   ├── timetable_provider.dart
│   ├── checkin_provider.dart
│   └── friends_provider.dart
├── pages/
│   ├── splash_page.dart
│   ├── login_page.dart
│   ├── signup_page.dart
│   ├── home_page.dart
│   ├── profile_page.dart
│   ├── timetable_page.dart
│   ├── checkin_page.dart
│   ├── friends_page.dart
│   └── settings_page.dart
├── widgets/
│   ├── lecture_card.dart
│   ├── stats_card.dart
│   ├── friend_card.dart
│   └── ...
├── router/
│   └── app_router.dart
├── theme/
│   └── app_theme.dart
└── utils/
    └── constants.dart
```

## Database Schema

```
profiles          streaks           points
├── id (PK)       ├── id (PK)       ├── id (PK)
├── email         ├── user_id (FK)  ├── user_id (FK)
├── username      ├── current       ├── total
├── avatar_url    ├── longest       ├── weekly
└── ical_url      └── freezes       └── monthly

timetables        lectures          attendance
├── id (PK)       ├── id (PK)       ├── id (PK)
├── user_id (FK)  ├── timetable_id  ├── user_id (FK)
├── name          ├── title         ├── lecture_id (FK)
└── source        ├── location      ├── check_in_time
                  ├── lat/lng       ├── location_verified
                  └── start/end     └── points_earned

friendships
├── id (PK)
├── user_id (FK)
├── friend_id (FK)
└── status (pending/accepted/rejected)
```

## Gamification

### Points

| Action | Points |
|--------|--------|
| Check-in (verified location) | 10 |
| Check-in (unverified) | 5 |


### Streaks

- Attend at least one lecture per day to maintain streak
- Streak expires 36 hours after last check-in
- 3 streak freezes provided initially
- Freezes protect your streak for one day

## Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.4.0    # State management
  supabase_flutter: ^2.0.0    # Backend
  go_router: ^12.0.0          # Navigation
  geolocator: ^10.0.0         # GPS
  http: ^1.1.0                # HTTP requests
  icalendar_parser: ^2.0.0    # iCal parsing
  flutter_local_notifications: ^16.0.0
  intl: ^0.18.0               # Date formatting
  equatable: ^2.0.5           # Value equality
  cached_network_image: ^3.3.0
  fl_chart: ^0.65.0           # Charts
```

## Configuration

### Location Settings

The app validates check-ins within 100 meters of the lecture location. To adjust:

```sql
-- In check_in() function, change the distance threshold
v_location_verified := v_distance <= 100;  -- Change 100 to desired meters
```

### Check-in Window

Check-ins are allowed 15 minutes before lecture start until lecture end:

```sql
-- In check_in() function
IF NOW() < v_lecture.start_time - INTERVAL '15 minutes' THEN
  -- Too early
```

### Streak Expiration

Streaks expire 36 hours after last attendance. To adjust, modify the `update_streak_internal()` function.

## Scheduled Tasks

Set up these cron jobs in Supabase (or use pg_cron):

```sql
-- Reset weekly points every Monday at midnight
SELECT cron.schedule('reset-weekly', '0 0 * * 1', 'SELECT reset_weekly_points()');

-- Reset monthly points on 1st of each month
SELECT cron.schedule('reset-monthly', '0 0 1 * *', 'SELECT reset_monthly_points()');

-- Expire old streaks every hour
SELECT cron.schedule('expire-streaks', '0 * * * *', 'SELECT expire_streaks()');
```

## Troubleshooting

### "Too far from lecture location"

- Ensure GPS is enabled on device
- Check lecture has valid coordinates (lat/lng ≠ 0)
- User can force check-in without location (awards 5 points instead of 10)

### iCal sync not working

- Verify URL is accessible (not behind auth)
- URL must contain `BEGIN:VCALENDAR` and `BEGIN:VEVENT`
- Check network connectivity

### Auth issues

- Ensure Supabase URL and anon key are correct
- For Google OAuth, verify redirect URL matches: `io.supabase.lecturetracker://login-callback`

## License

MIT License - see LICENSE file for details.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
