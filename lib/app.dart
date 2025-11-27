import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/timetable/presentation/providers/timetable_provider.dart';
import 'features/attendance/presentation/providers/attendance_provider.dart';
import 'features/social/presentation/providers/friends_provider.dart';
import 'features/gamification/presentation/providers/gamification_provider.dart';
import 'config/themes.dart';
import 'config/routes.dart';

class LectureTrackerApp extends StatelessWidget {
  const LectureTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TimetableProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => FriendsProvider()),
        ChangeNotifierProvider(create: (_) => GamificationProvider()),
      ],
      child: MaterialApp.router(
        title: 'Lecture Tracker',
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRoutes.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}