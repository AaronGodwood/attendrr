# Attendr

**Attendr** is a cross-platform mobile application built with Flutter designed to streamline attendance tracking and social interaction. It leverages Supabase for a robust, real-time backend, ensuring secure data handling and authentication.
## Tech Stack

* **Frontend:** Flutter (Dart)

* **Backend:** Supabase (PostgreSQL, Auth, Realtime)

* **State Management/Architecture:** Repository Pattern

* **Environment Management:** `flutter_dotenv`

* **Testing:** `auth_test`, `security_test`, `navigation_test`, `models_test`

## Features

* **User Authentication:** Secure Login and Signup flows using Supabase Auth.

* **Profile Management:** User profiles backed by strict Row Level Security (RLS) policies.

* **Attendance Tracking:** Logic to identify active lectures based on current time schedules.

* **Social Connectivity:** Friend system (Repository and Models included).

* **Robust Navigation:** Context-aware routing and protected dashboard views.

## Getting Started

### Prerequisites

* [Flutter SDK](https://docs.flutter.dev/get-started/install)

* Supabase Project (for backend URL and Keys)

### Installation

1. **Clone the repository:**

```
git clone [https://github.com/yourusername/attendr.git](https://github.com/yourusername/attendr.git)
cd attendr
```


2. **Install dependencies:**

```bash
flutter pub get
```


3. **Environment Setup:**
This project uses `.env` files to manage secrets. You must create them in the project root.

**Create a `.env` file for development:**

```
SUPABASE_URL=your_project_url
SUPABASE_ANON_KEY=your_anon_key
```


**Create a `.env.test` file for testing:**

```
SUPABASE_URL=your_project_url
SUPABASE_ANON_KEY=your_anon_key
TEST_USER_EMAIL=test@example.com
TEST_USER_PASSWORD=securepassword123
NON_EXISTENT_ID=some-fake-uuid
```


*Note: Add `*.env` to your `.gitignore` to prevent leaking secrets.*

## Testing Strategy

Attendr employs a multi-layered testing strategy to ensure reliability and security.

### 1. Unit Tests

Verifies that data models (e.g., User, Lecture) correctly parse JSON payloads from Supabase and handle edge cases (null fields, malformed data).

### 2. Widget/Behaviour Tests

Simulates user interactions to validate navigation logic, ensuring the router pushes the correct pages for actions like logging in or accessing the dashboard.

### 3. Integration Tests

We verify the integrity of the connection between the Flutter app and Supabase.

* **Data Integrity:** Confirms the repository layer correctly instantiates objects from live database data.

* **Security (RLS):** Validates that unauthenticated users cannot access protected data and that RLS policies are active.

**To run the integration tests:**

```bash
flutter test test/unit
flutter test test/widget
flutter test test/integration
```


## Project Structure

```
lib/
├── models/         # Data models (User, Friendship, Lecture)
├── repositories/   # Data access layer (Supabase interaction)
├── pages/          # UI Screens
├── providers/      # UI Screens
├── router/       
├── services/        
├── theme/   
├── utils/      
├── widgets/     
└── main.dart       # Entry point
test/
├── unit/           # JSON parsing and logic tests
├── widget/         # Navigation and UI rendering tests
└── integration/    # Supabase connection and Security tests
```
