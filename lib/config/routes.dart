import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/profile/presentation/pages/settings_page.dart';
import '../features/timetable/presentation/pages/timetable_page.dart';
import '../features/attendance/presentation/pages/check_in_page.dart';
import '../features/attendance/presentation/pages/attendance_history_page.dart';
import '../features/attendance/presentation/pages/lecture_lock_page.dart';
import '../features/social/presentation/pages/friends_leaderboard_page.dart';
import '../features/social/presentation/pages/friend_requests_page.dart';
import '../features/social/presentation/pages/add_friend_page.dart';
import '../features/gamification/presentation/pages/achievements_page.dart';
import '../features/gamification/presentation/pages/streak_details_page.dart';
import '../features/debug/supabase_test_page.dart';

class AppRoutes {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();
  
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // Splash Screen
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),

      // Authentication Routes (outside shell - full screen)
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // Main app shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // Timetable tab
          GoRoute(
            path: '/timetable',
            builder: (context, state) => const TimetablePage(),
          ),

          // Profile tab
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
            routes: [
              GoRoute(
                path: 'settings',
                builder: (context, state) => const SettingsPage(),
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

          // Friends & Leaderboard tab
          GoRoute(
            path: '/friends',
            builder: (context, state) => const FriendsLeaderboardPage(),
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
        ],
      ),

      // Debug/Test routes (outside shell - full screen)
      GoRoute(
        path: '/test',
        builder: (context, state) => const SupabaseTestPage(),
      ),
    ],
  );
}

// Main shell with bottom navigation
class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateIndex(int newIndex) {
    if (_currentIndex != newIndex) {
      setState(() {
        _animation = Tween<double>(
          begin: _currentIndex.toDouble(),
          end: newIndex.toDouble(),
        ).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
        );
        _currentIndex = newIndex;
      });
      _animationController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    if (_currentIndex != selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateIndex(selectedIndex);
      });
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomAppBar(
          elevation: 0,
          padding: EdgeInsets.zero,
          child: SizedBox(
            height: 70,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / 4;
                final circleSize = 50.0;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Animated circle indicator (behind the icons)
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Positioned(
                          left: (itemWidth * _animation.value) + (itemWidth - circleSize) / 2,
                          top: 15,
                          child: Container(
                            width: circleSize,
                            height: circleSize,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    ),
                    // Navigation items (in front of the circle)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(Icons.calendar_today, 0, context),
                        _buildNavItem(Icons.location_on, 1, context),
                        _buildNavItem(Icons.leaderboard, 2, context),
                        _buildNavItem(Icons.person, 3, context),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, BuildContext context) {
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? Theme.of(context).primaryColor
        : Colors.grey.shade600;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index, context),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/timetable')) return 0;
    if (location.startsWith('/checkin')) return 1;
    if (location.startsWith('/friends')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/timetable');
        break;
      case 1:
        GoRouter.of(context).go('/checkin');
        break;
      case 2:
        GoRouter.of(context).go('/friends');
        break;
      case 3:
        GoRouter.of(context).go('/profile');
        break;
    }
  }
}

