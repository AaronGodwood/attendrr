import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/timetable/presentation/pages/timetable_page.dart';
import '../features/timetable/presentation/pages/link_timetable_page.dart';
import '../features/attendance/presentation/pages/check_in_page.dart';
import '../features/attendance/presentation/pages/attendance_history_page.dart';
import '../features/attendance/presentation/pages/lecture_lock_page.dart';
import '../features/social/presentation/pages/friends_list_page.dart';
import '../features/social/presentation/pages/friend_requests_page.dart';
import '../features/social/presentation/pages/add_friend_page.dart';
import '../features/gamification/presentation/pages/leaderboard_page.dart';
import '../features/gamification/presentation/pages/achievements_page.dart';
import '../features/gamification/presentation/pages/streak_details_page.dart';

class AppRoutes {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();
  
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      // Splash/Loading route
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Auth routes (outside of shell)
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/link-timetable',
        builder: (context, state) => const LinkTimetablePage(),
      ),
      
      // Main app shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // Home tab
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomePage(),
          ),
          
          // Timetable tab
          GoRoute(
            path: '/timetable',
            builder: (context, state) => const TimetablePage(),
          ),
          
          // Check-in tab
          GoRoute(
            path: '/checkin',
            builder: (context, state) => const CheckInPage(),
            routes: [
              GoRoute(
                path: 'lock',
                builder: (context, state) => const LectureLockPage(),
              ),
            ],
          ),
          
          // Leaderboard tab
          GoRoute(
            path: '/leaderboard',
            builder: (context, state) => const LeaderboardPage(),
          ),
          
          // Profile tab
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
            routes: [
              GoRoute(
                path: 'friends',
                builder: (context, state) => const FriendsListPage(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const AddFriendPage(),
                  ),
                  GoRoute(
                    path: 'requests',
                    builder: (context, state) => const FriendRequestsPage(),
                  ),
                ],
              ),
              GoRoute(
                path: 'achievements',
                builder: (context, state) => const AchievementsPage(),
              ),
              GoRoute(
                path: 'streaks',
                builder: (context, state) => const StreakDetailsPage(),
              ),
              GoRoute(
                path: 'history',
                builder: (context, state) => const AttendanceHistoryPage(),
              ),
            ],
          ),
        ],
      ),
    ],
    
    // Redirect logic for authentication
    redirect: (context, state) {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;
      
      // Define public routes that don't require authentication
      final publicRoutes = [
        '/splash',
        '/login',
        '/register',
        '/forgot-password',
      ];
      
      final isPublicRoute = publicRoutes.contains(state.uri.path);
      
      // If not authenticated and trying to access protected route
      if (session == null && !isPublicRoute) {
        return '/login';
      }
      
      // If authenticated and on auth pages, redirect to home
      if (session != null && (state.uri.path == '/login' || state.uri.path == '/register')) {
        return '/home';
      }
      
      return null;
    },
  );
}

// Main shell with bottom navigation
class MainShell extends StatelessWidget {
  final Widget child;
  
  const MainShell({super.key, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Timetable',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Check In',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
  
  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/timetable')) return 1;
    if (location.startsWith('/checkin')) return 2;
    if (location.startsWith('/leaderboard')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }
  
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/home');
        break;
      case 1:
        GoRouter.of(context).go('/timetable');
        break;
      case 2:
        GoRouter.of(context).go('/checkin');
        break;
      case 3:
        GoRouter.of(context).go('/leaderboard');
        break;
      case 4:
        GoRouter.of(context).go('/profile');
        break;
    }
  }
}

// Splash screen widget
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }
  
  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // Show splash for 2 seconds
    
    final supabase = Supabase.instance.client;
    if (supabase.auth.currentSession != null) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 20),
            const Text(
              'Lecture Tracker',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

// Placeholder for Profile Page
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile Page')),
    );
  }
}