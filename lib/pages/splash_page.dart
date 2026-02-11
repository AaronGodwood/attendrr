import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    if (auth.isAuthenticated) {
      context.go('/timetable');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFC67B4E), // Terracotta
              Color(0xFF1A1714), // Dark charcoal
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8D5B7), // Cream accent
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.school,
                  size: 64,
                  color: Color(0xFFC67B4E),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Attendr',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE8D5B7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track your attendance, build your streak',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFFE8D5B7).withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8D5B7)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
