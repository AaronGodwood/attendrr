# Lecture Attendance Tracker - Complete Implementation Specification

## Table of Contents
1. [Project Overview](#project-overview)
2. [Navigation Structure](#navigation-structure)
3. [Authentication Flow](#authentication-flow)
4. [Page Implementations](#page-implementations)
5. [Data Models](#data-models)
6. [State Management](#state-management)
7. [Supabase Integration](#supabase-integration)
8. [Supabase Project Setup Guide](#supabase-project-setup-guide)
9. [iCal Calendar Integration](#ical-calendar-integration)
10. [Real Data Implementation](#real-data-implementation)
11. [Services Implementation](#services-implementation)
12. [Component Specifications](#component-specifications)

---

## Project Overview

### Technology Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (PostgreSQL, Auth, Realtime, Storage)
- **State Management**: Provider
- **Navigation**: GoRouter with bottom navigation
- **Location Services**: Geolocator package
- **Local Storage**: SharedPreferences for settings
- **Architecture**: Clean Architecture with Repository Pattern

### Dependencies (pubspec.yaml)

```yaml
name: lecture_tracker
description: A gamified lecture attendance tracking app
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # Supabase
  supabase_flutter: ^2.3.0
  
  # State Management
  provider: ^6.1.1
  
  # Navigation
  go_router: ^13.0.0
  
  # Location
  geolocator: ^11.0.0
  geocoding: ^2.1.1
  
  # Local Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  
  # Environment Variables
  flutter_dotenv: ^5.1.0
  
  # iCal Parsing
  icalendar_parser: ^2.0.0
  
  # HTTP
  http: ^1.1.0
  
  # Utilities
  equatable: ^2.0.5
  intl: ^0.18.1
  uuid: ^4.2.1
  
  # Notifications
  flutter_local_notifications: ^16.2.0
  
  # Background Tasks
  workmanager: ^0.5.2
  
  # UI Components
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  fl_chart: ^0.65.0
  
  # Icons
  cupertino_icons: ^1.0.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  mockito: ^5.4.4
  build_runner: ^2.4.8

flutter:
  uses-material-design: true
  
  assets:
    - .env
    - assets/images/
```

### Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── models.dart          # Barrel file
│   ├── user.dart
│   ├── user_profile.dart
│   ├── timetable.dart
│   ├── lecture.dart
│   ├── attendance.dart
│   ├── streak.dart
│   ├── points.dart
│   ├── friendship.dart
│   └── leaderboard.dart
├── providers/               # State management
│   ├── auth_provider.dart
│   ├── profile_provider.dart
│   ├── timetable_provider.dart
│   ├── checkin_provider.dart
│   └── friends_provider.dart
├── repositories/            # Data access layer
│   ├── base_repository.dart
│   ├── user_repository.dart
│   ├── lecture_repository.dart
│   ├── attendance_repository.dart
│   ├── friends_repository.dart
│   └── leaderboard_repository.dart
├── services/                # Business logic services
│   ├── auth_service.dart
│   ├── ical_service.dart
│   ├── timetable_sync_service.dart
│   ├── location_service.dart
│   ├── notification_service.dart
│   └── app_lock_service.dart
├── pages/                   # UI screens
│   ├── splash_page.dart
│   ├── login_page.dart
│   ├── signup_page.dart
│   ├── forgot_password_page.dart
│   ├── home_page.dart
│   ├── profile_page.dart
│   ├── settings_page.dart
│   ├── timetable_page.dart
│   ├── checkin_page.dart
│   └── friends_page.dart
├── widgets/                 # Reusable components
│   ├── common/
│   │   ├── loading_indicator.dart
│   │   ├── error_widget.dart
│   │   ├── empty_state.dart
│   │   └── custom_app_bar.dart
│   ├── profile/
│   │   ├── stats_card.dart
│   │   ├── attendance_chart.dart
│   │   └── profile_header.dart
│   ├── timetable/
│   │   ├── week_view_calendar.dart
│   │   ├── lecture_card.dart
│   │   └── week_selector.dart
│   ├── checkin/
│   │   ├── lecture_info_card.dart
│   │   ├── checkin_button.dart
│   │   └── timer_display.dart
│   └── friends/
│       ├── friend_card.dart
│       ├── friend_request_card.dart
│       └── leaderboard_entry.dart
├── router/                  # Navigation
│   └── app_router.dart
├── theme/                   # Theming
│   ├── app_theme.dart
│   └── app_colors.dart
└── utils/                   # Utilities
    ├── constants.dart
    ├── extensions.dart
    └── validators.dart
```

### App Structure
The app has 4 main pages accessible via bottom navigation:
1. **Timetable** - Calendar view of lectures
2. **Current Lecture** - Check-in functionality
3. **Profile** - User profile, stats, settings access
4. **Friends & Leaderboard** - Social features and rankings

---

## Navigation Structure

### Bottom Navigation Implementation
```dart
// Bottom Navigation Bar Configuration
BottomNavigationBar(
  type: BottomNavigationBarType.fixed,
  items: [
    BottomNavigationBarItem(icon: Icons.person, label: 'Profile'),
    BottomNavigationBarItem(icon: Icons.calendar_today, label: 'Timetable'),
    BottomNavigationBarItem(icon: Icons.location_on, label: 'Check In'),
    BottomNavigationBarItem(icon: Icons.leaderboard, label: 'Friends'),
  ],
  currentIndex: selectedIndex,
  onTap: (index) => navigateToPage(index),
)
```

### Route Definitions
- `/` - Splash/loading screen
- `/login` - Login page
- `/signup` - Sign up page
- `/forgot-password` - Password reset request
- `/profile` - Profile page
- `/profile/settings` - Settings page (navigated from profile)
- `/timetable` - Timetable calendar view
- `/checkin` - Current lecture check-in
- `/friends` - Friends and leaderboard

---

## Authentication Flow

This section covers the complete authentication system including login, signup, password reset, email verification, and session management with Supabase Auth.

### Authentication Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        App Start                             │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    SplashScreen                              │
│              Check auth state via Supabase                   │
└─────────────────────────┬───────────────────────────────────┘
                          │
            ┌─────────────┴─────────────┐
            │                           │
            ▼                           ▼
    ┌───────────────┐          ┌───────────────┐
    │   Logged In   │          │  Not Logged   │
    │   (Session)   │          │      In       │
    └───────┬───────┘          └───────┬───────┘
            │                           │
            ▼                           ▼
    ┌───────────────┐          ┌───────────────┐
    │   Main App    │          │  Login Page   │
    │  (HomePage)   │          │               │
    └───────────────┘          └───────┬───────┘
                                       │
                         ┌─────────────┼─────────────┐
                         │             │             │
                         ▼             ▼             ▼
                   ┌──────────┐ ┌──────────┐ ┌──────────────┐
                   │  Login   │ │  Signup  │ │ Forgot Pass  │
                   └──────────┘ └──────────┘ └──────────────┘
```

### Auth Service Implementation

```dart
// lib/services/auth_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();
  
  final SupabaseClient _client = Supabase.instance.client;
  
  // Stream of auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  
  // Current user
  User? get currentUser => _client.auth.currentUser;
  
  // Current session
  Session? get currentSession => _client.auth.currentSession;
  
  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;
  
  /// Sign up with email and password
  /// Creates auth user and triggers database profile creation via trigger
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // Validate inputs
      if (username.length < 3) {
        return AuthResult.failure('Username must be at least 3 characters');
      }
      
      if (password.length < 6) {
        return AuthResult.failure('Password must be at least 6 characters');
      }
      
      // Check if username is already taken
      final existingUser = await _client
          .from('profiles')
          .select('id')
          .eq('username', username)
          .maybeSingle();
      
      if (existingUser != null) {
        return AuthResult.failure('Username is already taken');
      }
      
      // Create auth user with username in metadata
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username}, // Passed to trigger via raw_user_meta_data
      );
      
      if (response.user == null) {
        return AuthResult.failure('Failed to create account');
      }
      
      // Check if email confirmation is required
      if (response.session == null) {
        return AuthResult.success(
          user: response.user,
          message: 'Please check your email to verify your account',
          requiresEmailVerification: true,
        );
      }
      
      return AuthResult.success(user: response.user);
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred: $e');
    }
  }
  
  /// Sign in with email and password
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        return AuthResult.failure('Invalid credentials');
      }
      
      return AuthResult.success(user: response.user);
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred');
    }
  }
  
  /// Sign in with Google OAuth
  Future<AuthResult> signInWithGoogle() async {
    try {
      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.lecturetracker://login-callback',
      );
      
      if (!response) {
        return AuthResult.failure('Google sign in was cancelled');
      }
      
      // OAuth completes via deep link, so we return pending
      return AuthResult.pending();
    } catch (e) {
      return AuthResult.failure('Google sign in failed: $e');
    }
  }
  
  /// Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.lecturetracker://reset-password',
      );
      
      return AuthResult.success(
        message: 'Password reset email sent. Please check your inbox.',
      );
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e));
    } catch (e) {
      return AuthResult.failure('Failed to send reset email');
    }
  }
  
  /// Update password (when user has reset token)
  Future<AuthResult> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      
      return AuthResult.success(message: 'Password updated successfully');
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e));
    } catch (e) {
      return AuthResult.failure('Failed to update password');
    }
  }
  
  /// Resend email verification
  Future<AuthResult> resendVerificationEmail(String email) async {
    try {
      await _client.auth.resend(
        type: OtpType.email,
        email: email,
      );
      
      return AuthResult.success(message: 'Verification email sent');
    } catch (e) {
      return AuthResult.failure('Failed to resend verification email');
    }
  }
  
  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
  
  /// Delete account and all user data
  Future<AuthResult> deleteAccount() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) {
        return AuthResult.failure('No user logged in');
      }
      
      // Call edge function or RPC to delete user data
      // The database cascade will handle related records
      await _client.rpc('delete_user_account');
      
      await signOut();
      
      return AuthResult.success(message: 'Account deleted');
    } catch (e) {
      return AuthResult.failure('Failed to delete account: $e');
    }
  }
  
  /// Map Supabase auth errors to user-friendly messages
  String _mapAuthError(AuthException e) {
    switch (e.message) {
      case 'Invalid login credentials':
        return 'Incorrect email or password';
      case 'Email not confirmed':
        return 'Please verify your email before signing in';
      case 'User already registered':
        return 'An account with this email already exists';
      case 'Password should be at least 6 characters':
        return 'Password must be at least 6 characters';
      case 'Unable to validate email address: invalid format':
        return 'Please enter a valid email address';
      default:
        return e.message;
    }
  }
}

/// Result class for auth operations
class AuthResult {
  final bool success;
  final User? user;
  final String? message;
  final String? error;
  final bool requiresEmailVerification;
  final bool isPending; // For OAuth flows
  
  AuthResult._({
    required this.success,
    this.user,
    this.message,
    this.error,
    this.requiresEmailVerification = false,
    this.isPending = false,
  });
  
  factory AuthResult.success({
    User? user,
    String? message,
    bool requiresEmailVerification = false,
  }) {
    return AuthResult._(
      success: true,
      user: user,
      message: message,
      requiresEmailVerification: requiresEmailVerification,
    );
  }
  
  factory AuthResult.failure(String error) {
    return AuthResult._(success: false, error: error);
  }
  
  factory AuthResult.pending() {
    return AuthResult._(success: false, isPending: true);
  }
}
```

### Auth Provider for State Management

```dart
// lib/providers/auth_provider.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import 'dart:async';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  emailVerificationRequired,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService.instance;
  
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _error;
  StreamSubscription<AuthState>? _authSubscription;
  
  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  
  AuthProvider() {
    _init();
  }
  
  void _init() {
    // Check initial auth state
    _user = _authService.currentUser;
    _status = _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    
    // Listen to auth state changes
    _authSubscription = _authService.authStateChanges.listen((AuthState state) {
      _handleAuthStateChange(state);
    });
  }
  
  void _handleAuthStateChange(AuthState state) {
    switch (state.event) {
      case AuthChangeEvent.signedIn:
        _user = state.session?.user;
        _status = AuthStatus.authenticated;
        _error = null;
        break;
      case AuthChangeEvent.signedOut:
        _user = null;
        _status = AuthStatus.unauthenticated;
        break;
      case AuthChangeEvent.userUpdated:
        _user = state.session?.user;
        break;
      case AuthChangeEvent.passwordRecovery:
        // Handle password recovery flow
        break;
      default:
        break;
    }
    notifyListeners();
  }
  
  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    
    final result = await _authService.signUp(
      email: email,
      password: password,
      username: username,
    );
    
    if (result.success) {
      if (result.requiresEmailVerification) {
        _status = AuthStatus.emailVerificationRequired;
      } else {
        _user = result.user;
        _status = AuthStatus.authenticated;
      }
      notifyListeners();
      return true;
    } else {
      _error = result.error;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    
    final result = await _authService.signIn(
      email: email,
      password: password,
    );
    
    if (result.success) {
      _user = result.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _error = result.error;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> signInWithGoogle() async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    
    final result = await _authService.signInWithGoogle();
    
    if (result.isPending) {
      // OAuth flow in progress, will complete via deep link
      return true;
    }
    
    if (!result.success) {
      _error = result.error;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
    
    return true;
  }
  
  Future<bool> sendPasswordResetEmail(String email) async {
    _error = null;
    
    final result = await _authService.sendPasswordResetEmail(email);
    
    if (!result.success) {
      _error = result.error;
      notifyListeners();
      return false;
    }
    
    return true;
  }
  
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
```

### Splash Screen (Initial Route)

```dart
// lib/pages/splash_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SplashPage extends StatefulWidget {
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }
  
  Future<void> _checkAuthAndNavigate() async {
    // Small delay to show splash screen
    await Future.delayed(Duration(milliseconds: 1500));
    
    if (!mounted) return;
    
    final authProvider = context.read<AuthProvider>();
    
    if (authProvider.isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/timetable');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.school,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Lecture Tracker',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Track your attendance, build your streak',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 48),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Login Page

```dart
// lib/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _rememberMe = false;
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40),
                
                // Header
                _buildHeader(),
                SizedBox(height: 48),
                
                // Error message
                Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    if (auth.error != null) {
                      return _buildErrorBanner(auth.error!);
                    }
                    return SizedBox.shrink();
                  },
                ),
                
                // Email field
                _buildEmailField(),
                SizedBox(height: 16),
                
                // Password field
                _buildPasswordField(),
                SizedBox(height: 8),
                
                // Remember me & Forgot password row
                _buildOptionsRow(),
                SizedBox(height: 24),
                
                // Login button
                _buildLoginButton(),
                SizedBox(height: 16),
                
                // Divider
                _buildDivider(),
                SizedBox(height: 16),
                
                // Social login buttons
                _buildGoogleButton(),
                SizedBox(height: 32),
                
                // Sign up link
                _buildSignUpLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Sign in to continue tracking your lectures',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildErrorBanner(String error) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18),
            onPressed: () => context.read<AuthProvider>().clearError(),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Enter your email',
        prefixIcon: Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }
  
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleLogin(),
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        prefixIcon: Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }
  
  Widget _buildOptionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() => _rememberMe = value ?? false);
                },
              ),
            ),
            SizedBox(width: 8),
            Text('Remember me'),
          ],
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
          child: Text('Forgot Password?'),
        ),
      ],
    );
  }
  
  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: auth.isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: auth.isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Sign In',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        );
      },
    );
  }
  
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or continue with',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        Expanded(child: Divider()),
      ],
    );
  }
  
  Widget _buildGoogleButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return SizedBox(
          height: 56,
          child: OutlinedButton(
            onPressed: auth.isLoading ? null : _handleGoogleSignIn,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Google logo placeholder - use actual Google logo asset
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'G',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Text('Continue with Google'),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account? "),
        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/signup'),
          child: Text(
            'Sign Up',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
  
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = context.read<AuthProvider>();
    
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/timetable');
    }
  }
  
  Future<void> _handleGoogleSignIn() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.signInWithGoogle();
    // Navigation handled by auth state listener
  }
}
```

### Sign Up Page

```dart
// lib/pages/signup_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  
  // Password strength
  double _passwordStrength = 0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.grey;
  
  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);
  }
  
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  void _updatePasswordStrength() {
    final password = _passwordController.text;
    double strength = 0;
    
    if (password.length >= 6) strength += 0.2;
    if (password.length >= 8) strength += 0.1;
    if (password.length >= 12) strength += 0.1;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.1;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.15;
    
    setState(() {
      _passwordStrength = strength.clamp(0.0, 1.0);
      
      if (_passwordStrength < 0.3) {
        _passwordStrengthText = 'Weak';
        _passwordStrengthColor = Colors.red;
      } else if (_passwordStrength < 0.6) {
        _passwordStrengthText = 'Fair';
        _passwordStrengthColor = Colors.orange;
      } else if (_passwordStrength < 0.8) {
        _passwordStrengthText = 'Good';
        _passwordStrengthColor = Colors.lightGreen;
      } else {
        _passwordStrengthText = 'Strong';
        _passwordStrengthColor = Colors.green;
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                _buildHeader(),
                SizedBox(height: 32),
                
                // Error message
                Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    if (auth.error != null) {
                      return _buildErrorBanner(auth.error!);
                    }
                    return SizedBox.shrink();
                  },
                ),
                
                // Username field
                _buildUsernameField(),
                SizedBox(height: 16),
                
                // Email field
                _buildEmailField(),
                SizedBox(height: 16),
                
                // Password field
                _buildPasswordField(),
                SizedBox(height: 8),
                
                // Password strength indicator
                if (_passwordController.text.isNotEmpty)
                  _buildPasswordStrengthIndicator(),
                SizedBox(height: 16),
                
                // Confirm password field
                _buildConfirmPasswordField(),
                SizedBox(height: 16),
                
                // Terms checkbox
                _buildTermsCheckbox(),
                SizedBox(height: 24),
                
                // Sign up button
                _buildSignUpButton(),
                SizedBox(height: 16),
                
                // Divider
                _buildDivider(),
                SizedBox(height: 16),
                
                // Google sign up
                _buildGoogleButton(),
                SizedBox(height: 32),
                
                // Login link
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Start tracking your lecture attendance today',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildErrorBanner(String error) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(error, style: TextStyle(color: Colors.red.shade700)),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18),
            onPressed: () => context.read<AuthProvider>().clearError(),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Username',
        hintText: 'Choose a unique username',
        prefixIcon: Icon(Icons.person_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a username';
        }
        if (value.length < 3) {
          return 'Username must be at least 3 characters';
        }
        if (value.length > 20) {
          return 'Username must be less than 20 characters';
        }
        if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
          return 'Username can only contain letters, numbers, and underscores';
        }
        return null;
      },
    );
  }
  
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Enter your university email',
        prefixIcon: Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }
  
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Create a strong password',
        prefixIcon: Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }
  
  Widget _buildPasswordStrengthIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _passwordStrength,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
                  minHeight: 6,
                ),
              ),
            ),
            SizedBox(width: 12),
            Text(
              _passwordStrengthText,
              style: TextStyle(
                color: _passwordStrengthColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          'Use 8+ characters with uppercase, numbers & symbols',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
  
  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        hintText: 'Re-enter your password',
        prefixIcon: Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        }
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }
  
  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: (value) {
              setState(() => _agreeToTerms = value ?? false);
            },
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              children: [
                TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms of Service',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _showTermsDialog(),
                ),
                TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _showPrivacyDialog(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSignUpButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: (auth.isLoading || !_agreeToTerms) ? null : _handleSignUp,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: auth.isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Create Account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        );
      },
    );
  }
  
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Or sign up with', style: TextStyle(color: Colors.grey)),
        ),
        Expanded(child: Divider()),
      ],
    );
  }
  
  Widget _buildGoogleButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return SizedBox(
          height: 56,
          child: OutlinedButton(
            onPressed: auth.isLoading ? null : _handleGoogleSignUp,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'G',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Text('Continue with Google'),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already have an account? '),
        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          child: Text(
            'Sign In',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
  
  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please agree to the Terms of Service')),
      );
      return;
    }
    
    final authProvider = context.read<AuthProvider>();
    
    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      username: _usernameController.text.trim(),
    );
    
    if (success && mounted) {
      if (authProvider.status == AuthStatus.emailVerificationRequired) {
        _showEmailVerificationDialog();
      } else {
        Navigator.pushReplacementNamed(context, '/timetable');
      }
    }
  }
  
  Future<void> _handleGoogleSignUp() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.signInWithGoogle();
  }
  
  void _showEmailVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.email, color: Theme.of(context).primaryColor),
            SizedBox(width: 8),
            Text('Verify Your Email'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'We\'ve sent a verification link to:',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              _emailController.text,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Please check your inbox and click the link to verify your account.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text('Go to Login'),
          ),
        ],
      ),
    );
  }
  
  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Terms of Service'),
        content: SingleChildScrollView(
          child: Text('Your terms of service content here...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Text('Your privacy policy content here...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
```

### Forgot Password Page

```dart
// lib/pages/forgot_password_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  bool _emailSent = false;
  bool _isLoading = false;
  
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: _emailSent ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }
  
  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 20),
          
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_reset,
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 24),
          
          // Header
          Text(
            'Forgot Password?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Enter your email address and we\'ll send you a link to reset your password.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          
          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 24),
          
          // Submit button
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleResetPassword,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Send Reset Link',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          SizedBox(height: 24),
          
          // Back to login
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Back to Login'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 40),
        
        // Success icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mark_email_read,
            size: 50,
            color: Colors.green,
          ),
        ),
        SizedBox(height: 32),
        
        Text(
          'Check Your Email',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Text(
          'We\'ve sent a password reset link to:',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          _emailController.text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32),
        
        // Instructions
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInstructionItem(
                '1',
                'Check your email inbox',
              ),
              SizedBox(height: 12),
              _buildInstructionItem(
                '2',
                'Click the reset password link',
              ),
              SizedBox(height: 12),
              _buildInstructionItem(
                '3',
                'Create your new password',
              ),
            ],
          ),
        ),
        SizedBox(height: 32),
        
        // Didn't receive email
        Text(
          'Didn\'t receive the email?',
          style: TextStyle(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        TextButton(
          onPressed: _handleResetPassword,
          child: Text('Resend Email'),
        ),
        SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text('Back to Login'),
        ),
      ],
    );
  }
  
  Widget _buildInstructionItem(String number, String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Text(text),
      ],
    );
  }
  
  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendPasswordResetEmail(
      _emailController.text.trim(),
    );
    
    setState(() => _isLoading = false);
    
    if (success) {
      setState(() => _emailSent = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Failed to send reset email'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

### Router Configuration with Auth Guards

```dart
// lib/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/splash_page.dart';
import '../pages/login_page.dart';
import '../pages/signup_page.dart';
import '../pages/forgot_password_page.dart';
import '../pages/home_page.dart';
import '../pages/profile_page.dart';
import '../pages/settings_page.dart';
import '../pages/timetable_page.dart';
import '../pages/checkin_page.dart';
import '../pages/friends_page.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();
  
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    
    // Redirect logic for auth
    redirect: (context, state) {
      final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/';
      
      // If not logged in and trying to access protected route
      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }
      
      // If logged in and trying to access auth routes (except splash)
      if (isLoggedIn && isAuthRoute && state.matchedLocation != '/') {
        return '/timetable';
      }
      
      return null; // No redirect
    },
    
    // Listen to auth state changes
    refreshListenable: GoRouterRefreshStream(
      Supabase.instance.client.auth.onAuthStateChange,
    ),
    
    routes: [
      // Splash screen
      GoRoute(
        path: '/',
        builder: (context, state) => SplashPage(),
      ),
      
      // Auth routes
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => SignUpPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => ForgotPasswordPage(),
      ),
      
      // Main app with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => HomePage(child: child),
        routes: [
          GoRoute(
            path: '/profile',
            builder: (context, state) => ProfilePage(),
            routes: [
              GoRoute(
                path: 'settings',
                builder: (context, state) => SettingsPage(),
              ),
            ],
          ),
          GoRoute(
            path: '/timetable',
            builder: (context, state) => TimetablePage(),
          ),
          GoRoute(
            path: '/checkin',
            builder: (context, state) => CheckInPage(),
          ),
          GoRoute(
            path: '/friends',
            builder: (context, state) => FriendsLeaderboardPage(),
          ),
        ],
      ),
    ],
    
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
}

/// Helper class to refresh GoRouter when auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    stream.listen((_) => notifyListeners());
  }
}
```

### Updated Main with Auth Provider

```dart
// lib/main2.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/timetable_provider.dart';
import 'providers/checkin_provider.dart';
import 'providers/friends_provider.dart';
import 'router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions: FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => TimetableProvider()),
        ChangeNotifierProvider(create: (_) => CheckInProvider()),
        ChangeNotifierProvider(create: (_) => FriendsProvider()),
      ],
      child: MaterialApp.router(
        title: 'Lecture Tracker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
```

### Supabase Configuration for Auth

Add these settings in your Supabase Dashboard:

#### Authentication Settings (Authentication → Settings)

1. **Email Settings**:
    - Enable "Enable Email Signup"
    - Enable "Confirm Email" (recommended for production)
    - Set "Email OTP Expiration" to 3600 seconds

2. **Email Templates** (Authentication → Email Templates):

   **Confirm Signup Email:**
   ```html
   <h2>Confirm your signup</h2>
   <p>Hi {{ .Email }},</p>
   <p>Welcome to Lecture Tracker! Click the button below to confirm your email:</p>
   <a href="{{ .ConfirmationURL }}" style="background: #3b82f6; color: white; padding: 12px 24px; text-decoration: none; border-radius: 8px; display: inline-block;">Confirm Email</a>
   ```

   **Reset Password Email:**
   ```html
   <h2>Reset Your Password</h2>
   <p>Hi,</p>
   <p>Someone requested a password reset for your Lecture Tracker account. Click below to reset:</p>
   <a href="{{ .ConfirmationURL }}" style="background: #3b82f6; color: white; padding: 12px 24px; text-decoration: none; border-radius: 8px; display: inline-block;">Reset Password</a>
   <p>If you didn't request this, you can ignore this email.</p>
   ```

3. **URL Configuration** (Authentication → URL Configuration):
    - Site URL: `io.supabase.lecturetracker://login-callback`
    - Redirect URLs: Add all of these:
        - `io.supabase.lecturetracker://login-callback`
        - `io.supabase.lecturetracker://reset-password`
        - `http://localhost:3000/auth/callback` (for web development)

4. **External OAuth Providers** (Authentication → Providers):

   For Google Sign-In:
    - Enable Google provider
    - Add your Google OAuth credentials (from Google Cloud Console)
    - Set callback URL as shown in Supabase

### Database Function for Account Deletion

```sql
-- Function to delete user account and all related data
CREATE OR REPLACE FUNCTION delete_user_account()
RETURNS VOID AS $$
DECLARE
  v_user_id UUID;
BEGIN
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;
  
  -- Delete all user data (cascades handle most of it)
  DELETE FROM public.profiles WHERE id = v_user_id;
  
  -- Note: The actual auth.users deletion requires admin privileges
  -- In production, use a Supabase Edge Function with service_role key
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## Page Implementations

### 1. Profile Page (`/profile`)

#### Layout Structure
```
ProfilePage
├── AppBar (with settings icon button)
├── Body
│   ├── ProfileHeader
│   │   ├── Avatar/Profile Picture
│   │   ├── Username
│   │   └── University ID
│   ├── StatsCard
│   │   ├── Current Streak (with fire icon)
│   │   ├── Total Points
│   │   └── Streak Freezes Available
│   ├── AttendanceStatsSection
│   │   ├── This Week: X/Y lectures attended
│   │   ├── This Month: X/Y lectures attended
│   │   ├── Overall Attendance Rate: XX%
│   │   └── MiniChart (showing last 30 days)
│   └── QuickActions
│       ├── View Achievements
│       ├── Attendance History
│       └── Settings
```

#### Implementation Details
```dart
class ProfilePage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/profile/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ProfileHeader(),
            SizedBox(height: 20),
            StatsCard(),
            SizedBox(height: 20),
            AttendanceStatsSection(),
            SizedBox(height: 20),
            QuickActionsGrid(),
          ],
        ),
      ),
    );
  }
}
```

#### Data Requirements
- Fetch user profile from Supabase `profiles` table
- Get current streak from `streaks` table
- Calculate attendance statistics from `attendance` table
- Get total points from `points` table

#### StatsCard Component
```dart
class StatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              icon: Icons.local_fire_department,
              iconColor: Colors.orange,
              value: '${streak.currentStreak}',
              label: 'Day Streak',
            ),
            _StatItem(
              icon: Icons.star,
              iconColor: Colors.amber,
              value: '${points.totalPoints}',
              label: 'Points',
            ),
            _StatItem(
              icon: Icons.ac_unit,
              iconColor: Colors.blue,
              value: '${streak.freezes}',
              label: 'Freezes',
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2. Settings Page (`/profile/settings`)

#### Layout Structure
```
SettingsPage
├── AppBar (with back button)
├── Body
│   ├── AccountSection
│   │   ├── Email (read-only)
│   │   ├── Username (editable)
│   │   ├── Change Password
│   │   └── Link/Update Timetable
│   ├── AppearanceSection
│   │   ├── Theme Toggle (Light/Dark/System)
│   │   └── Color Accent Selector
│   ├── NotificationSection
│   │   ├── Lecture Reminders Toggle
│   │   ├── Reminder Time Before Lecture
│   │   └── Friend Request Notifications
│   ├── AppLockSection
│   │   ├── Enable App Locking Toggle
│   │   └── Manage Allowed Apps
│   └── DangerZone
│       ├── Clear Cache
│       ├── Sign Out
│       └── Delete Account
```

#### Implementation Details
```dart
class SettingsPage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          _SettingsSection(
            title: 'Account',
            children: [
              ListTile(
                title: Text('Email'),
                subtitle: Text(user.email),
                trailing: Icon(Icons.lock_outline, size: 20),
              ),
              ListTile(
                title: Text('Username'),
                subtitle: Text(user.username),
                trailing: Icon(Icons.edit),
                onTap: () => _showEditUsernameDialog(),
              ),
              ListTile(
                title: Text('Change Password'),
                trailing: Icon(Icons.chevron_right),
                onTap: () => _showChangePasswordDialog(),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Appearance',
            children: [
              ListTile(
                title: Text('Theme'),
                subtitle: Text(_getThemeText()),
                trailing: DropdownButton<ThemeMode>(
                  value: currentTheme,
                  items: [
                    DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                    DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                  ],
                  onChanged: (value) => _updateTheme(value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

#### SharedPreferences Keys
```dart
class SettingsKeys {
  static const String THEME_MODE = 'theme_mode';
  static const String NOTIFICATION_ENABLED = 'notifications_enabled';
  static const String REMINDER_TIME = 'reminder_time_minutes';
  static const String APP_LOCK_ENABLED = 'app_lock_enabled';
}
```

### 3. Timetable Page (`/timetable`)

#### Layout Structure
```
TimetablePage
├── AppBar (with week selector)
├── Body
│   ├── WeekView (default) / MonthView (optional)
│   │   ├── DayHeaders (Mon-Fri)
│   │   └── TimeSlots (8am-6pm)
│   │       └── LectureCards (positioned by time)
│   └── FloatingActionButton (Sync Timetable)
```

#### Implementation Details
```dart
class TimetablePage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timetable'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_view_week),
            onPressed: () => _toggleViewMode(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: WeekSelector(
            currentWeek: selectedWeek,
            onWeekChanged: (week) => setState(() => selectedWeek = week),
          ),
        ),
      ),
      body: WeekViewCalendar(
        lectures: weekLectures,
        onLectureTap: (lecture) => _showLectureDetails(lecture),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.sync),
        onPressed: () => _syncTimetable(),
      ),
    );
  }
}
```

#### Calendar Component (Week View)
```dart
class WeekViewCalendar extends StatelessWidget {
  final List<Lecture> lectures;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Day headers
        Container(
          height: 40,
          child: Row(
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']
                .map((day) => Expanded(
                  child: Center(
                    child: Text(day, style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ))
                .toList(),
          ),
        ),
        // Time slots and lectures
        Expanded(
          child: SingleChildScrollView(
            child: Stack(
              children: [
                // Time indicators (8am - 6pm)
                _buildTimeIndicators(),
                // Lecture cards positioned absolutely
                ..._buildLectureCards(lectures),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  List<Widget> _buildLectureCards(List<Lecture> lectures) {
    return lectures.map((lecture) {
      final dayIndex = lecture.startTime.weekday - 1;
      final startMinutes = lecture.startTime.hour * 60 + lecture.startTime.minute;
      final duration = lecture.endTime.difference(lecture.startTime).inMinutes;
      
      return Positioned(
        left: (MediaQuery.of(context).size.width / 5) * dayIndex,
        top: (startMinutes - 480) * 2, // 480 = 8am in minutes
        width: MediaQuery.of(context).size.width / 5 - 4,
        height: duration * 2,
        child: LectureCard(lecture: lecture),
      );
    }).toList();
  }
}
```

#### Lecture Card
```dart
class LectureCard extends StatelessWidget {
  final Lecture lecture;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getLectureColor(lecture),
      child: InkWell(
        onTap: () => _showLectureDetails(lecture),
        child: Padding(
          padding: EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lecture.moduleCode,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                lecture.title,
                style: TextStyle(fontSize: 10),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Spacer(),
              Row(
                children: [
                  Icon(Icons.location_on, size: 10),
                  SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      lecture.location,
                      style: TextStyle(fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getLectureColor(Lecture lecture) {
    // Check if attended
    if (lecture.attended) return Colors.green.shade100;
    // Check if missed
    if (lecture.endTime.isBefore(DateTime.now())) return Colors.red.shade100;
    // Upcoming
    return Colors.blue.shade100;
  }
}
```

### 4. Current Lecture Page (`/checkin`)

#### Layout Structure
```
CurrentLecturePage
├── AppBar
├── Body (Conditional based on state)
│   ├── IF current lecture exists:
│   │   ├── CurrentLectureCard
│   │   │   ├── Module Code & Title
│   │   │   ├── Time (Start - End)
│   │   │   ├── Location
│   │   │   └── Distance from location
│   │   ├── CheckInButton (large, prominent)
│   │   └── AppLockSettings
│   │       └── Selected apps to keep unlocked
│   ├── ELSE IF no current lecture:
│   │   ├── NoLectureMessage
│   │   └── NextLectureCard
│   │       ├── Time until next lecture
│   │       └── Lecture details
│   └── IF checked in:
│       ├── CheckedInConfirmation
│       ├── Timer (showing remaining time)
│       └── BreakLockButton (with warning)
```

#### Implementation States
```dart
enum CheckInState {
  noLecture,
  readyToCheckIn,
  checkingIn,
  checkedIn,
  lectureEnded,
}
```

#### Implementation Details
```dart
class CurrentLecturePage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    final checkInProvider = Provider.of<CheckInProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Check In'),
      ),
      body: _buildBody(checkInProvider.state),
    );
  }
  
  Widget _buildBody(CheckInState state) {
    switch (state) {
      case CheckInState.noLecture:
        return _NoLectureView();
      case CheckInState.readyToCheckIn:
        return _ReadyToCheckInView();
      case CheckInState.checkingIn:
        return _CheckingInView();
      case CheckInState.checkedIn:
        return _CheckedInView();
      case CheckInState.lectureEnded:
        return _LectureEndedView();
    }
  }
}
```

#### Ready to Check In View
```dart
class _ReadyToCheckInView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lecture = context.watch<CheckInProvider>().currentLecture;
    final distance = context.watch<LocationProvider>().distanceToLecture;
    
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Current Lecture Card
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.book, color: Theme.of(context).primaryColor),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lecture.moduleCode,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              lecture.title,
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '${DateFormat('HH:mm').format(lecture.startTime)} - ${DateFormat('HH:mm').format(lecture.endTime)}',
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16),
                      SizedBox(width: 4),
                      Expanded(child: Text(lecture.location)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.navigation, size: 16),
                      SizedBox(width: 4),
                      Text(
                        distance != null 
                          ? '${distance.toStringAsFixed(0)}m away'
                          : 'Calculating distance...',
                        style: TextStyle(
                          color: distance != null && distance <= 50
                            ? Colors.green
                            : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 32),
          
          // Check In Button
          Container(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: distance != null && distance <= 50
                ? () => context.read<CheckInProvider>().checkIn()
                : null,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                distance != null && distance <= 50
                  ? 'CHECK IN'
                  : 'Move closer to check in',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          
          SizedBox(height: 24),
          
          // App Lock Settings
          Card(
            child: ExpansionTile(
              title: Text('App Lock Settings'),
              subtitle: Text('Apps will be locked during lecture'),
              children: [
                SwitchListTile(
                  title: Text('Enable App Lock'),
                  value: appLockEnabled,
                  onChanged: (value) => _toggleAppLock(value),
                ),
                if (appLockEnabled)
                  ListTile(
                    title: Text('Manage Allowed Apps'),
                    subtitle: Text('${allowedApps.length} apps allowed'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () => _showAppSelector(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

#### Checked In View
```dart
class _CheckedInView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final endTime = context.watch<CheckInProvider>().currentLecture.endTime;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 100,
            color: Colors.green,
          ),
          SizedBox(height: 24),
          Text(
            'Checked In Successfully!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'Your apps are locked until the lecture ends',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 32),
          StreamBuilder<int>(
            stream: _getRemainingTimeStream(endTime),
            builder: (context, snapshot) {
              final minutes = snapshot.data ?? 0;
              return Column(
                children: [
                  Text(
                    'Time Remaining',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    '${minutes ~/ 60}h ${minutes % 60}m',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 48),
          TextButton(
            onPressed: () => _showBreakLockWarning(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Emergency: Break Lock'),
          ),
        ],
      ),
    );
  }
}
```

### 5. Friends & Leaderboard Page (`/friends`)

#### Layout Structure
```
FriendsLeaderboardPage
├── AppBar (with add friend button)
├── TabBar
│   ├── Friends Tab
│   └── Leaderboard Tab
├── TabBarView
│   ├── FriendsView
│   │   ├── Friend Requests Section (if any)
│   │   └── Friends List
│   │       └── FriendCard (avatar, name, points, streak)
│   └── LeaderboardView
│       ├── Toggle (Global/Friends)
│       └── LeaderboardList
│           └── LeaderboardEntry (rank, user, points)
```

#### Implementation Details
```dart
class FriendsLeaderboardPage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Friends & Leaderboard'),
          actions: [
            IconButton(
              icon: Icon(Icons.person_add),
              onPressed: () => _showAddFriendDialog(),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Friends'),
              Tab(text: 'Leaderboard'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FriendsView(),
            LeaderboardView(),
          ],
        ),
      ),
    );
  }
}
```

#### Friends View
```dart
class FriendsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final friendsProvider = Provider.of<FriendsProvider>(context);
    
    return RefreshIndicator(
      onRefresh: () => friendsProvider.refreshFriends(),
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Friend Requests Section
          if (friendsProvider.pendingRequests.isNotEmpty) ...[
            Text(
              'Friend Requests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ...friendsProvider.pendingRequests.map((request) =>
              FriendRequestCard(request: request),
            ),
            SizedBox(height: 24),
          ],
          
          // Friends List
          Text(
            'My Friends (${friendsProvider.friends.length})',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          if (friendsProvider.friends.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No friends yet'),
                  TextButton(
                    onPressed: () => _showAddFriendDialog(),
                    child: Text('Add Friends'),
                  ),
                ],
              ),
            )
          else
            ...friendsProvider.friends.map((friend) =>
              FriendCard(friend: friend),
            ),
        ],
      ),
    );
  }
}
```

#### Friend Card Component
```dart
class FriendCard extends StatelessWidget {
  final Friend friend;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: friend.avatarUrl != null
            ? NetworkImage(friend.avatarUrl!)
            : null,
          child: friend.avatarUrl == null
            ? Text(friend.username[0].toUpperCase())
            : null,
        ),
        title: Text(friend.username),
        subtitle: Row(
          children: [
            Icon(Icons.star, size: 14, color: Colors.amber),
            SizedBox(width: 4),
            Text('${friend.points} pts'),
            SizedBox(width: 16),
            Icon(Icons.local_fire_department, size: 14, color: Colors.orange),
            SizedBox(width: 4),
            Text('${friend.streak} days'),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'view',
              child: Text('View Profile'),
            ),
            PopupMenuItem(
              value: 'remove',
              child: Text('Remove Friend'),
            ),
          ],
          onSelected: (value) => _handleFriendAction(value, friend),
        ),
      ),
    );
  }
}
```

#### Leaderboard View
```dart
class LeaderboardView extends StatefulWidget {
  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  bool showGlobal = true;
  
  @override
  Widget build(BuildContext context) {
    final leaderboardProvider = Provider.of<LeaderboardProvider>(context);
    
    return Column(
      children: [
        // Toggle between Global and Friends
        Container(
          padding: EdgeInsets.all(16),
          child: SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: true, label: Text('Global')),
              ButtonSegment(value: false, label: Text('Friends')),
            ],
            selected: {showGlobal},
            onSelectionChanged: (Set<bool> selection) {
              setState(() => showGlobal = selection.first);
            },
          ),
        ),
        
        // Leaderboard List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => leaderboardProvider.refreshLeaderboard(showGlobal),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: leaderboardProvider.entries.length,
              itemBuilder: (context, index) {
                final entry = leaderboardProvider.entries[index];
                final isCurrentUser = entry.userId == currentUserId;
                
                return LeaderboardEntry(
                  rank: index + 1,
                  entry: entry,
                  isHighlighted: isCurrentUser,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
```

#### Leaderboard Entry Component
```dart
class LeaderboardEntry extends StatelessWidget {
  final int rank;
  final LeaderboardEntryModel entry;
  final bool isHighlighted;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isHighlighted 
          ? Theme.of(context).primaryColor.withOpacity(0.1)
          : null,
        border: isHighlighted
          ? Border.all(color: Theme.of(context).primaryColor, width: 2)
          : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getRankColor(rank),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          entry.username,
          style: TextStyle(
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text('${entry.attendanceRate}% attendance'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${entry.points}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'points',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1: return Colors.amber;
      case 2: return Colors.grey;
      case 3: return Colors.brown;
      default: return Colors.blue;
    }
  }
}
```

---

## Data Models

All models include `fromJson`, `toJson`, and `copyWith` methods for complete Supabase integration. Models are organized in `lib/models/` directory.

### User Model

```dart
// lib/models/user.dart

import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String username;
  final String? universityId;
  final String? avatarUrl;
  final String? icalUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const User({
    required this.id,
    required this.email,
    required this.username,
    this.universityId,
    this.avatarUrl,
    this.icalUrl,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      universityId: json['university_id'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      icalUrl: json['ical_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'university_id': universityId,
      'avatar_url': avatarUrl,
      'ical_url': icalUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  User copyWith({
    String? id,
    String? email,
    String? username,
    String? universityId,
    String? avatarUrl,
    String? icalUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      universityId: universityId ?? this.universityId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      icalUrl: icalUrl ?? this.icalUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// Get user's initials for avatar placeholder
  String get initials {
    if (username.isEmpty) return '?';
    final parts = username.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return username[0].toUpperCase();
  }
  
  @override
  List<Object?> get props => [id, email, username, universityId, avatarUrl, icalUrl, createdAt, updatedAt];
}
```

### Timetable Model

```dart
// lib/models/timetable.dart

import 'package:equatable/equatable.dart';

class Timetable extends Equatable {
  final String id;
  final String userId;
  final String name;
  final TimetableSource source;
  final DateTime? lastSyncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const Timetable({
    required this.id,
    required this.userId,
    required this.name,
    required this.source,
    this.lastSyncedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Timetable.fromJson(Map<String, dynamic> json) {
    return Timetable(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      source: TimetableSource.fromString(json['source'] as String? ?? 'manual'),
      lastSyncedAt: json['last_synced_at'] != null 
          ? DateTime.parse(json['last_synced_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'source': source.value,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  Timetable copyWith({
    String? id,
    String? userId,
    String? name,
    TimetableSource? source,
    DateTime? lastSyncedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Timetable(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      source: source ?? this.source,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// Check if timetable needs syncing (older than 24 hours)
  bool get needsSync {
    if (source == TimetableSource.manual) return false;
    if (lastSyncedAt == null) return true;
    return DateTime.now().difference(lastSyncedAt!).inHours >= 24;
  }
  
  @override
  List<Object?> get props => [id, userId, name, source, lastSyncedAt, createdAt, updatedAt];
}

enum TimetableSource {
  manual('manual'),
  ical('ical'),
  universityApi('university_api');
  
  final String value;
  const TimetableSource(this.value);
  
  static TimetableSource fromString(String value) {
    return TimetableSource.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TimetableSource.manual,
    );
  }
}
```

### Lecture Model

```dart
// lib/models/lecture.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Lecture extends Equatable {
  final String id;
  final String timetableId;
  final String? externalId; // UID from iCal
  final String title;
  final String moduleCode;
  final String location;
  final double latitude;
  final double longitude;
  final DateTime startTime;
  final DateTime endTime;
  final String? recurrenceRule;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const Lecture({
    required this.id,
    required this.timetableId,
    this.externalId,
    required this.title,
    required this.moduleCode,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.startTime,
    required this.endTime,
    this.recurrenceRule,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Lecture.fromJson(Map<String, dynamic> json) {
    return Lecture(
      id: json['id'] as String,
      timetableId: json['timetable_id'] as String,
      externalId: json['external_id'] as String?,
      title: json['title'] as String,
      moduleCode: json['module_code'] as String,
      location: json['location'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      recurrenceRule: json['recurrence_rule'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timetable_id': timetableId,
      'external_id': externalId,
      'title': title,
      'module_code': moduleCode,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'recurrence_rule': recurrenceRule,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  /// For inserting new lectures (without id and timestamps)
  Map<String, dynamic> toInsertJson() {
    return {
      'timetable_id': timetableId,
      'external_id': externalId,
      'title': title,
      'module_code': moduleCode,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'recurrence_rule': recurrenceRule,
    };
  }
  
  Lecture copyWith({
    String? id,
    String? timetableId,
    String? externalId,
    String? title,
    String? moduleCode,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? startTime,
    DateTime? endTime,
    String? recurrenceRule,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Lecture(
      id: id ?? this.id,
      timetableId: timetableId ?? this.timetableId,
      externalId: externalId ?? this.externalId,
      title: title ?? this.title,
      moduleCode: moduleCode ?? this.moduleCode,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  // Computed properties
  
  /// Check if lecture is currently active
  bool get isCurrentlyActive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }
  
  /// Check if lecture is upcoming
  bool get isUpcoming => DateTime.now().isBefore(startTime);
  
  /// Check if lecture has ended
  bool get isPast => DateTime.now().isAfter(endTime);
  
  /// Get lecture duration
  Duration get duration => endTime.difference(startTime);
  
  /// Get duration in minutes
  int get durationMinutes => duration.inMinutes;
  
  /// Get formatted time range (e.g., "09:00 - 10:00")
  String get timeRange {
    final startStr = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final endStr = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$startStr - $endStr';
  }
  
  /// Get day of week (1 = Monday, 7 = Sunday)
  int get dayOfWeek => startTime.weekday;
  
  /// Get color based on module code (consistent coloring)
  Color get color {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
    ];
    final hash = moduleCode.hashCode.abs();
    return colors[hash % colors.length];
  }
  
  /// Check if location has valid coordinates
  bool get hasValidCoordinates => latitude != 0.0 && longitude != 0.0;
  
  /// Time until lecture starts (null if already started or passed)
  Duration? get timeUntilStart {
    if (!isUpcoming) return null;
    return startTime.difference(DateTime.now());
  }
  
  /// Time remaining in lecture (null if not active)
  Duration? get timeRemaining {
    if (!isCurrentlyActive) return null;
    return endTime.difference(DateTime.now());
  }
  
  @override
  List<Object?> get props => [
    id, timetableId, externalId, title, moduleCode, location,
    latitude, longitude, startTime, endTime, recurrenceRule,
    createdAt, updatedAt
  ];
}

/// Lecture with attendance status (used in timetable view)
class LectureWithAttendance {
  final Lecture lecture;
  final bool attended;
  final String? attendanceId;
  final int? pointsEarned;
  
  const LectureWithAttendance({
    required this.lecture,
    required this.attended,
    this.attendanceId,
    this.pointsEarned,
  });
  
  factory LectureWithAttendance.fromJson(Map<String, dynamic> json) {
    final lecture = Lecture.fromJson(json);
    final attendanceList = json['attendance'] as List?;
    final hasAttendance = attendanceList != null && attendanceList.isNotEmpty;
    
    return LectureWithAttendance(
      lecture: lecture,
      attended: hasAttendance,
      attendanceId: hasAttendance ? attendanceList!.first['id'] as String : null,
      pointsEarned: hasAttendance ? attendanceList!.first['points_earned'] as int? : null,
    );
  }
  
  /// Get status for UI display
  LectureStatus get status {
    if (attended) return LectureStatus.attended;
    if (lecture.isPast) return LectureStatus.missed;
    if (lecture.isCurrentlyActive) return LectureStatus.inProgress;
    return LectureStatus.upcoming;
  }
}

enum LectureStatus {
  upcoming,
  inProgress,
  attended,
  missed,
}
```

### Attendance Model

```dart
// lib/models/attendance.dart

import 'package:equatable/equatable.dart';
import 'lecture.dart';

class Attendance extends Equatable {
  final String id;
  final String userId;
  final String lectureId;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final bool locationVerified;
  final bool appsLocked;
  final bool lockBroken;
  final int pointsEarned;
  final DateTime createdAt;
  final Lecture? lecture; // Optionally populated via join
  
  const Attendance({
    required this.id,
    required this.userId,
    required this.lectureId,
    required this.checkInTime,
    this.checkOutTime,
    required this.locationVerified,
    required this.appsLocked,
    required this.lockBroken,
    required this.pointsEarned,
    required this.createdAt,
    this.lecture,
  });
  
  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      lectureId: json['lecture_id'] as String,
      checkInTime: DateTime.parse(json['check_in_time'] as String),
      checkOutTime: json['check_out_time'] != null 
          ? DateTime.parse(json['check_out_time'] as String)
          : null,
      locationVerified: json['location_verified'] as bool? ?? false,
      appsLocked: json['apps_locked'] as bool? ?? false,
      lockBroken: json['lock_broken'] as bool? ?? false,
      pointsEarned: json['points_earned'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      lecture: json['lectures'] != null 
          ? Lecture.fromJson(json['lectures'] as Map<String, dynamic>)
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'lecture_id': lectureId,
      'check_in_time': checkInTime.toIso8601String(),
      'check_out_time': checkOutTime?.toIso8601String(),
      'location_verified': locationVerified,
      'apps_locked': appsLocked,
      'lock_broken': lockBroken,
      'points_earned': pointsEarned,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  /// For creating new attendance records
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'lecture_id': lectureId,
      'check_in_time': checkInTime.toIso8601String(),
      'location_verified': locationVerified,
      'apps_locked': appsLocked,
      'points_earned': pointsEarned,
    };
  }
  
  Attendance copyWith({
    String? id,
    String? userId,
    String? lectureId,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    bool? locationVerified,
    bool? appsLocked,
    bool? lockBroken,
    int? pointsEarned,
    DateTime? createdAt,
    Lecture? lecture,
  }) {
    return Attendance(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lectureId: lectureId ?? this.lectureId,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      locationVerified: locationVerified ?? this.locationVerified,
      appsLocked: appsLocked ?? this.appsLocked,
      lockBroken: lockBroken ?? this.lockBroken,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      createdAt: createdAt ?? this.createdAt,
      lecture: lecture ?? this.lecture,
    );
  }
  
  /// Check if attendance session is still active
  bool get isActive => checkOutTime == null;
  
  /// Get session duration
  Duration get sessionDuration {
    final end = checkOutTime ?? DateTime.now();
    return end.difference(checkInTime);
  }
  
  /// Check if full points were earned
  bool get earnedFullPoints => !lockBroken && locationVerified;
  
  @override
  List<Object?> get props => [
    id, userId, lectureId, checkInTime, checkOutTime,
    locationVerified, appsLocked, lockBroken, pointsEarned, createdAt
  ];
}

/// Daily attendance summary for charts
class DailyAttendance {
  final DateTime date;
  final int lecturesAttended;
  final int totalLectures;
  
  const DailyAttendance({
    required this.date,
    required this.lecturesAttended,
    this.totalLectures = 0,
  });
  
  double get rate => totalLectures > 0 ? lecturesAttended / totalLectures : 0;
  
  String get dateKey {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Attendance statistics for profile/dashboard
class AttendanceStats {
  final int weeklyAttended;
  final int weeklyTotal;
  final int monthlyAttended;
  final int monthlyTotal;
  final int overallAttended;
  final int overallTotal;
  
  const AttendanceStats({
    required this.weeklyAttended,
    required this.weeklyTotal,
    required this.monthlyAttended,
    required this.monthlyTotal,
    required this.overallAttended,
    required this.overallTotal,
  });
  
  factory AttendanceStats.empty() {
    return const AttendanceStats(
      weeklyAttended: 0,
      weeklyTotal: 0,
      monthlyAttended: 0,
      monthlyTotal: 0,
      overallAttended: 0,
      overallTotal: 0,
    );
  }
  
  double get weeklyRate => weeklyTotal > 0 ? weeklyAttended / weeklyTotal : 0;
  double get monthlyRate => monthlyTotal > 0 ? monthlyAttended / monthlyTotal : 0;
  double get overallRate => overallTotal > 0 ? overallAttended / overallTotal : 0;
  
  int get weeklyPercentage => (weeklyRate * 100).round();
  int get monthlyPercentage => (monthlyRate * 100).round();
  int get overallPercentage => (overallRate * 100).round();
}
```

### Streak Model

```dart
// lib/models/streak.dart

import 'package:equatable/equatable.dart';

class Streak extends Equatable {
  final String id;
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final int streakFreezes;
  final DateTime? lastAttendanceDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const Streak({
    required this.id,
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    required this.streakFreezes,
    this.lastAttendanceDate,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Streak.fromJson(Map<String, dynamic> json) {
    return Streak(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      streakFreezes: json['streak_freezes'] as int? ?? 0,
      lastAttendanceDate: json['last_attendance_date'] != null
          ? DateTime.parse(json['last_attendance_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'streak_freezes': streakFreezes,
      'last_attendance_date': lastAttendanceDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  Streak copyWith({
    String? id,
    String? userId,
    int? currentStreak,
    int? longestStreak,
    int? streakFreezes,
    DateTime? lastAttendanceDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Streak(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      streakFreezes: streakFreezes ?? this.streakFreezes,
      lastAttendanceDate: lastAttendanceDate ?? this.lastAttendanceDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// Check if user can use a streak freeze
  bool get canUseFreeze => streakFreezes > 0;
  
  /// Check if streak is at risk (no attendance today and not frozen)
  bool get isAtRisk {
    if (lastAttendanceDate == null) return currentStreak > 0;
    final today = DateTime.now();
    final lastDate = lastAttendanceDate!;
    return lastDate.year != today.year || 
           lastDate.month != today.month || 
           lastDate.day != today.day;
  }
  
  /// Check if this is a new personal best
  bool get isPersonalBest => currentStreak >= longestStreak && currentStreak > 0;
  
  /// Get streak status for UI
  StreakStatus get status {
    if (currentStreak == 0) return StreakStatus.none;
    if (isPersonalBest) return StreakStatus.personalBest;
    if (currentStreak >= 30) return StreakStatus.legendary;
    if (currentStreak >= 14) return StreakStatus.impressive;
    if (currentStreak >= 7) return StreakStatus.strong;
    return StreakStatus.building;
  }
  
  @override
  List<Object?> get props => [
    id, userId, currentStreak, longestStreak, streakFreezes,
    lastAttendanceDate, createdAt, updatedAt
  ];
}

enum StreakStatus {
  none,
  building,
  strong,
  impressive,
  legendary,
  personalBest,
}
```

### Points Model

```dart
// lib/models/points.dart

import 'package:equatable/equatable.dart';

class Points extends Equatable {
  final String id;
  final String userId;
  final int totalPoints;
  final int weeklyPoints;
  final int monthlyPoints;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const Points({
    required this.id,
    required this.userId,
    required this.totalPoints,
    required this.weeklyPoints,
    required this.monthlyPoints,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Points.fromJson(Map<String, dynamic> json) {
    return Points(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      totalPoints: json['total_points'] as int? ?? 0,
      weeklyPoints: json['weekly_points'] as int? ?? 0,
      monthlyPoints: json['monthly_points'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'total_points': totalPoints,
      'weekly_points': weeklyPoints,
      'monthly_points': monthlyPoints,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  Points copyWith({
    String? id,
    String? userId,
    int? totalPoints,
    int? weeklyPoints,
    int? monthlyPoints,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Points(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      totalPoints: totalPoints ?? this.totalPoints,
      weeklyPoints: weeklyPoints ?? this.weeklyPoints,
      monthlyPoints: monthlyPoints ?? this.monthlyPoints,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// Get rank tier based on total points
  PointsTier get tier {
    if (totalPoints >= 10000) return PointsTier.legendary;
    if (totalPoints >= 5000) return PointsTier.master;
    if (totalPoints >= 2000) return PointsTier.expert;
    if (totalPoints >= 500) return PointsTier.intermediate;
    if (totalPoints >= 100) return PointsTier.beginner;
    return PointsTier.newcomer;
  }
  
  /// Points needed for next tier
  int get pointsToNextTier {
    switch (tier) {
      case PointsTier.newcomer:
        return 100 - totalPoints;
      case PointsTier.beginner:
        return 500 - totalPoints;
      case PointsTier.intermediate:
        return 2000 - totalPoints;
      case PointsTier.expert:
        return 5000 - totalPoints;
      case PointsTier.master:
        return 10000 - totalPoints;
      case PointsTier.legendary:
        return 0; // Max tier
    }
  }
  
  @override
  List<Object?> get props => [
    id, userId, totalPoints, weeklyPoints, monthlyPoints, createdAt, updatedAt
  ];
}

enum PointsTier {
  newcomer('Newcomer', 0),
  beginner('Beginner', 100),
  intermediate('Intermediate', 500),
  expert('Expert', 2000),
  master('Master', 5000),
  legendary('Legendary', 10000);
  
  final String name;
  final int minPoints;
  
  const PointsTier(this.name, this.minPoints);
}
```

### Friendship Model

```dart
// lib/models/friendship.dart

import 'package:equatable/equatable.dart';
import 'user.dart';

class Friendship extends Equatable {
  final String id;
  final String userId;
  final String friendId;
  final FriendshipStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user; // The user who sent the request
  final User? friend; // The user who received the request
  
  const Friendship({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.friend,
  });
  
  factory Friendship.fromJson(Map<String, dynamic> json) {
    return Friendship(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      friendId: json['friend_id'] as String,
      status: FriendshipStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      user: json['user'] != null 
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      friend: json['friend'] != null 
          ? User.fromJson(json['friend'] as Map<String, dynamic>)
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'friend_id': friendId,
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  Friendship copyWith({
    String? id,
    String? userId,
    String? friendId,
    FriendshipStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
    User? friend,
  }) {
    return Friendship(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      friendId: friendId ?? this.friendId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      friend: friend ?? this.friend,
    );
  }
  
  bool get isPending => status == FriendshipStatus.pending;
  bool get isAccepted => status == FriendshipStatus.accepted;
  bool get isRejected => status == FriendshipStatus.rejected;
  
  @override
  List<Object?> get props => [id, userId, friendId, status, createdAt, updatedAt];
}

enum FriendshipStatus {
  pending('pending'),
  accepted('accepted'),
  rejected('rejected');
  
  final String value;
  const FriendshipStatus(this.value);
  
  static FriendshipStatus fromString(String value) {
    return FriendshipStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FriendshipStatus.pending,
    );
  }
}

/// Friend with stats for display in friends list
class FriendWithStats {
  final String id;
  final String username;
  final String? avatarUrl;
  final int currentStreak;
  final int totalPoints;
  final String friendshipId;
  
  const FriendWithStats({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.currentStreak,
    required this.totalPoints,
    required this.friendshipId,
  });
  
  factory FriendWithStats.fromJson(Map<String, dynamic> json, String friendshipId) {
    return FriendWithStats(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String?,
      currentStreak: (json['streaks'] as Map<String, dynamic>?)?['current_streak'] as int? ?? 0,
      totalPoints: (json['points'] as Map<String, dynamic>?)?['total_points'] as int? ?? 0,
      friendshipId: friendshipId,
    );
  }
  
  String get initials => username.isNotEmpty ? username[0].toUpperCase() : '?';
}

/// Friend request for pending requests view
class FriendRequest {
  final String id;
  final String senderId;
  final String senderUsername;
  final String? senderAvatarUrl;
  final DateTime createdAt;
  
  const FriendRequest({
    required this.id,
    required this.senderId,
    required this.senderUsername,
    this.senderAvatarUrl,
    required this.createdAt,
  });
  
  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] as Map<String, dynamic>;
    return FriendRequest(
      id: json['id'] as String,
      senderId: sender['id'] as String,
      senderUsername: sender['username'] as String,
      senderAvatarUrl: sender['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  
  String get initials => senderUsername.isNotEmpty ? senderUsername[0].toUpperCase() : '?';
  
  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }
}
```

### Leaderboard Model

```dart
// lib/models/leaderboard.dart

import 'package:equatable/equatable.dart';

class LeaderboardEntry extends Equatable {
  final int rank;
  final String userId;
  final String username;
  final String? avatarUrl;
  final int totalPoints;
  final int weeklyPoints;
  final int currentStreak;
  final double attendanceRate;
  final bool isCurrentUser;
  
  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.totalPoints,
    this.weeklyPoints = 0,
    this.currentStreak = 0,
    this.attendanceRate = 0,
    this.isCurrentUser = false,
  });
  
  factory LeaderboardEntry.fromJson(Map<String, dynamic> json, int rank, String? currentUserId) {
    final profile = json['profiles'] as Map<String, dynamic>;
    final streaks = json['streaks'] as Map<String, dynamic>?;
    
    return LeaderboardEntry(
      rank: rank,
      userId: profile['id'] as String,
      username: profile['username'] as String,
      avatarUrl: profile['avatar_url'] as String?,
      totalPoints: json['total_points'] as int? ?? 0,
      weeklyPoints: json['weekly_points'] as int? ?? 0,
      currentStreak: streaks?['current_streak'] as int? ?? 0,
      attendanceRate: 0, // Calculate separately if needed
      isCurrentUser: profile['id'] == currentUserId,
    );
  }
  
  LeaderboardEntry copyWith({
    int? rank,
    String? userId,
    String? username,
    String? avatarUrl,
    int? totalPoints,
    int? weeklyPoints,
    int? currentStreak,
    double? attendanceRate,
    bool? isCurrentUser,
  }) {
    return LeaderboardEntry(
      rank: rank ?? this.rank,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalPoints: totalPoints ?? this.totalPoints,
      weeklyPoints: weeklyPoints ?? this.weeklyPoints,
      currentStreak: currentStreak ?? this.currentStreak,
      attendanceRate: attendanceRate ?? this.attendanceRate,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }
  
  String get initials => username.isNotEmpty ? username[0].toUpperCase() : '?';
  
  /// Check if this is a podium position (top 3)
  bool get isPodium => rank <= 3;
  
  /// Get medal emoji for podium positions
  String? get medal {
    switch (rank) {
      case 1: return '🥇';
      case 2: return '🥈';
      case 3: return '🥉';
      default: return null;
    }
  }
  
  @override
  List<Object?> get props => [
    rank, userId, username, avatarUrl, totalPoints, 
    weeklyPoints, currentStreak, attendanceRate, isCurrentUser
  ];
}

/// Leaderboard type for filtering
enum LeaderboardType {
  global,
  friends,
  weekly,
  monthly,
}
```

### User Profile (Combined Model)

```dart
// lib/models/user_profile.dart

import 'user.dart';
import 'streak.dart';
import 'points.dart';
import 'attendance.dart';

/// Combined user profile with all related data
class UserProfile {
  final User user;
  final Streak streak;
  final Points points;
  final AttendanceStats? stats;
  final List<DailyAttendance>? attendanceHistory;
  
  const UserProfile({
    required this.user,
    required this.streak,
    required this.points,
    this.stats,
    this.attendanceHistory,
  });
  
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      user: User.fromJson(json),
      streak: Streak.fromJson(json['streaks'] as Map<String, dynamic>? ?? {
        'id': '',
        'user_id': json['id'],
        'current_streak': 0,
        'longest_streak': 0,
        'streak_freezes': 3,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }),
      points: Points.fromJson(json['points'] as Map<String, dynamic>? ?? {
        'id': '',
        'user_id': json['id'],
        'total_points': 0,
        'weekly_points': 0,
        'monthly_points': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }),
    );
  }
  
  UserProfile copyWith({
    User? user,
    Streak? streak,
    Points? points,
    AttendanceStats? stats,
    List<DailyAttendance>? attendanceHistory,
  }) {
    return UserProfile(
      user: user ?? this.user,
      streak: streak ?? this.streak,
      points: points ?? this.points,
      stats: stats ?? this.stats,
      attendanceHistory: attendanceHistory ?? this.attendanceHistory,
    );
  }
  
  // Convenience accessors
  String get username => user.username;
  String get email => user.email;
  String? get avatarUrl => user.avatarUrl;
  int get currentStreak => streak.currentStreak;
  int get longestStreak => streak.longestStreak;
  int get totalPoints => points.totalPoints;
  int get weeklyPoints => points.weeklyPoints;
  int get streakFreezes => streak.streakFreezes;
  
  /// Check if user has connected their timetable
  bool get hasTimetableConnected => user.icalUrl != null;
}
```

### Models Barrel File

```dart
// lib/models/models.dart

/// Export all models from a single file for easy imports

export 'user.dart';
export 'user_profile.dart';
export 'timetable.dart';
export 'lecture.dart';
export 'attendance.dart';
export 'streak.dart';
export 'points.dart';
export 'friendship.dart';
export 'leaderboard.dart';
```

### Usage Example

```dart
// Import all models with a single import
import 'package:lecture_tracker/models/models.dart';

// Using models with Supabase
final response = await supabase
    .from('profiles')
    .select('''
      *,
      streaks(*),
      points(*)
    ''')
    .eq('id', userId)
    .single();

final profile = UserProfile.fromJson(response);
print('Welcome ${profile.username}!');
print('Current streak: ${profile.currentStreak} days');
print('Total points: ${profile.totalPoints}');

// Creating a new attendance record
final attendance = Attendance(
  id: '', // Will be set by database
  userId: currentUser.id,
  lectureId: lecture.id,
  checkInTime: DateTime.now(),
  locationVerified: true,
  appsLocked: true,
  lockBroken: false,
  pointsEarned: 10,
  createdAt: DateTime.now(),
);

await supabase.from('attendance').insert(attendance.toInsertJson());
```

---

## State Management

### Provider Structure

#### CheckInProvider
```dart
class CheckInProvider extends ChangeNotifier {
  CheckInState _state = CheckInState.noLecture;
  Lecture? _currentLecture;
  Attendance? _currentAttendance;
  
  CheckInState get state => _state;
  Lecture? get currentLecture => _currentLecture;
  Attendance? get currentAttendance => _currentAttendance;
  
  Future<void> loadCurrentLecture() async {
    try {
      // Get current time lectures from Supabase
      final now = DateTime.now();
      final response = await supabase
          .from('lectures')
          .select()
          .lte('start_time', now.toIso8601String())
          .gte('end_time', now.toIso8601String())
          .single();
      
      if (response != null) {
        _currentLecture = Lecture.fromJson(response);
        _state = CheckInState.readyToCheckIn;
      } else {
        _state = CheckInState.noLecture;
        _loadNextLecture();
      }
      notifyListeners();
    } catch (e) {
      _state = CheckInState.noLecture;
      notifyListeners();
    }
  }
  
  Future<void> checkIn() async {
    if (_currentLecture == null) return;
    
    _state = CheckInState.checkingIn;
    notifyListeners();
    
    try {
      // Verify location
      final position = await Geolocator.getCurrentPosition();
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        _currentLecture!.latitude,
        _currentLecture!.longitude,
      );
      
      if (distance > 50) {
        throw Exception('Too far from lecture location');
      }
      
      // Create attendance record
      final attendance = await supabase
          .from('attendance')
          .insert({
            'user_id': supabase.auth.currentUser!.id,
            'lecture_id': _currentLecture!.id,
            'check_in_time': DateTime.now().toIso8601String(),
            'location_verified': true,
            'apps_locked': true,
            'points_earned': 10,
          })
          .select()
          .single();
      
      _currentAttendance = Attendance.fromJson(attendance);
      _state = CheckInState.checkedIn;
      
      // Start app lock
      await AppLockService.instance.startLock(_currentLecture!.endTime);
      
      // Update streak
      await _updateStreak();
      
      notifyListeners();
    } catch (e) {
      _state = CheckInState.readyToCheckIn;
      notifyListeners();
      throw e;
    }
  }
  
  Future<void> breakLock() async {
    if (_currentAttendance == null) return;
    
    // Update attendance record
    await supabase
        .from('attendance')
        .update({
          'lock_broken': true,
          'check_out_time': DateTime.now().toIso8601String(),
          'points_earned': 5, // Reduced points for breaking lock
        })
        .eq('id', _currentAttendance!.id);
    
    // Stop app lock
    await AppLockService.instance.stopLock();
    
    _state = CheckInState.lectureEnded;
    notifyListeners();
  }
}
```

#### TimetableProvider
```dart
class TimetableProvider extends ChangeNotifier {
  List<Lecture> _lectures = [];
  DateTime _selectedWeek = DateTime.now();
  bool _isLoading = false;
  
  List<Lecture> get lectures => _lectures;
  List<Lecture> get weekLectures => _getWeekLectures();
  DateTime get selectedWeek => _selectedWeek;
  bool get isLoading => _isLoading;
  
  List<Lecture> _getWeekLectures() {
    final weekStart = _getWeekStart(_selectedWeek);
    final weekEnd = weekStart.add(Duration(days: 7));
    
    return _lectures.where((lecture) =>
      lecture.startTime.isAfter(weekStart) &&
      lecture.startTime.isBefore(weekEnd)
    ).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }
  
  Future<void> loadTimetable() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Get user's timetable
      final timetable = await supabase
          .from('timetables')
          .select('id')
          .eq('user_id', supabase.auth.currentUser!.id)
          .single();
      
      // Get lectures for this timetable
      final lecturesResponse = await supabase
          .from('lectures')
          .select('*, attendance!left(*)')
          .eq('timetable_id', timetable['id'])
          .order('start_time');
      
      _lectures = (lecturesResponse as List)
          .map((json) => Lecture.fromJson(json))
          .toList();
      
      // Mark attended lectures
      for (var lecture in _lectures) {
        final attendance = await _checkAttendance(lecture.id);
        lecture.attended = attendance != null;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }
  
  Future<void> syncWithUniversity() async {
    // Call university API to get updated timetable
    // Update local database with changes
  }
  
  void changeWeek(DateTime newWeek) {
    _selectedWeek = newWeek;
    notifyListeners();
  }
}
```

---

## Supabase Integration

### Initialize Supabase
```dart
// main2.dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_ANON_KEY',
);

final supabase = Supabase.instance.client;
```

### Authentication Flow
```dart
class AuthService {
  final SupabaseClient _client = Supabase.instance.client;
  
  Future<User?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // Sign up with Supabase Auth
      final AuthResponse response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        // Create profile
        await _client.from('profiles').insert({
          'id': response.user!.id,
          'email': email,
          'username': username,
        });
        
        // Initialize streak record
        await _client.from('streaks').insert({
          'user_id': response.user!.id,
          'current_streak': 0,
          'longest_streak': 0,
          'streak_freezes': 3,
        });
        
        // Initialize points record
        await _client.from('points').insert({
          'user_id': response.user!.id,
          'total_points': 0,
          'weekly_points': 0,
          'monthly_points': 0,
        });
      }
      
      return response.user;
    } catch (e) {
      throw e;
    }
  }
  
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } catch (e) {
      throw e;
    }
  }
  
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
```

### Real-time Subscriptions
```dart
class RealtimeService {
  StreamSubscription? _attendanceSubscription;
  StreamSubscription? _friendRequestSubscription;
  
  void subscribeToAttendance(String userId) {
    _attendanceSubscription = supabase
        .from('attendance')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .listen((List<Map<String, dynamic>> data) {
          // Handle real-time attendance updates
        });
  }
  
  void subscribeToFriendRequests(String userId) {
    _friendRequestSubscription = supabase
        .from('friendships')
        .stream(primaryKey: ['id'])
        .eq('friend_id', userId)
        .eq('status', 'pending')
        .listen((List<Map<String, dynamic>> data) {
          // Handle new friend requests
        });
  }
  
  void dispose() {
    _attendanceSubscription?.cancel();
    _friendRequestSubscription?.cancel();
  }
}
```

---

## Supabase Project Setup Guide

This section provides step-by-step instructions for creating and linking a Supabase project to your Flutter application.

### Step 1: Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign in or create an account
2. Click **"New Project"** from your dashboard
3. Fill in the project details:
    - **Name**: `lecture-attendance-tracker` (or your preferred name)
    - **Database Password**: Generate a strong password and save it securely
    - **Region**: Select the region closest to your users (e.g., `eu-west-2` for UK)
4. Click **"Create new project"** and wait for provisioning (~2 minutes)

### Step 2: Get Your API Credentials

Once your project is ready:

1. Go to **Settings** (gear icon) → **API**
2. Copy these values (you'll need them for Flutter):
    - **Project URL**: `https://your-project-ref.supabase.co`
    - **anon/public key**: The public API key (safe to use in client apps)
    - **service_role key**: Keep this secret (server-side only)

### Step 3: Create the Database Schema

Navigate to **SQL Editor** in your Supabase dashboard and run the following SQL to create all required tables:

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Profiles table (extends Supabase auth.users)
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT NOT NULL,
  username TEXT UNIQUE NOT NULL,
  university_id TEXT,
  avatar_url TEXT,
  ical_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Timetables table
CREATE TABLE public.timetables (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL DEFAULT 'My Timetable',
  source TEXT DEFAULT 'manual', -- 'manual', 'ical', 'university_api'
  last_synced_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Lectures table
CREATE TABLE public.lectures (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  timetable_id UUID REFERENCES public.timetables(id) ON DELETE CASCADE NOT NULL,
  external_id TEXT, -- UID from iCal for deduplication
  title TEXT NOT NULL,
  module_code TEXT NOT NULL,
  location TEXT NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE NOT NULL,
  recurrence_rule TEXT, -- RRULE from iCal if recurring
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(timetable_id, external_id)
);

-- Attendance table
CREATE TABLE public.attendance (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  lecture_id UUID REFERENCES public.lectures(id) ON DELETE CASCADE NOT NULL,
  check_in_time TIMESTAMP WITH TIME ZONE NOT NULL,
  check_out_time TIMESTAMP WITH TIME ZONE,
  location_verified BOOLEAN DEFAULT FALSE,
  apps_locked BOOLEAN DEFAULT FALSE,
  lock_broken BOOLEAN DEFAULT FALSE,
  points_earned INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, lecture_id)
);

-- Streaks table
CREATE TABLE public.streaks (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE UNIQUE NOT NULL,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  streak_freezes INTEGER DEFAULT 3,
  last_attendance_date DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Points table
CREATE TABLE public.points (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE UNIQUE NOT NULL,
  total_points INTEGER DEFAULT 0,
  weekly_points INTEGER DEFAULT 0,
  monthly_points INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Friendships table
CREATE TABLE public.friendships (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  friend_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, friend_id)
);

-- Create indexes for performance
CREATE INDEX idx_lectures_timetable ON public.lectures(timetable_id);
CREATE INDEX idx_lectures_start_time ON public.lectures(start_time);
CREATE INDEX idx_attendance_user ON public.attendance(user_id);
CREATE INDEX idx_attendance_lecture ON public.attendance(lecture_id);
CREATE INDEX idx_friendships_user ON public.friendships(user_id);
CREATE INDEX idx_friendships_friend ON public.friendships(friend_id);
```

### Step 4: Set Up Row Level Security (RLS)

Run this SQL to enable RLS and create security policies:

```sql
-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.timetables ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lectures ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.streaks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.points ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.friendships ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can view friends profiles" ON public.profiles
  FOR SELECT USING (
    id IN (
      SELECT friend_id FROM public.friendships 
      WHERE user_id = auth.uid() AND status = 'accepted'
      UNION
      SELECT user_id FROM public.friendships 
      WHERE friend_id = auth.uid() AND status = 'accepted'
    )
  );

-- Timetables policies
CREATE POLICY "Users can CRUD own timetables" ON public.timetables
  FOR ALL USING (auth.uid() = user_id);

-- Lectures policies
CREATE POLICY "Users can view own lectures" ON public.lectures
  FOR SELECT USING (
    timetable_id IN (
      SELECT id FROM public.timetables WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can manage own lectures" ON public.lectures
  FOR ALL USING (
    timetable_id IN (
      SELECT id FROM public.timetables WHERE user_id = auth.uid()
    )
  );

-- Attendance policies
CREATE POLICY "Users can CRUD own attendance" ON public.attendance
  FOR ALL USING (auth.uid() = user_id);

-- Streaks policies
CREATE POLICY "Users can view own streak" ON public.streaks
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own streak" ON public.streaks
  FOR UPDATE USING (auth.uid() = user_id);

-- Points policies
CREATE POLICY "Users can view own points" ON public.points
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can view friends points for leaderboard" ON public.points
  FOR SELECT USING (
    user_id IN (
      SELECT friend_id FROM public.friendships 
      WHERE user_id = auth.uid() AND status = 'accepted'
      UNION
      SELECT user_id FROM public.friendships 
      WHERE friend_id = auth.uid() AND status = 'accepted'
    )
  );

-- Friendships policies
CREATE POLICY "Users can view own friendships" ON public.friendships
  FOR SELECT USING (auth.uid() = user_id OR auth.uid() = friend_id);

CREATE POLICY "Users can create friend requests" ON public.friendships
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update friendships they're part of" ON public.friendships
  FOR UPDATE USING (auth.uid() = user_id OR auth.uid() = friend_id);

CREATE POLICY "Users can delete own friendships" ON public.friendships
  FOR DELETE USING (auth.uid() = user_id OR auth.uid() = friend_id);
```

### Step 5: Create Database Functions

Add these helper functions for common operations:

```sql
-- Function to auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, username)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1))
  );
  
  INSERT INTO public.streaks (user_id) VALUES (NEW.id);
  INSERT INTO public.points (user_id) VALUES (NEW.id);
  INSERT INTO public.timetables (user_id, name) VALUES (NEW.id, 'My Timetable');
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for new user signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to update timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add update triggers to relevant tables
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_timetables_updated_at
  BEFORE UPDATE ON public.timetables
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_streaks_updated_at
  BEFORE UPDATE ON public.streaks
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();
```

### Step 6: Configure Flutter Project

#### Add Dependencies

In your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.3.0
  flutter_dotenv: ^5.1.0
```

#### Create Environment File

Create a `.env` file in your project root (add to `.gitignore`):

```
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

#### Initialize Supabase

Update your `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
    ),
  );
  
  runApp(const MyApp());
}

// Global Supabase client accessor
final supabase = Supabase.instance.client;
```

#### Configure Deep Links (for Auth)

For email confirmation and password reset to work, configure deep links:

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="io.supabase.lecturetracker" android:host="login-callback" />
</intent-filter>
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>io.supabase.lecturetracker</string>
    </array>
  </dict>
</array>
```

**Supabase Dashboard**: Go to **Authentication** → **URL Configuration** and set:
- Site URL: `io.supabase.lecturetracker://login-callback`
- Redirect URLs: Add `io.supabase.lecturetracker://login-callback`

### Step 7: Verify Setup

Test your connection with this widget:

```dart
class ConnectionTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: supabase.from('profiles').select().limit(1),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return Text('Supabase connected successfully!');
      },
    );
  }
}
```

---

## iCal Calendar Integration

This section details how to implement iCal (.ics) file import via URL for automatic timetable synchronization.

### Overview

Bath University (and most universities) provide timetables as iCal feeds. Users can paste their timetable URL, and the app will:
1. Fetch the iCal data
2. Parse the events
3. Store lectures in Supabase
4. Periodically sync for updates

### Step 1: Add Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  icalendar_parser: ^2.0.0  # For parsing iCal format
  http: ^1.1.0               # For fetching the iCal URL
```

### Step 2: Create iCal Models

```dart
// lib/models/ical_event.dart

class ICalEvent {
  final String uid;
  final String summary;
  final String? description;
  final String? location;
  final DateTime dtStart;
  final DateTime dtEnd;
  final String? rrule;
  
  ICalEvent({
    required this.uid,
    required this.summary,
    this.description,
    this.location,
    required this.dtStart,
    required this.dtEnd,
    this.rrule,
  });
  
  /// Extract module code from summary (e.g., "CM10228 - Lecture" → "CM10228")
  String get moduleCode {
    final match = RegExp(r'^([A-Z]{2,4}\d{4,5})').firstMatch(summary);
    return match?.group(1) ?? 'MISC';
  }
  
  /// Get clean title without module code
  String get title {
    return summary
        .replaceFirst(RegExp(r'^[A-Z]{2,4}\d{4,5}\s*[-:]\s*'), '')
        .trim();
  }
  
  /// Convert to Lecture model for database storage
  Map<String, dynamic> toLectureJson(String timetableId) {
    return {
      'timetable_id': timetableId,
      'external_id': uid,
      'title': title.isEmpty ? summary : title,
      'module_code': moduleCode,
      'location': location ?? 'TBC',
      'latitude': 0.0,  // Will be geocoded separately
      'longitude': 0.0,
      'start_time': dtStart.toIso8601String(),
      'end_time': dtEnd.toIso8601String(),
      'recurrence_rule': rrule,
    };
  }
}
```

### Step 3: Create iCal Service

```dart
// lib/services/ical_service.dart

import 'package:http/http.dart' as http;
import 'package:icalendar_parser/icalendar_parser.dart';
import '../models/ical_event.dart';

class ICalService {
  static final ICalService instance = ICalService._();
  ICalService._();
  
  /// Validates that a URL points to a valid iCal feed
  Future<bool> validateICalUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        Duration(seconds: 10),
      );
      
      if (response.statusCode != 200) return false;
      
      // Check if content looks like iCal
      final content = response.body;
      return content.contains('BEGIN:VCALENDAR') && 
             content.contains('BEGIN:VEVENT');
    } catch (e) {
      return false;
    }
  }
  
  /// Fetches and parses iCal data from URL
  Future<List<ICalEvent>> fetchAndParseICal(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch iCal: ${response.statusCode}');
      }
      
      return parseICalString(response.body);
    } catch (e) {
      throw Exception('Error fetching iCal: $e');
    }
  }
  
  /// Parses iCal string content into events
  List<ICalEvent> parseICalString(String icalContent) {
    final calendar = ICalendar.fromString(icalContent);
    final events = <ICalEvent>[];
    
    for (final data in calendar.data) {
      if (data['type'] == 'VEVENT') {
        try {
          events.add(_parseEvent(data));
        } catch (e) {
          // Skip malformed events
          print('Skipping malformed event: $e');
        }
      }
    }
    
    return events;
  }
  
  ICalEvent _parseEvent(Map<String, dynamic> data) {
    // Parse start time
    final dtStartData = data['dtstart'];
    final dtStart = _parseDateTime(dtStartData);
    
    // Parse end time
    final dtEndData = data['dtend'];
    final dtEnd = _parseDateTime(dtEndData);
    
    return ICalEvent(
      uid: data['uid']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      summary: data['summary']?.toString() ?? 'Untitled Event',
      description: data['description']?.toString(),
      location: data['location']?.toString(),
      dtStart: dtStart,
      dtEnd: dtEnd,
      rrule: data['rrule']?.toString(),
    );
  }
  
  DateTime _parseDateTime(dynamic dtData) {
    if (dtData is IcsDateTime) {
      return dtData.toDateTime() ?? DateTime.now();
    } else if (dtData is DateTime) {
      return dtData;
    } else if (dtData is String) {
      return DateTime.parse(dtData);
    }
    throw Exception('Unable to parse datetime: $dtData');
  }
  
  /// Filters events to only include lectures (excludes past events, all-day events, etc.)
  List<ICalEvent> filterLectures(List<ICalEvent> events) {
    final now = DateTime.now();
    final threeMonthsFromNow = now.add(Duration(days: 90));
    
    return events.where((event) {
      // Exclude past events
      if (event.dtEnd.isBefore(now)) return false;
      
      // Exclude events too far in the future
      if (event.dtStart.isAfter(threeMonthsFromNow)) return false;
      
      // Exclude all-day events (likely not lectures)
      final duration = event.dtEnd.difference(event.dtStart);
      if (duration.inHours >= 24) return false;
      
      // Exclude very short events (likely not lectures)
      if (duration.inMinutes < 30) return false;
      
      return true;
    }).toList();
  }
}
```

### Step 4: Create Timetable Sync Service

```dart
// lib/services/timetable_sync_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'ical_service.dart';
import '../models/ical_event.dart';

class TimetableSyncService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ICalService _icalService = ICalService.instance;
  
  /// Full sync: fetches iCal and updates database
  Future<SyncResult> syncFromICalUrl(String icalUrl) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');
    
    // 1. Fetch and parse iCal
    final allEvents = await _icalService.fetchAndParseICal(icalUrl);
    final lectures = _icalService.filterLectures(allEvents);
    
    // 2. Get or create user's timetable
    final timetable = await _getOrCreateTimetable(userId);
    final timetableId = timetable['id'] as String;
    
    // 3. Update the iCal URL in profile
    await _supabase.from('profiles').update({
      'ical_url': icalUrl,
    }).eq('id', userId);
    
    // 4. Upsert lectures (insert or update based on external_id)
    int added = 0;
    int updated = 0;
    
    for (final lecture in lectures) {
      final lectureData = lecture.toLectureJson(timetableId);
      
      // Try to find existing lecture by external_id
      final existing = await _supabase
          .from('lectures')
          .select('id')
          .eq('timetable_id', timetableId)
          .eq('external_id', lecture.uid)
          .maybeSingle();
      
      if (existing != null) {
        // Update existing
        await _supabase
            .from('lectures')
            .update(lectureData)
            .eq('id', existing['id']);
        updated++;
      } else {
        // Insert new
        await _supabase.from('lectures').insert(lectureData);
        added++;
      }
    }
    
    // 5. Update last synced timestamp
    await _supabase.from('timetables').update({
      'last_synced_at': DateTime.now().toIso8601String(),
      'source': 'ical',
    }).eq('id', timetableId);
    
    return SyncResult(
      totalEvents: allEvents.length,
      lecturesFound: lectures.length,
      added: added,
      updated: updated,
    );
  }
  
  Future<Map<String, dynamic>> _getOrCreateTimetable(String userId) async {
    final existing = await _supabase
        .from('timetables')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    
    if (existing != null) return existing;
    
    final newTimetable = await _supabase
        .from('timetables')
        .insert({'user_id': userId, 'name': 'My Timetable'})
        .select()
        .single();
    
    return newTimetable;
  }
  
  /// Removes lectures that no longer exist in the iCal feed
  Future<int> cleanupDeletedLectures(String icalUrl) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return 0;
    
    final events = await _icalService.fetchAndParseICal(icalUrl);
    final currentUids = events.map((e) => e.uid).toSet();
    
    final timetable = await _supabase
        .from('timetables')
        .select('id')
        .eq('user_id', userId)
        .single();
    
    // Get all lectures from DB
    final dbLectures = await _supabase
        .from('lectures')
        .select('id, external_id')
        .eq('timetable_id', timetable['id']);
    
    int deleted = 0;
    for (final lecture in dbLectures) {
      if (lecture['external_id'] != null && 
          !currentUids.contains(lecture['external_id'])) {
        await _supabase.from('lectures').delete().eq('id', lecture['id']);
        deleted++;
      }
    }
    
    return deleted;
  }
}

class SyncResult {
  final int totalEvents;
  final int lecturesFound;
  final int added;
  final int updated;
  
  SyncResult({
    required this.totalEvents,
    required this.lecturesFound,
    required this.added,
    required this.updated,
  });
  
  @override
  String toString() {
    return 'Synced: $lecturesFound lectures ($added new, $updated updated)';
  }
}
```

### Step 5: Create UI for iCal Setup

```dart
// lib/widgets/ical_setup_dialog.dart

import 'package:flutter/material.dart';
import '../services/ical_service.dart';
import '../services/timetable_sync_service.dart';

class ICalSetupDialog extends StatefulWidget {
  final String? currentUrl;
  
  const ICalSetupDialog({this.currentUrl});
  
  @override
  State<ICalSetupDialog> createState() => _ICalSetupDialogState();
}

class _ICalSetupDialogState extends State<ICalSetupDialog> {
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isValidating = false;
  bool _isSyncing = false;
  String? _error;
  SyncResult? _result;
  
  @override
  void initState() {
    super.initState();
    _urlController.text = widget.currentUrl ?? '';
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Connect Timetable'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paste your iCal timetable URL below. You can find this in your '
                'university portal under "Export Timetable" or "Subscribe to Calendar".',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'iCal URL',
                  hintText: 'https://...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a URL';
                  }
                  if (!value.startsWith('http://') && !value.startsWith('https://')) {
                    return 'URL must start with http:// or https://';
                  }
                  return null;
                },
              ),
              if (_error != null) ...[
                SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
              if (_result != null) ...[
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Expanded(child: Text(_result.toString())),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 16),
              _buildHelpSection(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isValidating || _isSyncing ? null : _syncTimetable,
          child: _isSyncing
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Sync Timetable'),
        ),
      ],
    );
  }
  
  Widget _buildHelpSection() {
    return ExpansionTile(
      title: Text('How to find your iCal URL', style: TextStyle(fontSize: 14)),
      tilePadding: EdgeInsets.zero,
      children: [
        Text(
          '1. Log into your university portal\n'
          '2. Navigate to your timetable\n'
          '3. Look for "Export", "Subscribe", or "iCal" option\n'
          '4. Copy the URL provided (usually ends in .ics)\n\n'
          'For Bath University:\n'
          '• Go to mytimetable.bath.ac.uk\n'
          '• Click the "Subscribe" button\n'
          '• Copy the webcal:// or https:// URL',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
  
  Future<void> _syncTimetable() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isValidating = true;
      _error = null;
      _result = null;
    });
    
    final url = _urlController.text.trim()
        .replaceFirst('webcal://', 'https://'); // Convert webcal to https
    
    // Validate URL first
    final isValid = await ICalService.instance.validateICalUrl(url);
    
    if (!isValid) {
      setState(() {
        _isValidating = false;
        _error = 'Invalid iCal URL. Make sure the URL points to a valid .ics feed.';
      });
      return;
    }
    
    setState(() {
      _isValidating = false;
      _isSyncing = true;
    });
    
    try {
      final syncService = TimetableSyncService();
      final result = await syncService.syncFromICalUrl(url);
      
      setState(() {
        _isSyncing = false;
        _result = result;
      });
      
      // Auto-close after successful sync
      await Future.delayed(Duration(seconds: 2));
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      setState(() {
        _isSyncing = false;
        _error = 'Sync failed: ${e.toString()}';
      });
    }
  }
  
  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}
```

### Step 6: Add to Settings Page

Add this to your Settings page to trigger the iCal setup:

```dart
// In SettingsPage, add this ListTile in the Account section:

ListTile(
  title: Text('Link Timetable'),
  subtitle: Text(
    user.icalUrl != null 
        ? 'Connected • Tap to update' 
        : 'Import from university calendar',
  ),
  leading: Icon(Icons.calendar_month),
  trailing: Icon(Icons.chevron_right),
  onTap: () async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ICalSetupDialog(
        currentUrl: user.icalUrl,
      ),
    );
    
    if (result == true) {
      // Refresh the timetable data
      context.read<TimetableProvider>().loadTimetable();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Timetable synced successfully!')),
      );
    }
  },
),
```

### Step 7: Implement Auto-Sync (Optional)

For automatic periodic syncing:

```dart
// lib/services/background_sync_service.dart

import 'package:workmanager/workmanager.dart';
import 'timetable_sync_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String timetableSyncTask = 'timetable_sync';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == timetableSyncTask) {
      try {
        // Initialize Supabase in background
        await Supabase.initialize(
          url: inputData?['supabase_url'] ?? '',
          anonKey: inputData?['supabase_key'] ?? '',
        );
        
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('ical_url')
            .eq('id', Supabase.instance.client.auth.currentUser?.id)
            .maybeSingle();
        
        if (profile?['ical_url'] != null) {
          final syncService = TimetableSyncService();
          await syncService.syncFromICalUrl(profile!['ical_url']);
        }
        
        return true;
      } catch (e) {
        print('Background sync failed: $e');
        return false;
      }
    }
    return false;
  });
}

class BackgroundSyncService {
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
  }
  
  static Future<void> registerPeriodicSync() async {
    await Workmanager().registerPeriodicTask(
      'timetable_sync_task',
      timetableSyncTask,
      frequency: Duration(hours: 12),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresCharging: false,
      ),
    );
  }
  
  static Future<void> cancelSync() async {
    await Workmanager().cancelByUniqueName('timetable_sync_task');
  }
}
```

### Location Geocoding for Lecture Rooms

To enable location-based check-in, you'll need to geocode room names. Add this to your sync service:

```dart
// Add to TimetableSyncService

/// Geocodes location names to coordinates
/// You'll need a mapping of room codes to coordinates for your university
Future<void> geocodeLectures() async {
  // Bath University room coordinates (example)
  // In production, this could be fetched from a university API or maintained in a separate table
  final roomCoordinates = <String, Map<String, double>>{
    '1W 2.101': {'lat': 51.3796, 'lng': -2.3281},
    '2E 3.1': {'lat': 51.3794, 'lng': -2.3276},
    '8W 1.1': {'lat': 51.3801, 'lng': -2.3290},
    'CB 1.11': {'lat': 51.3788, 'lng': -2.3269},
    // Add more rooms as needed
  };
  
  final userId = _supabase.auth.currentUser?.id;
  if (userId == null) return;
  
  final lectures = await _supabase
      .from('lectures')
      .select('id, location')
      .eq('latitude', 0.0); // Only geocode lectures without coordinates
  
  for (final lecture in lectures) {
    final location = lecture['location'] as String?;
    if (location == null) continue;
    
    // Try to find matching room
    for (final entry in roomCoordinates.entries) {
      if (location.contains(entry.key)) {
        await _supabase.from('lectures').update({
          'latitude': entry.value['lat'],
          'longitude': entry.value['lng'],
        }).eq('id', lecture['id']);
        break;
      }
    }
  }
}
```

---

## Real Data Implementation

This section provides complete implementations for connecting each page to real Supabase data, replacing placeholder content with live data fetching, caching, and state management.

### Repository Pattern

First, create a repository layer to abstract database operations:

```dart
// lib/repositories/base_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';

abstract class BaseRepository {
  final SupabaseClient _client = Supabase.instance.client;
  
  SupabaseClient get client => _client;
  
  String? get currentUserId => _client.auth.currentUser?.id;
  
  void requireAuth() {
    if (currentUserId == null) {
      throw Exception('User must be authenticated');
    }
  }
}
```

### User Repository

```dart
// lib/repositories/user_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';
import '../models/streak.dart';
import '../models/points.dart';
import 'base_repository.dart';

class UserRepository extends BaseRepository {
  static final UserRepository instance = UserRepository._();
  UserRepository._();
  
  /// Fetches the current user's complete profile with stats
  Future<UserProfile> getCurrentUserProfile() async {
    requireAuth();
    
    final response = await client
        .from('profiles')
        .select('''
          *,
          streaks(*),
          points(*)
        ''')
        .eq('id', currentUserId!)
        .single();
    
    return UserProfile.fromJson(response);
  }
  
  /// Fetches just the basic profile info
  Future<User> getProfile(String userId) async {
    final response = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    
    return User.fromJson(response);
  }
  
  /// Updates user profile
  Future<void> updateProfile({
    String? username,
    String? avatarUrl,
    String? universityId,
  }) async {
    requireAuth();
    
    final updates = <String, dynamic>{};
    if (username != null) updates['username'] = username;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (universityId != null) updates['university_id'] = universityId;
    
    if (updates.isEmpty) return;
    
    await client
        .from('profiles')
        .update(updates)
        .eq('id', currentUserId!);
  }
  
  /// Gets streak info for current user
  Future<Streak> getCurrentStreak() async {
    requireAuth();
    
    final response = await client
        .from('streaks')
        .select()
        .eq('user_id', currentUserId!)
        .single();
    
    return Streak.fromJson(response);
  }
  
  /// Gets points for current user
  Future<Points> getCurrentPoints() async {
    requireAuth();
    
    final response = await client
        .from('points')
        .select()
        .eq('user_id', currentUserId!)
        .single();
    
    return Points.fromJson(response);
  }
  
  /// Searches for users by username (for adding friends)
  Future<List<User>> searchUsers(String query) async {
    requireAuth();
    
    final response = await client
        .from('profiles')
        .select()
        .ilike('username', '%$query%')
        .neq('id', currentUserId!)
        .limit(20);
    
    return (response as List).map((json) => User.fromJson(json)).toList();
  }
}
```

### Attendance Repository

```dart
// lib/repositories/attendance_repository.dart

import 'base_repository.dart';
import '../models/attendance.dart';

class AttendanceRepository extends BaseRepository {
  static final AttendanceRepository instance = AttendanceRepository._();
  AttendanceRepository._();
  
  /// Gets attendance stats for current user
  Future<AttendanceStats> getAttendanceStats() async {
    requireAuth();
    
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    // Get all attendance records
    final allAttendance = await client
        .from('attendance')
        .select('*, lectures!inner(start_time, end_time)')
        .eq('user_id', currentUserId!);
    
    // Get total lectures for the user
    final timetable = await client
        .from('timetables')
        .select('id')
        .eq('user_id', currentUserId!)
        .single();
    
    final allLectures = await client
        .from('lectures')
        .select('id, start_time, end_time')
        .eq('timetable_id', timetable['id'])
        .lte('end_time', now.toIso8601String());
    
    // Calculate weekly stats
    final weeklyAttendance = (allAttendance as List).where((a) {
      final checkIn = DateTime.parse(a['check_in_time']);
      return checkIn.isAfter(startOfWeek);
    }).length;
    
    final weeklyLectures = (allLectures as List).where((l) {
      final start = DateTime.parse(l['start_time']);
      return start.isAfter(startOfWeek) && start.isBefore(now);
    }).length;
    
    // Calculate monthly stats
    final monthlyAttendance = (allAttendance).where((a) {
      final checkIn = DateTime.parse(a['check_in_time']);
      return checkIn.isAfter(startOfMonth);
    }).length;
    
    final monthlyLectures = (allLectures).where((l) {
      final start = DateTime.parse(l['start_time']);
      return start.isAfter(startOfMonth) && start.isBefore(now);
    }).length;
    
    // Overall stats
    final totalAttended = allAttendance.length;
    final totalLectures = allLectures.length;
    
    return AttendanceStats(
      weeklyAttended: weeklyAttendance,
      weeklyTotal: weeklyLectures,
      monthlyAttended: monthlyAttendance,
      monthlyTotal: monthlyLectures,
      overallAttended: totalAttended,
      overallTotal: totalLectures,
    );
  }
  
  /// Gets attendance history for last N days (for chart)
  Future<List<DailyAttendance>> getAttendanceHistory(int days) async {
    requireAuth();
    
    final startDate = DateTime.now().subtract(Duration(days: days));
    
    final attendance = await client
        .from('attendance')
        .select('check_in_time')
        .eq('user_id', currentUserId!)
        .gte('check_in_time', startDate.toIso8601String())
        .order('check_in_time');
    
    // Group by date
    final Map<String, int> byDate = {};
    for (final record in attendance as List) {
      final date = DateTime.parse(record['check_in_time']);
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      byDate[key] = (byDate[key] ?? 0) + 1;
    }
    
    // Create list for all days
    final result = <DailyAttendance>[];
    for (int i = days - 1; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      result.add(DailyAttendance(
        date: date,
        count: byDate[key] ?? 0,
      ));
    }
    
    return result;
  }
  
  /// Records a check-in
  Future<Attendance> checkIn({
    required String lectureId,
    required bool locationVerified,
    bool appsLocked = true,
  }) async {
    requireAuth();
    
    final response = await client
        .from('attendance')
        .insert({
          'user_id': currentUserId!,
          'lecture_id': lectureId,
          'check_in_time': DateTime.now().toIso8601String(),
          'location_verified': locationVerified,
          'apps_locked': appsLocked,
          'points_earned': locationVerified ? 10 : 5,
        })
        .select()
        .single();
    
    // Update points
    await _addPoints(locationVerified ? 10 : 5);
    
    // Update streak
    await _updateStreak();
    
    return Attendance.fromJson(response);
  }
  
  /// Records check-out or lock break
  Future<void> checkOut(String attendanceId, {bool lockBroken = false}) async {
    await client
        .from('attendance')
        .update({
          'check_out_time': DateTime.now().toIso8601String(),
          'lock_broken': lockBroken,
          'points_earned': lockBroken ? 5 : 10, // Reduced points if lock broken
        })
        .eq('id', attendanceId);
  }
  
  /// Gets current active attendance (if any)
  Future<Attendance?> getCurrentAttendance() async {
    requireAuth();
    
    final response = await client
        .from('attendance')
        .select('*, lectures(*)')
        .eq('user_id', currentUserId!)
        .isFilter('check_out_time', null)
        .maybeSingle();
    
    if (response == null) return null;
    return Attendance.fromJson(response);
  }
  
  Future<void> _addPoints(int points) async {
    await client.rpc('add_points', params: {
      'p_user_id': currentUserId!,
      'p_points': points,
    });
  }
  
  Future<void> _updateStreak() async {
    await client.rpc('update_streak', params: {
      'p_user_id': currentUserId!,
    });
  }
}

class AttendanceStats {
  final int weeklyAttended;
  final int weeklyTotal;
  final int monthlyAttended;
  final int monthlyTotal;
  final int overallAttended;
  final int overallTotal;
  
  AttendanceStats({
    required this.weeklyAttended,
    required this.weeklyTotal,
    required this.monthlyAttended,
    required this.monthlyTotal,
    required this.overallAttended,
    required this.overallTotal,
  });
  
  double get weeklyRate => weeklyTotal > 0 ? weeklyAttended / weeklyTotal : 0;
  double get monthlyRate => monthlyTotal > 0 ? monthlyAttended / monthlyTotal : 0;
  double get overallRate => overallTotal > 0 ? overallAttended / overallTotal : 0;
}

class DailyAttendance {
  final DateTime date;
  final int count;
  
  DailyAttendance({required this.date, required this.count});
}
```

### Lecture Repository

```dart
// lib/repositories/lecture_repository.dart

import 'base_repository.dart';
import '../models/lecture.dart';

class LectureRepository extends BaseRepository {
  static final LectureRepository instance = LectureRepository._();
  LectureRepository._();
  
  /// Gets all lectures for current user
  Future<List<Lecture>> getAllLectures() async {
    requireAuth();
    
    final timetable = await client
        .from('timetables')
        .select('id')
        .eq('user_id', currentUserId!)
        .single();
    
    final response = await client
        .from('lectures')
        .select()
        .eq('timetable_id', timetable['id'])
        .order('start_time');
    
    return (response as List).map((json) => Lecture.fromJson(json)).toList();
  }
  
  /// Gets lectures for a specific week
  Future<List<Lecture>> getLecturesForWeek(DateTime weekStart) async {
    requireAuth();
    
    final weekEnd = weekStart.add(Duration(days: 7));
    
    final timetable = await client
        .from('timetables')
        .select('id')
        .eq('user_id', currentUserId!)
        .single();
    
    final response = await client
        .from('lectures')
        .select()
        .eq('timetable_id', timetable['id'])
        .gte('start_time', weekStart.toIso8601String())
        .lt('start_time', weekEnd.toIso8601String())
        .order('start_time');
    
    return (response as List).map((json) => Lecture.fromJson(json)).toList();
  }
  
  /// Gets lectures with attendance status for a week
  Future<List<LectureWithAttendance>> getLecturesWithAttendance(DateTime weekStart) async {
    requireAuth();
    
    final weekEnd = weekStart.add(Duration(days: 7));
    
    final timetable = await client
        .from('timetables')
        .select('id')
        .eq('user_id', currentUserId!)
        .single();
    
    final response = await client
        .from('lectures')
        .select('''
          *,
          attendance!left(id, check_in_time, points_earned)
        ''')
        .eq('timetable_id', timetable['id'])
        .gte('start_time', weekStart.toIso8601String())
        .lt('start_time', weekEnd.toIso8601String())
        .order('start_time');
    
    return (response as List).map((json) {
      final lecture = Lecture.fromJson(json);
      final attendanceList = json['attendance'] as List?;
      final attended = attendanceList != null && attendanceList.isNotEmpty;
      
      return LectureWithAttendance(
        lecture: lecture,
        attended: attended,
        attendanceId: attended ? attendanceList!.first['id'] : null,
      );
    }).toList();
  }
  
  /// Gets the current active lecture (if any)
  Future<Lecture?> getCurrentLecture() async {
    requireAuth();
    
    final now = DateTime.now();
    
    final timetable = await client
        .from('timetables')
        .select('id')
        .eq('user_id', currentUserId!)
        .single();
    
    final response = await client
        .from('lectures')
        .select()
        .eq('timetable_id', timetable['id'])
        .lte('start_time', now.toIso8601String())
        .gte('end_time', now.toIso8601String())
        .maybeSingle();
    
    if (response == null) return null;
    return Lecture.fromJson(response);
  }
  
  /// Gets the next upcoming lecture
  Future<Lecture?> getNextLecture() async {
    requireAuth();
    
    final now = DateTime.now();
    
    final timetable = await client
        .from('timetables')
        .select('id')
        .eq('user_id', currentUserId!)
        .single();
    
    final response = await client
        .from('lectures')
        .select()
        .eq('timetable_id', timetable['id'])
        .gt('start_time', now.toIso8601String())
        .order('start_time')
        .limit(1)
        .maybeSingle();
    
    if (response == null) return null;
    return Lecture.fromJson(response);
  }
  
  /// Gets today's lectures
  Future<List<Lecture>> getTodaysLectures() async {
    requireAuth();
    
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(Duration(days: 1));
    
    final timetable = await client
        .from('timetables')
        .select('id')
        .eq('user_id', currentUserId!)
        .single();
    
    final response = await client
        .from('lectures')
        .select()
        .eq('timetable_id', timetable['id'])
        .gte('start_time', startOfDay.toIso8601String())
        .lt('start_time', endOfDay.toIso8601String())
        .order('start_time');
    
    return (response as List).map((json) => Lecture.fromJson(json)).toList();
  }
}

class LectureWithAttendance {
  final Lecture lecture;
  final bool attended;
  final String? attendanceId;
  
  LectureWithAttendance({
    required this.lecture,
    required this.attended,
    this.attendanceId,
  });
}
```

### Friends Repository

```dart
// lib/repositories/friends_repository.dart

import 'base_repository.dart';
import '../models/user.dart';
import '../models/friendship.dart';

class FriendsRepository extends BaseRepository {
  static final FriendsRepository instance = FriendsRepository._();
  FriendsRepository._();
  
  /// Gets all accepted friends with their stats
  Future<List<FriendWithStats>> getFriends() async {
    requireAuth();
    
    // Get friendships where current user is either user_id or friend_id
    final response = await client
        .from('friendships')
        .select('''
          *,
          friend:profiles!friendships_friend_id_fkey(
            id, username, avatar_url,
            streaks(current_streak),
            points(total_points)
          ),
          user:profiles!friendships_user_id_fkey(
            id, username, avatar_url,
            streaks(current_streak),
            points(total_points)
          )
        ''')
        .or('user_id.eq.${currentUserId!},friend_id.eq.${currentUserId!}')
        .eq('status', 'accepted');
    
    return (response as List).map((json) {
      // Determine which side of the friendship is "the friend"
      final isUserSide = json['user_id'] == currentUserId;
      final friendData = isUserSide ? json['friend'] : json['user'];
      
      return FriendWithStats(
        id: friendData['id'],
        username: friendData['username'],
        avatarUrl: friendData['avatar_url'],
        currentStreak: friendData['streaks']?['current_streak'] ?? 0,
        totalPoints: friendData['points']?['total_points'] ?? 0,
        friendshipId: json['id'],
      );
    }).toList();
  }
  
  /// Gets pending friend requests (where current user is the recipient)
  Future<List<FriendRequest>> getPendingRequests() async {
    requireAuth();
    
    final response = await client
        .from('friendships')
        .select('''
          *,
          sender:profiles!friendships_user_id_fkey(id, username, avatar_url)
        ''')
        .eq('friend_id', currentUserId!)
        .eq('status', 'pending');
    
    return (response as List).map((json) => FriendRequest(
      id: json['id'],
      senderId: json['sender']['id'],
      senderUsername: json['sender']['username'],
      senderAvatarUrl: json['sender']['avatar_url'],
      createdAt: DateTime.parse(json['created_at']),
    )).toList();
  }
  
  /// Sends a friend request
  Future<void> sendFriendRequest(String friendId) async {
    requireAuth();
    
    // Check if friendship already exists
    final existing = await client
        .from('friendships')
        .select('id')
        .or('and(user_id.eq.${currentUserId!},friend_id.eq.$friendId),and(user_id.eq.$friendId,friend_id.eq.${currentUserId!})')
        .maybeSingle();
    
    if (existing != null) {
      throw Exception('Friend request already exists');
    }
    
    await client.from('friendships').insert({
      'user_id': currentUserId!,
      'friend_id': friendId,
      'status': 'pending',
    });
  }
  
  /// Accepts a friend request
  Future<void> acceptRequest(String friendshipId) async {
    await client
        .from('friendships')
        .update({'status': 'accepted'})
        .eq('id', friendshipId)
        .eq('friend_id', currentUserId!); // Ensure only recipient can accept
  }
  
  /// Rejects a friend request
  Future<void> rejectRequest(String friendshipId) async {
    await client
        .from('friendships')
        .update({'status': 'rejected'})
        .eq('id', friendshipId)
        .eq('friend_id', currentUserId!);
  }
  
  /// Removes a friend
  Future<void> removeFriend(String friendshipId) async {
    await client
        .from('friendships')
        .delete()
        .eq('id', friendshipId);
  }
}

class FriendWithStats {
  final String id;
  final String username;
  final String? avatarUrl;
  final int currentStreak;
  final int totalPoints;
  final String friendshipId;
  
  FriendWithStats({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.currentStreak,
    required this.totalPoints,
    required this.friendshipId,
  });
}

class FriendRequest {
  final String id;
  final String senderId;
  final String senderUsername;
  final String? senderAvatarUrl;
  final DateTime createdAt;
  
  FriendRequest({
    required this.id,
    required this.senderId,
    required this.senderUsername,
    this.senderAvatarUrl,
    required this.createdAt,
  });
}
```

### Leaderboard Repository

```dart
// lib/repositories/leaderboard_repository.dart

import 'base_repository.dart';

class LeaderboardRepository extends BaseRepository {
  static final LeaderboardRepository instance = LeaderboardRepository._();
  LeaderboardRepository._();
  
  /// Gets global leaderboard (top users by points)
  Future<List<LeaderboardEntry>> getGlobalLeaderboard({int limit = 50}) async {
    final response = await client
        .from('points')
        .select('''
          total_points,
          profiles!inner(id, username, avatar_url)
        ''')
        .order('total_points', ascending: false)
        .limit(limit);
    
    return _mapToEntries(response as List);
  }
  
  /// Gets friends-only leaderboard
  Future<List<LeaderboardEntry>> getFriendsLeaderboard() async {
    requireAuth();
    
    // First get friend IDs
    final friendships = await client
        .from('friendships')
        .select('user_id, friend_id')
        .or('user_id.eq.${currentUserId!},friend_id.eq.${currentUserId!}')
        .eq('status', 'accepted');
    
    final friendIds = <String>{currentUserId!}; // Include self
    for (final f in friendships as List) {
      friendIds.add(f['user_id']);
      friendIds.add(f['friend_id']);
    }
    
    // Get points for all friends
    final response = await client
        .from('points')
        .select('''
          total_points,
          profiles!inner(id, username, avatar_url)
        ''')
        .inFilter('user_id', friendIds.toList())
        .order('total_points', ascending: false);
    
    return _mapToEntries(response as List);
  }
  
  /// Gets current user's rank
  Future<int> getCurrentUserRank({bool globalOnly = true}) async {
    requireAuth();
    
    final userPoints = await client
        .from('points')
        .select('total_points')
        .eq('user_id', currentUserId!)
        .single();
    
    final higherCount = await client
        .from('points')
        .select('user_id')
        .gt('total_points', userPoints['total_points']);
    
    return (higherCount as List).length + 1;
  }
  
  List<LeaderboardEntry> _mapToEntries(List<dynamic> response) {
    return response.asMap().entries.map((entry) {
      final json = entry.value;
      final profile = json['profiles'];
      
      return LeaderboardEntry(
        rank: entry.key + 1,
        userId: profile['id'],
        username: profile['username'],
        avatarUrl: profile['avatar_url'],
        totalPoints: json['total_points'] ?? 0,
        isCurrentUser: profile['id'] == currentUserId,
      );
    }).toList();
  }
}

class LeaderboardEntry {
  final int rank;
  final String userId;
  final String username;
  final String? avatarUrl;
  final int totalPoints;
  final bool isCurrentUser;
  
  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.totalPoints,
    required this.isCurrentUser,
  });
}
```

### Database Functions for Points and Streaks

Add these SQL functions to Supabase for atomic operations:

```sql
-- Function to add points atomically
CREATE OR REPLACE FUNCTION add_points(p_user_id UUID, p_points INTEGER)
RETURNS VOID AS $$
BEGIN
  UPDATE public.points
  SET 
    total_points = total_points + p_points,
    weekly_points = weekly_points + p_points,
    monthly_points = monthly_points + p_points,
    updated_at = NOW()
  WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update streak
CREATE OR REPLACE FUNCTION update_streak(p_user_id UUID)
RETURNS VOID AS $$
DECLARE
  v_last_date DATE;
  v_current_streak INTEGER;
  v_longest_streak INTEGER;
BEGIN
  SELECT last_attendance_date, current_streak, longest_streak
  INTO v_last_date, v_current_streak, v_longest_streak
  FROM public.streaks
  WHERE user_id = p_user_id;
  
  IF v_last_date IS NULL OR v_last_date < CURRENT_DATE - INTERVAL '1 day' THEN
    -- Streak broken or first attendance
    v_current_streak := 1;
  ELSIF v_last_date = CURRENT_DATE - INTERVAL '1 day' THEN
    -- Consecutive day
    v_current_streak := v_current_streak + 1;
  END IF;
  -- If same day, don't change streak
  
  -- Update longest if needed
  IF v_current_streak > v_longest_streak THEN
    v_longest_streak := v_current_streak;
  END IF;
  
  UPDATE public.streaks
  SET 
    current_streak = v_current_streak,
    longest_streak = v_longest_streak,
    last_attendance_date = CURRENT_DATE,
    updated_at = NOW()
  WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to reset weekly/monthly points (call via cron)
CREATE OR REPLACE FUNCTION reset_periodic_points()
RETURNS VOID AS $$
BEGIN
  -- Reset weekly points on Monday
  IF EXTRACT(DOW FROM CURRENT_DATE) = 1 THEN
    UPDATE public.points SET weekly_points = 0;
  END IF;
  
  -- Reset monthly points on 1st
  IF EXTRACT(DAY FROM CURRENT_DATE) = 1 THEN
    UPDATE public.points SET monthly_points = 0;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### Updated Providers with Real Data

#### ProfileProvider

```dart
// lib/providers/profile_provider.dart

import 'package:flutter/foundation.dart';
import '../repositories/user_repository.dart';
import '../repositories/attendance_repository.dart';
import '../models/user.dart';
import '../models/streak.dart';
import '../models/points.dart';

class ProfileProvider extends ChangeNotifier {
  final UserRepository _userRepo = UserRepository.instance;
  final AttendanceRepository _attendanceRepo = AttendanceRepository.instance;
  
  UserProfile? _profile;
  AttendanceStats? _stats;
  List<DailyAttendance>? _attendanceHistory;
  bool _isLoading = false;
  String? _error;
  
  UserProfile? get profile => _profile;
  AttendanceStats? get stats => _stats;
  List<DailyAttendance>? get attendanceHistory => _attendanceHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Convenience getters
  User? get user => _profile?.user;
  Streak? get streak => _profile?.streak;
  Points? get points => _profile?.points;
  
  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _profile = await _userRepo.getCurrentUserProfile();
      _stats = await _attendanceRepo.getAttendanceStats();
      _attendanceHistory = await _attendanceRepo.getAttendanceHistory(30);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> updateUsername(String newUsername) async {
    try {
      await _userRepo.updateProfile(username: newUsername);
      await loadProfile(); // Refresh
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> refresh() async {
    await loadProfile();
  }
}

// Combined profile model
class UserProfile {
  final User user;
  final Streak streak;
  final Points points;
  
  UserProfile({
    required this.user,
    required this.streak,
    required this.points,
  });
  
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      user: User.fromJson(json),
      streak: Streak.fromJson(json['streaks'] ?? {}),
      points: Points.fromJson(json['points'] ?? {}),
    );
  }
}
```

#### TimetableProvider (Updated)

```dart
// lib/providers/timetable_provider.dart

import 'package:flutter/foundation.dart';
import '../repositories/lecture_repository.dart';
import '../models/lecture.dart';

class TimetableProvider extends ChangeNotifier {
  final LectureRepository _lectureRepo = LectureRepository.instance;
  
  List<LectureWithAttendance> _lectures = [];
  DateTime _selectedWeek = _getWeekStart(DateTime.now());
  bool _isLoading = false;
  String? _error;
  
  List<LectureWithAttendance> get lectures => _lectures;
  DateTime get selectedWeek => _selectedWeek;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Get lectures grouped by day
  Map<int, List<LectureWithAttendance>> get lecturesByDay {
    final Map<int, List<LectureWithAttendance>> grouped = {};
    for (final lecture in _lectures) {
      final day = lecture.lecture.startTime.weekday;
      grouped.putIfAbsent(day, () => []);
      grouped[day]!.add(lecture);
    }
    return grouped;
  }
  
  Future<void> loadWeek([DateTime? week]) async {
    if (week != null) {
      _selectedWeek = _getWeekStart(week);
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _lectures = await _lectureRepo.getLecturesWithAttendance(_selectedWeek);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  void nextWeek() {
    loadWeek(_selectedWeek.add(Duration(days: 7)));
  }
  
  void previousWeek() {
    loadWeek(_selectedWeek.subtract(Duration(days: 7)));
  }
  
  void goToToday() {
    loadWeek(DateTime.now());
  }
  
  static DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }
}
```

#### CheckInProvider (Updated)

```dart
// lib/providers/checkin_provider.dart

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../repositories/lecture_repository.dart';
import '../repositories/attendance_repository.dart';
import '../models/lecture.dart';
import '../models/attendance.dart';
import '../services/location_service.dart';

enum CheckInState {
  loading,
  noLecture,
  readyToCheckIn,
  tooFarAway,
  checkingIn,
  checkedIn,
  lectureEnded,
  error,
}

class CheckInProvider extends ChangeNotifier {
  final LectureRepository _lectureRepo = LectureRepository.instance;
  final AttendanceRepository _attendanceRepo = AttendanceRepository.instance;
  final LocationService _locationService = LocationService.instance;
  
  CheckInState _state = CheckInState.loading;
  Lecture? _currentLecture;
  Lecture? _nextLecture;
  Attendance? _currentAttendance;
  double? _distanceToLecture;
  String? _error;
  
  CheckInState get state => _state;
  Lecture? get currentLecture => _currentLecture;
  Lecture? get nextLecture => _nextLecture;
  Attendance? get currentAttendance => _currentAttendance;
  double? get distanceToLecture => _distanceToLecture;
  String? get error => _error;
  
  // Time until next lecture
  Duration? get timeUntilNext {
    if (_nextLecture == null) return null;
    return _nextLecture!.startTime.difference(DateTime.now());
  }
  
  // Time remaining in current lecture
  Duration? get timeRemaining {
    if (_currentLecture == null) return null;
    return _currentLecture!.endTime.difference(DateTime.now());
  }
  
  Future<void> loadCurrentState() async {
    _state = CheckInState.loading;
    notifyListeners();
    
    try {
      // Check for existing attendance first
      _currentAttendance = await _attendanceRepo.getCurrentAttendance();
      
      if (_currentAttendance != null) {
        _state = CheckInState.checkedIn;
        _currentLecture = await _lectureRepo.getCurrentLecture();
        notifyListeners();
        return;
      }
      
      // Check for current lecture
      _currentLecture = await _lectureRepo.getCurrentLecture();
      
      if (_currentLecture != null) {
        // Check location
        await _checkLocation();
      } else {
        // No current lecture, get next one
        _nextLecture = await _lectureRepo.getNextLecture();
        _state = CheckInState.noLecture;
      }
      
      notifyListeners();
    } catch (e) {
      _state = CheckInState.error;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> _checkLocation() async {
    try {
      final hasPermission = await _locationService.checkPermissions();
      if (!hasPermission) {
        _state = CheckInState.readyToCheckIn; // Allow check-in without location
        _distanceToLecture = null;
        return;
      }
      
      final position = await _locationService.getCurrentPosition();
      _distanceToLecture = _locationService.calculateDistance(
        position.latitude,
        position.longitude,
        _currentLecture!.latitude,
        _currentLecture!.longitude,
      );
      
      // 100 meters threshold
      if (_distanceToLecture! <= 100) {
        _state = CheckInState.readyToCheckIn;
      } else {
        _state = CheckInState.tooFarAway;
      }
    } catch (e) {
      // Location error - still allow check-in
      _state = CheckInState.readyToCheckIn;
      _distanceToLecture = null;
    }
  }
  
  Future<void> checkIn() async {
    if (_currentLecture == null) return;
    
    _state = CheckInState.checkingIn;
    notifyListeners();
    
    try {
      final locationVerified = _distanceToLecture != null && _distanceToLecture! <= 100;
      
      _currentAttendance = await _attendanceRepo.checkIn(
        lectureId: _currentLecture!.id,
        locationVerified: locationVerified,
      );
      
      _state = CheckInState.checkedIn;
      notifyListeners();
    } catch (e) {
      _state = CheckInState.error;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> breakLock() async {
    if (_currentAttendance == null) return;
    
    try {
      await _attendanceRepo.checkOut(_currentAttendance!.id, lockBroken: true);
      _currentAttendance = null;
      _state = CheckInState.lectureEnded;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> refresh() async {
    await loadCurrentState();
  }
}
```

#### FriendsProvider

```dart
// lib/providers/friends_provider.dart

import 'package:flutter/foundation.dart';
import '../repositories/friends_repository.dart';
import '../repositories/leaderboard_repository.dart';

class FriendsProvider extends ChangeNotifier {
  final FriendsRepository _friendsRepo = FriendsRepository.instance;
  final LeaderboardRepository _leaderboardRepo = LeaderboardRepository.instance;
  
  List<FriendWithStats> _friends = [];
  List<FriendRequest> _pendingRequests = [];
  List<LeaderboardEntry> _leaderboard = [];
  bool _showGlobalLeaderboard = true;
  bool _isLoading = false;
  String? _error;
  
  List<FriendWithStats> get friends => _friends;
  List<FriendRequest> get pendingRequests => _pendingRequests;
  List<LeaderboardEntry> get leaderboard => _leaderboard;
  bool get showGlobalLeaderboard => _showGlobalLeaderboard;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadFriends() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _friends = await _friendsRepo.getFriends();
      _pendingRequests = await _friendsRepo.getPendingRequests();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> loadLeaderboard() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      if (_showGlobalLeaderboard) {
        _leaderboard = await _leaderboardRepo.getGlobalLeaderboard();
      } else {
        _leaderboard = await _leaderboardRepo.getFriendsLeaderboard();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  void toggleLeaderboardType() {
    _showGlobalLeaderboard = !_showGlobalLeaderboard;
    loadLeaderboard();
  }
  
  Future<void> sendFriendRequest(String userId) async {
    try {
      await _friendsRepo.sendFriendRequest(userId);
      // Show success message via callback or snackbar
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> acceptRequest(String friendshipId) async {
    try {
      await _friendsRepo.acceptRequest(friendshipId);
      await loadFriends(); // Refresh
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> rejectRequest(String friendshipId) async {
    try {
      await _friendsRepo.rejectRequest(friendshipId);
      _pendingRequests.removeWhere((r) => r.id == friendshipId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> removeFriend(String friendshipId) async {
    try {
      await _friendsRepo.removeFriend(friendshipId);
      _friends.removeWhere((f) => f.friendshipId == friendshipId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
```

### Updated Page Implementations

#### Profile Page with Real Data

```dart
// lib/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/attendance_chart.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Load profile data when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/profile/settings'),
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (provider.error != null) {
            return _buildError(provider.error!);
          }
          
          if (provider.profile == null) {
            return Center(child: Text('No profile data'));
          }
          
          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfileHeader(provider),
                  SizedBox(height: 20),
                  _buildStatsCard(provider),
                  SizedBox(height: 20),
                  _buildAttendanceStats(provider),
                  SizedBox(height: 20),
                  if (provider.attendanceHistory != null)
                    _buildAttendanceChart(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildProfileHeader(ProfileProvider provider) {
    final user = provider.user!;
    
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: user.avatarUrl != null 
              ? NetworkImage(user.avatarUrl!) 
              : null,
          child: user.avatarUrl == null 
              ? Text(user.username[0].toUpperCase(), style: TextStyle(fontSize: 32))
              : null,
        ),
        SizedBox(height: 12),
        Text(
          user.username,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        if (user.universityId != null)
          Text(
            user.universityId!,
            style: TextStyle(color: Colors.grey),
          ),
      ],
    );
  }
  
  Widget _buildStatsCard(ProfileProvider provider) {
    final streak = provider.streak!;
    final points = provider.points!;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              icon: Icons.local_fire_department,
              iconColor: Colors.orange,
              value: '${streak.currentStreak}',
              label: 'Day Streak',
            ),
            _StatItem(
              icon: Icons.star,
              iconColor: Colors.amber,
              value: '${points.totalPoints}',
              label: 'Points',
            ),
            _StatItem(
              icon: Icons.ac_unit,
              iconColor: Colors.blue,
              value: '${streak.streakFreezes}',
              label: 'Freezes',
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAttendanceStats(ProfileProvider provider) {
    final stats = provider.stats!;
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _AttendanceRow(
              label: 'This Week',
              attended: stats.weeklyAttended,
              total: stats.weeklyTotal,
            ),
            Divider(),
            _AttendanceRow(
              label: 'This Month',
              attended: stats.monthlyAttended,
              total: stats.monthlyTotal,
            ),
            Divider(),
            _AttendanceRow(
              label: 'Overall',
              attended: stats.overallAttended,
              total: stats.overallTotal,
              showPercentage: true,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAttendanceChart(ProfileProvider provider) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last 30 Days',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: AttendanceChart(data: provider.attendanceHistory!),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 16),
          Text('Error loading profile'),
          SizedBox(height: 8),
          Text(error, style: TextStyle(color: Colors.grey)),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<ProfileProvider>().loadProfile(),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  
  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 32),
        SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  final String label;
  final int attended;
  final int total;
  final bool showPercentage;
  
  const _AttendanceRow({
    required this.label,
    required this.attended,
    required this.total,
    this.showPercentage = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (attended / total * 100).toStringAsFixed(0) : '0';
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              Text(
                '$attended / $total',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (showPercentage) ...[
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getPercentageColor(double.parse(percentage)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$percentage%',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
  
  Color _getPercentageColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }
}
```

#### Check-In Page with Real Data

```dart
// lib/pages/checkin_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/checkin_provider.dart';
import 'dart:async';

class CheckInPage extends StatefulWidget {
  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  Timer? _refreshTimer;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CheckInProvider>().loadCurrentState();
    });
    
    // Refresh every minute to update time displays
    _refreshTimer = Timer.periodic(Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check In'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => context.read<CheckInProvider>().refresh(),
          ),
        ],
      ),
      body: Consumer<CheckInProvider>(
        builder: (context, provider, child) {
          return _buildBody(context, provider);
        },
      ),
    );
  }
  
  Widget _buildBody(BuildContext context, CheckInProvider provider) {
    switch (provider.state) {
      case CheckInState.loading:
        return Center(child: CircularProgressIndicator());
        
      case CheckInState.error:
        return _buildError(provider);
        
      case CheckInState.noLecture:
        return _buildNoLecture(provider);
        
      case CheckInState.readyToCheckIn:
      case CheckInState.tooFarAway:
        return _buildReadyToCheckIn(provider);
        
      case CheckInState.checkingIn:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Checking in...'),
            ],
          ),
        );
        
      case CheckInState.checkedIn:
        return _buildCheckedIn(provider);
        
      case CheckInState.lectureEnded:
        return _buildLectureEnded(provider);
    }
  }
  
  Widget _buildNoLecture(CheckInProvider provider) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 64, color: Colors.grey),
            SizedBox(height: 24),
            Text(
              'No Lecture Right Now',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            if (provider.nextLecture != null) ...[
              Text('Next lecture:', style: TextStyle(color: Colors.grey)),
              SizedBox(height: 8),
              _LectureCard(lecture: provider.nextLecture!),
              SizedBox(height: 16),
              if (provider.timeUntilNext != null)
                Text(
                  'Starts in ${_formatDuration(provider.timeUntilNext!)}',
                  style: TextStyle(fontSize: 18, color: Colors.blue),
                ),
            ] else
              Text(
                'No upcoming lectures today',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildReadyToCheckIn(CheckInProvider provider) {
    final lecture = provider.currentLecture!;
    final isTooFar = provider.state == CheckInState.tooFarAway;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _LectureCard(lecture: lecture, showFullDetails: true),
          SizedBox(height: 24),
          
          // Distance indicator
          if (provider.distanceToLecture != null) ...[
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isTooFar ? Colors.orange.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isTooFar ? Icons.location_off : Icons.location_on,
                    color: isTooFar ? Colors.orange : Colors.green,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isTooFar
                          ? 'You are ${provider.distanceToLecture!.toStringAsFixed(0)}m away from the lecture'
                          : 'Location verified (${provider.distanceToLecture!.toStringAsFixed(0)}m)',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
          ],
          
          // Check-in button
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () => provider.checkIn(),
              style: ElevatedButton.styleFrom(
                backgroundColor: isTooFar ? Colors.orange : Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                isTooFar ? 'Check In Anyway (Reduced Points)' : 'Check In',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
          
          if (isTooFar) ...[
            SizedBox(height: 8),
            Text(
              'You\'ll earn 5 points instead of 10 without location verification',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildCheckedIn(CheckInProvider provider) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(Icons.check_circle, size: 80, color: Colors.green),
          SizedBox(height: 16),
          Text(
            'Checked In!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '+${provider.currentAttendance?.pointsEarned ?? 10} points',
            style: TextStyle(fontSize: 20, color: Colors.green),
          ),
          SizedBox(height: 24),
          
          if (provider.currentLecture != null)
            _LectureCard(lecture: provider.currentLecture!),
          
          SizedBox(height: 24),
          
          // Time remaining
          if (provider.timeRemaining != null)
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text('Time Remaining', style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 8),
                  Text(
                    _formatDuration(provider.timeRemaining!),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          
          SizedBox(height: 32),
          
          // Break lock button
          OutlinedButton(
            onPressed: () => _showBreakLockDialog(context, provider),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red),
            ),
            child: Text('End Session Early'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLectureEnded(CheckInProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.celebration, size: 64, color: Colors.amber),
          SizedBox(height: 16),
          Text(
            'Great Job!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Your lecture session has ended'),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => provider.refresh(),
            child: Text('Check for Next Lecture'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildError(CheckInProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text('Something went wrong'),
          if (provider.error != null)
            Text(provider.error!, style: TextStyle(color: Colors.grey)),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => provider.refresh(),
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }
  
  void _showBreakLockDialog(BuildContext context, CheckInProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('End Session Early?'),
        content: Text(
          'Ending early will reduce your points for this session from 10 to 5.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.breakLock();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('End Session'),
          ),
        ],
      ),
    );
  }
  
  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }
    return '${duration.inMinutes}m';
  }
}

class _LectureCard extends StatelessWidget {
  final dynamic lecture; // Lecture model
  final bool showFullDetails;
  
  const _LectureCard({
    required this.lecture,
    this.showFullDetails = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    lecture.moduleCode,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    lecture.title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(_formatTimeRange(lecture.startTime, lecture.endTime)),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(lecture.location),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatTimeRange(DateTime start, DateTime end) {
    final startStr = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final endStr = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    return '$startStr - $endStr';
  }
}
```

### Provider Setup in Main

```dart
// lib/main2.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/profile_provider.dart';
import 'providers/timetable_provider.dart';
import 'providers/checkin_provider.dart';
import 'providers/friends_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_ANON_KEY',
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => TimetableProvider()),
        ChangeNotifierProvider(create: (_) => CheckInProvider()),
        ChangeNotifierProvider(create: (_) => FriendsProvider()),
      ],
      child: MyApp(),
    ),
  );
}
```

---

## Services Implementation

### Location Service
```dart
class LocationService {
  static final LocationService instance = LocationService._();
  LocationService._();
  
  Future<bool> checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
           permission == LocationPermission.whileInUse;
  }
  
  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
  
  double calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
  
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}
```

### App Lock Service (Conceptual - Platform Specific)
```dart
class AppLockService {
  static final AppLockService instance = AppLockService._();
  AppLockService._();
  
  List<String> _allowedApps = [];
  Timer? _lockTimer;
  
  Future<void> startLock(DateTime endTime) async {
    // Load allowed apps from preferences
    final prefs = await SharedPreferences.getInstance();
    _allowedApps = prefs.getStringList('allowed_apps') ?? [];
    
    // Platform specific implementation needed
    // Android: Use DevicePolicyManager or AccessibilityService
    // iOS: Use Screen Time API (requires special entitlements)
    
    // Set timer to auto-unlock
    final duration = endTime.difference(DateTime.now());
    _lockTimer = Timer(duration, () {
      stopLock();
    });
  }
  
  Future<void> stopLock() async {
    _lockTimer?.cancel();
    // Platform specific unlock implementation
  }
  
  Future<List<AppInfo>> getInstalledApps() async {
    // Platform specific - get list of installed apps
    // Return mock data for now
    return [
      AppInfo(name: 'Notes', packageName: 'com.example.notes'),
      AppInfo(name: 'Calculator', packageName: 'com.example.calc'),
      AppInfo(name: 'Canvas', packageName: 'com.instructure.canvas'),
    ];
  }
}
```

### Notification Service
```dart
class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();
  
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    await _notifications.initialize(
      InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
  }
  
  Future<void> scheduleL lectureReminder(Lecture lecture) async {
    final reminderTime = lecture.startTime.subtract(Duration(minutes: 15));
    
    await _notifications.zonedSchedule(
      lecture.id.hashCode,
      'Lecture Starting Soon',
      '${lecture.moduleCode} - ${lecture.title} at ${lecture.location}',
      TZDateTime.from(reminderTime, local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'lecture_reminders',
          'Lecture Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
  
  Future<void> showCheckInSuccess(int pointsEarned) async {
    await _notifications.show(
      0,
      'Check-in Successful!',
      'You earned $pointsEarned points. Your apps are now locked.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'check_in',
          'Check In',
          importance: Importance.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
```

---

## Component Specifications

### Common Components

#### Custom App Bar
```dart
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? bottom;
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      actions: actions,
      bottom: bottom,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: Theme.of(context).textTheme.headlineLarge?.color,
    );
  }
  
  @override
  Size get preferredSize => Size.fromHeight(
    bottom != null ? 100.0 : 56.0,
  );
}
```

#### Loading Indicator
```dart
class LoadingIndicator extends StatelessWidget {
  final String? message;
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          if (message != null) ...[
            SizedBox(height: 16),
            Text(message!),
          ],
        ],
      ),
    );
  }
}
```

#### Empty State Widget
```dart
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (subtitle != null) ...[
              SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
```

#### Stats Card
```dart
class StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: iconColor),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Error Handling

### Global Error Handler
```dart
class ErrorHandler {
  static void handleError(BuildContext context, dynamic error) {
    String message = 'An error occurred';

    if (error is PostgrestException) {
      message = error.message;
    } else if (error is AuthException) {
      message = error.message;
    } else if (error is Exception) {
      message = error.toString();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  static Widget errorWidget(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}
```

---

## Testing Approach

### Unit Tests
- Test all providers
- Test data models
- Test services

### Widget Tests
- Test individual pages
- Test navigation
- Test state changes

### Integration Tests
- Test complete user flows
- Test Supabase integration
- Test location services

---

This specification provides complete implementation details for every page and component. Each section includes the exact layout, required functionality, data flow, and code structure needed to build the app. Use this as your reference when implementing each feature.