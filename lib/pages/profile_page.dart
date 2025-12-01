import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile/stats_card.dart';
import '../widgets/profile/attendance_chart.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () => context.push('/profile/settings')),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: provider.refresh, child: const Text('Retry')),
                ],
              ),
            );
          }

          final user = provider.user;
          final streak = provider.streak;
          final points = provider.points;
          final stats = provider.stats;

          if (user == null) return const Center(child: Text('No profile data'));

          return RefreshIndicator(
            onRefresh: provider.refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Header
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                    child: user.avatarUrl == null ? Text(user.initials, style: const TextStyle(fontSize: 32)) : null,
                  ),
                  const SizedBox(height: 12),
                  Text(user.username, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  if (user.universityId != null) Text(user.universityId!, style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 20),

                  // Stats Card
                  if (streak != null && points != null)
                    StatsCard(streak: streak, points: points),
                  const SizedBox(height: 20),

                  // Attendance Stats
                  if (stats != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Attendance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            _buildStatRow('This Week', stats.weeklyAttended, stats.weeklyTotal),
                            const Divider(),
                            _buildStatRow('This Month', stats.monthlyAttended, stats.monthlyTotal),
                            const Divider(),
                            _buildStatRow('Overall', stats.overallAttended, stats.overallTotal, showPercent: true),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Attendance Chart
                  if (provider.history != null && provider.history!.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Last 30 Days', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            SizedBox(height: 100, child: AttendanceChart(data: provider.history!)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, int attended, int total, {bool showPercent = false}) {
    final percent = total > 0 ? (attended / total * 100).round() : 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              Text('$attended / $total', style: const TextStyle(fontWeight: FontWeight.bold)),
              if (showPercent) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: percent >= 80 ? Colors.green : percent >= 60 ? Colors.orange : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$percent%', style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}