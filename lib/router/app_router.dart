import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
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

  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isAuthRoute = state.matchedLocation == '/login' ||
            state.matchedLocation == '/signup' ||
            state.matchedLocation == '/forgot-password' ||
            state.matchedLocation == '/';

        // Not authenticated and not on auth route -> redirect to login
        if (!isAuthenticated && !isAuthRoute) {
          return '/login';
        }

        // Authenticated and on auth route (except splash) -> redirect to timetable
        if (isAuthenticated && isAuthRoute && state.matchedLocation != '/') {
          return '/timetable';
        }

        return null;
      },
      routes: [
        // Splash
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashPage(),
        ),

        // Auth routes
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignUpPage(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordPage(),
        ),

        // Main app shell with bottom navigation
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => HomePage(child: child),
          routes: [
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) => const NoTransitionPage(child: ProfilePage()),
              routes: [
                GoRoute(
                  path: 'settings',
                  builder: (context, state) => const SettingsPage(),
                ),
              ],
            ),
            GoRoute(
              path: '/timetable',
              pageBuilder: (context, state) => const NoTransitionPage(child: TimetablePage()),
            ),
            GoRoute(
              path: '/checkin',
              pageBuilder: (context, state) => const NoTransitionPage(child: CheckInPage()),
            ),
            GoRoute(
              path: '/friends',
              pageBuilder: (context, state) => const NoTransitionPage(child: FriendsPage()),
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Page not found: ${state.matchedLocation}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/timetable'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}