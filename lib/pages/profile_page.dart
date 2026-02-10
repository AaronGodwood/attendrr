import 'package:flutter/foundation.dart' show kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile/stats_card.dart';
import '../widgets/profile/attendance_chart.dart';
import '../widgets/profile/profile_skeleton.dart';

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
            return const ProfileSkeleton();
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
                  GestureDetector(
                    onTap: () => _showAvatarOptions(context, provider),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty ? NetworkImage(user.avatarUrl!) : null,
                          child: user.avatarUrl == null || user.avatarUrl!.isEmpty ? Text(user.initials, style: const TextStyle(fontSize: 32)) : null,
                        ),
                        if (provider.isUploading)
                          const Positioned.fill(
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.black38,
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          )
                        else
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
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

  bool get _isMobilePlatform {
    if (kIsWeb) return false;
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.android || platform == TargetPlatform.iOS;
  }

  void _showAvatarOptions(BuildContext context, ProfileProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isMobilePlatform)
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, provider);
                },
              ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, provider);
              },
            ),
            if (provider.user?.avatarUrl != null && provider.user!.avatarUrl!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  provider.removeAvatar();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, ProfileProvider provider) async {
    try {
      if (_isMobilePlatform) {
        final picker = ImagePicker();
        final image = await picker.pickImage(source: source, maxWidth: 512, maxHeight: 512, imageQuality: 75);
        if (image != null) {
          provider.updateAvatar(image);
        }
      } else {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        if (result != null && result.files.single.path != null) {
          provider.updateAvatar(XFile(result.files.single.path!));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open image picker')),
        );
      }
    }
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