import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
import '../pages/user_profile_page.dart';
import '../pages/shop_page.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

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
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isAuthRoute =
            state.matchedLocation == '/login' ||
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

        // Main app shell with bottom navigation
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
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
                GoRoute(
                  path: 'shop',
                  builder: (context, state) => const ShopPage(),
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
            GoRoute(
              path: '/friends',
              pageBuilder:
                  (context, state) => _buildPageWithTransition(
                    context: context,
                    state: state,
                    child: const FriendsPage(),
                  ),
              routes: [
                GoRoute(
                  path: 'user/:userId/:username',
                  builder: (context, state) {
                    final userId = state.pathParameters['userId']!;
                    final username = Uri.decodeComponent(
                      state.pathParameters['username']!,
                    );
                    return UserProfilePage(userId: userId, username: username);
                  },
                ),
              ],
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
                  Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
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
