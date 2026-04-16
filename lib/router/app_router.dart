import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../pages/splash_page.dart';
import '../pages/login_page.dart';
import '../pages/signup_page.dart';
import '../pages/forgot_password_page.dart';
import '../pages/reset_password_page.dart';
import '../pages/home_page.dart';
import '../pages/profile_page.dart';
import '../pages/settings_page.dart';
import '../pages/timetable_page.dart';
import '../pages/checkin_page.dart';

class AppRouter {
  static Page _buildPageWithTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
    );
  }

  static GoRouter router(AuthProvider authProvider) {
    final rootNavigatorKey = GlobalKey<NavigatorState>();
    final shellNavigatorKey = GlobalKey<NavigatorState>();

    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isPasswordRecovery =
            authProvider.status == AuthStatus.passwordRecovery;
        final isAuthRoute =
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/signup' ||
            state.matchedLocation == '/forgot-password' ||
            state.matchedLocation == '/reset-password' ||
            state.matchedLocation == '/';

        if (isPasswordRecovery) {
          return state.matchedLocation == '/reset-password'
              ? null
              : '/reset-password';
        }

        if (state.matchedLocation == '/') {
          return isAuthenticated ? '/timetable' : '/login';
        }

        if (!isAuthenticated && !isAuthRoute) {
          return '/login';
        }

        if (isAuthenticated &&
            isAuthRoute &&
            state.matchedLocation != '/' &&
            state.matchedLocation != '/reset-password') {
          return '/timetable';
        }

        return null;
      },
      routes: [
        // Splash
        GoRoute(path: '/', builder: (context, state) => const SplashPage()),

        // Auth routes
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignUpPage(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordPage(),
        ),
        GoRoute(
          path: '/reset-password',
          builder: (context, state) => const ResetPasswordPage(),
        ),

        // Main app shell with bottom navigation
        ShellRoute(
          navigatorKey: shellNavigatorKey,
          builder: (context, state, child) => HomePage(child: child),
          routes: [
            GoRoute(
              path: '/profile',
              pageBuilder:
                  (context, state) => _buildPageWithTransition(
                    context: context,
                    state: state,
                    child: const ProfilePage(),
                  ),
              routes: [
                GoRoute(
                  path: 'settings',
                  builder: (context, state) => const SettingsPage(),
                ),
              ],
            ),
            GoRoute(
              path: '/timetable',
              pageBuilder:
                  (context, state) => _buildPageWithTransition(
                    context: context,
                    state: state,
                    child: const TimetablePage(),
                  ),
            ),
            GoRoute(
              path: '/checkin',
              pageBuilder:
                  (context, state) => _buildPageWithTransition(
                    context: context,
                    state: state,
                    child: const CheckInPage(),
                  ),
            ),
          ],
        ),
      ],
      errorBuilder:
          (context, state) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
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
