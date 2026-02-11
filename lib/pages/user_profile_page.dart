import 'package:flutter/material.dart';
import '../models/models.dart';
import '../repositories/user_repository.dart';
import '../repositories/attendance_repository.dart';
import '../theme/theme_extensions.dart';
import '../widgets/common/grain_overlay.dart';
import '../widgets/profile/tier_progress_card.dart';
import '../widgets/profile/streak_card.dart';
import '../widgets/profile/attendance_ring_card.dart';
import '../widgets/profile/attendance_chart.dart';
import '../widgets/profile/profile_skeleton.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;
  final String username;

  const UserProfilePage({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _userRepo = UserRepository.instance;
  final _attendanceRepo = AttendanceRepository.instance;

  User? _user;
  Streak? _streak;
  Points? _points;
  AttendanceStats? _stats;
  List<DailyAttendance>? _history;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userData = await _userRepo.getUserProfile(widget.userId);
      final streakData = await _userRepo.getUserStreak(widget.userId);
      final pointsData = await _userRepo.getUserPoints(widget.userId);
      final statsData = await _attendanceRepo.getUserStats(widget.userId);
      final historyData = await _attendanceRepo.getUserHistory(widget.userId, 30);

      setState(() {
        _user = userData;
        _streak = streakData;
        _points = pointsData;
        _stats = statsData;
        _history = historyData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const ProfileSkeleton()
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Theme.of(context).extension<TerraThemeExtension>()?.danger,
                          ),
                          const SizedBox(height: 16),
                          Text(_error!),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadUserProfile,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadUserProfile,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Profile Header
                            _buildProfileHeader(),
                            const SizedBox(height: 20),

                            // Tier Progress
                            if (_points != null)
                              _animatedSection(
                                index: 0,
                                child: TierProgressCard(points: _points!),
                              ),
                            const SizedBox(height: 12),

                            // Streak
                            if (_streak != null)
                              _animatedSection(
                                index: 1,
                                child: StreakCard(streak: _streak!),
                              ),
                            const SizedBox(height: 12),

                            // Attendance Rings
                            if (_stats != null)
                              _animatedSection(
                                index: 2,
                                child: AttendanceRingCard(stats: _stats!),
                              ),
                            const SizedBox(height: 12),

                            // Attendance Chart
                            if (_history != null && _history!.isNotEmpty)
                              _animatedSection(
                                index: 3,
                                child: AttendanceChart(data: _history!),
                              ),
                          ],
                        ),
                      ),
                    ),
          const GrainOverlay(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final theme = Theme.of(context);
    final ext = theme.extension<TerraThemeExtension>();
    final hasAvatar = _user?.avatarUrl != null && _user!.avatarUrl!.isNotEmpty;

    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: hasAvatar ? NetworkImage(_user!.avatarUrl!) : null,
          child: !hasAvatar
              ? Text(_user?.initials ?? '?', style: const TextStyle(fontSize: 32))
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          _user?.username ?? widget.username,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (_user?.universityId != null)
          Text(
            _user!.universityId!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: ext?.textSecondary,
            ),
          ),
        if (_points != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: ext?.tierGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _points!.tierName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _animatedSection({required int index, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 80)),
      curve: Curves.easeOut,
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
    );
  }
}
