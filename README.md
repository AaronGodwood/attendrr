# Lecture Tracker (Attendr)

A comprehensive Flutter application for tracking university lecture attendance with gamification features.

## Features

- **Authentication**: User registration, login, and password recovery
- **Timetable Management**: Link and sync university timetables
- **Attendance Tracking**: Location-based check-ins for lectures
- **Social Features**: Connect with friends and compare attendance
- **Gamification**: Streaks, achievements, points, and leaderboards
- **App Locking**: Lock the app during lectures to earn rewards

## Project Structure

This project follows Clean Architecture principles with feature-based organization:

```
lib/
├── config/              # App configuration (themes, routes, constants)
├── core/               # Shared utilities, widgets, and constants
│   ├── errors/         # Exception and failure handling
│   ├── utils/          # Validators, formatters, helpers
│   ├── widgets/        # Reusable UI components
│   └── constants/      # App-wide constants
├── features/           # Feature modules
│   ├── auth/           # Authentication
│   ├── timetable/      # Timetable management
│   ├── attendance/     # Attendance tracking
│   ├── social/         # Social features
│   ├── gamification/   # Streaks, achievements, leaderboard
│   └── home/           # Home dashboard
└── services/           # Platform services
```

Each feature follows the Clean Architecture pattern:
- **data/**: Data sources, models, repository implementations
- **domain/**: Entities, repository interfaces, use cases
- **presentation/**: Pages, widgets, providers

## Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Supabase account (for backend)

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd attendr
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Set up environment variables:
   Create a `.env` file in the root directory:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Dependencies

Key dependencies used in this project:
- `supabase_flutter` - Backend and authentication
- `geolocator` - Location services
- `flutter_local_notifications` - Push notifications
- `shared_preferences` - Local storage
- `intl` - Date/time formatting

## Architecture

This project implements Clean Architecture with the following layers:

1. **Presentation Layer**: UI components, pages, and state management
2. **Domain Layer**: Business logic, entities, and use cases
3. **Data Layer**: Data sources and repository implementations

## Contributing

Contributions are welcome! Please follow these steps:
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a pull request

## License

This project is licensed under the MIT License.
