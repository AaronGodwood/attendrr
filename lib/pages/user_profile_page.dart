import 'package:flutter/material.dart';
import '../models/models.dart';
import '../repositories/user_repository.dart';
import '../repositories/attendance_repository.dart';
import '../widgets/profile/stats_card.dart';
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
      // Load user profile data for the specific user
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
      body: _isLoading
          ? const ProfileSkeleton()
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
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
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _user?.avatarUrl != null
                              ? NetworkImage(_user!.avatarUrl!)
                              : null,
                          child: _user?.avatarUrl == null
                              ? Text(
                                  _user?.initials ?? '?',
                                  style: const TextStyle(fontSize: 32),
                                )
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _user?.username ?? widget.username,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_user?.universityId != null)
                          Text(
                            _user!.universityId!,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        const SizedBox(height: 20),

                        // Stats Card
                        if (_streak != null && _points != null)
                          StatsCard(streak: _streak!, points: _points!),
                        const SizedBox(height: 20),

                        // Attendance Stats
                        if (_stats != null) ...[
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Attendance',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildStatRow(
                                    'This Week',
                                    _stats!.weeklyAttended,
                                    _stats!.weeklyTotal,
                                  ),
                                  const Divider(),
                                  _buildStatRow(
                                    'This Month',
                                    _stats!.monthlyAttended,
                                    _stats!.monthlyTotal,
                                  ),
                                  const Divider(),
                                  _buildStatRow(
                                    'Overall',
                                    _stats!.overallAttended,
                                    _stats!.overallTotal,
                                    showPercent: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Attendance Chart
                        if (_history != null && _history!.isNotEmpty)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Last 30 Days',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 100,
                                    child: AttendanceChart(data: _history!),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatRow(String label, int attended, int total,
      {bool showPercent = false}) {
    final percent = total > 0 ? (attended / total * 100).round() : 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              Text(
                '$attended / $total',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (showPercent) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: percent >= 80
                        ? Colors.green
                        : percent >= 60
                            ? Colors.orange
                            : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$percent%',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
