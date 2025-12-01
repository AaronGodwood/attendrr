import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  final Widget child;

  const HomePage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _calculateIndex(GoRouterState.of(context).matchedLocation),
        onTap: (index) => _onTap(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Timetable'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Check In'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Friends'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  int _calculateIndex(String location) {
    if (location.startsWith('/profile')) return 3;
    if (location.startsWith('/timetable')) return 0;
    if (location.startsWith('/checkin')) return 1;
    if (location.startsWith('/friends')) return 2;
    return 1;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/timetable'); break;
      case 1: context.go('/checkin'); break;
      case 2: context.go('/friends'); break;
      case 3: context.go('/profile'); break;
    }
  }
}