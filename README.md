# Attendrr

A Flutter application for gamified lecture attendance tracking, built for University of Bath students. Submitted as coursework for **CM22007 Software Engineering** (Year 2).

**Live deployment:** [aarongodwood.github.io/attendrr](https://aarongodwood.github.io/attendrr)

---

## Team

Aaron Godwood, Will Barnard, Dylan Tombs, Isaac Strid, Harry Thacker, Leo Pagani, Brandon Greenstone, Charlie Harrison, Sami

---

## Overview

Attendrr lets University of Bath students track their lecture attendance by checking in via GPS proximity when they arrive at a lecture. Attendance is gamified through streaks, a points-based tier system, and a friends leaderboard — encouraging students to maintain consistent attendance habits.

Key features:
- **GPS check-in** — verifies physical presence at a lecture location using proximity detection
- **Timetable sync** — imports lectures via iCal URL from MyTimetable (University of Bath's timetable system)
- **Streaks** — consecutive attendance streaks with freeze power-ups to protect against missed lectures
- **Points & tiers** — points earned per check-in (scaled by how early you arrive), progressing through six tiers from Newcomer to Legendary
- **Friends & leaderboard** — add friends, view ranked leaderboards by points or streaks
- **Shop** — spend earned points on streak freezes and weekly point boost multipliers

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart ^3.7.2) |
| Backend | Supabase (PostgreSQL + Auth + Storage) |
| State management | Provider (`ChangeNotifier`) |
| Navigation | GoRouter |
| Location | Geolocator |
| Timetable import | iCalendar Parser |
| Local storage | SharedPreferences, Hive |
| Charts | fl_chart |
| HTTP | Dio |

---

## Architecture

The project follows a layered architecture with clear separation of concerns:

```
lib/
├── main.dart                  # Entry point, MultiProvider setup
├── models/                    # Immutable data classes (Equatable + copyWith)
├── repositories/              # Data access layer (Supabase queries)
├── providers/                 # State management (ChangeNotifier)
├── services/                  # Business logic (auth, location, iCal, notifications)
├── pages/                     # Screen-level widgets
├── widgets/                   # Reusable UI components
├── router/                    # GoRouter navigation configuration
├── theme/                     # Material 3 theming, color palette, typography
└── utils/                     # Constants and helper functions
```

**Data flow:** Pages consume Providers → Providers call Repositories → Repositories interact with Supabase or Services.

Models are immutable and use `Equatable` for value equality. Error handling in repositories uses typed results rather than raw exceptions where appropriate.

---

## Database Schema

Hosted on Supabase (PostgreSQL). Key tables:

| Table | Purpose |
|---|---|
| `profiles` | User accounts — username, university ID, avatar |
| `timetables` | User timetables with sync source and last-synced timestamp |
| `lectures` | Individual lecture entries with location coordinates |
| `attendance` | Check-in records — time, location verified, points earned |
| `streaks` | Current and longest streak, freeze count, last attendance date |
| `points` | Total, weekly, and monthly points with optional boost multiplier |
| `friendships` | Friend relationships with pending/accepted/rejected status |
| `shop_items` / `purchases` | Shop inventory and purchase history |

Supabase RPC functions handle atomic operations: `add_points` and `update_streak` run server-side to prevent race conditions.

---

## Check-in System

1. The app imports a student's timetable by fetching their MyTimetable iCal URL (configured in Settings).
2. When a lecture is active, the Check-in page becomes available.
3. The student's GPS coordinates are compared against the stored coordinates of the lecture's building.
4. If within the proximity threshold, the check-in is recorded and points are awarded.
5. Points scale based on how early in the lecture window the student checks in.
6. Streak logic runs server-side after each check-in via the `update_streak` RPC.

---

## Local Development Setup

### Prerequisites

- Flutter SDK (≥ 3.7.2) — [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
- Dart SDK (included with Flutter)
- A Supabase project

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/AaronGodwood/attendrr.git
   cd attendrr
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**

   Create a `.env` file in the project root:
   ```env
   SUPABASE_URL=your_supabase_project_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   OAUTH_REDIRECT_URL=com.example.attendr://login-callback
   PASSWORD_RESET_REDIRECT_URL=com.example.attendr://reset-password
   ```

4. **Run code generation** (for Freezed and JSON serialization)
   ```bash
   flutter pub run build_runner build
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

### Other commands

```bash
flutter test        # Run tests
flutter analyze     # Static analysis
flutter build apk   # Android release build
flutter build web   # Web release build
```

---

## Supported Platforms

- Android
- iOS
- Web (deployed via GitHub Pages)
