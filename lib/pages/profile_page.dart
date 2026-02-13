import 'package:flutter/foundation.dart' show kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/profile_provider.dart';
import '../theme/theme_extensions.dart';
import '../widgets/common/grain_overlay.dart';
import '../widgets/profile/tier_progress_card.dart';
import '../widgets/profile/streak_card.dart';
import '../widgets/profile/attendance_ring_card.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ProfileProvider>();
      await provider.loadProfile();
      if (!mounted) return;
      _showStreakNotification(provider);
    });
  }

  void _showStreakNotification(ProfileProvider provider) {
    final eval = provider.lastEvaluation;
    if (eval == null || !eval.hadChanges) return;

    final ext = Theme.of(context).extension<TerraThemeExtension>();

    if (eval.streakBroken) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Your streak was broken due to missed lectures.'),
          backgroundColor: ext?.danger,
          duration: const Duration(seconds: 4),
        ),
      );
    } else if (eval.freezesConsumed > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${eval.freezesConsumed} streak freeze${eval.freezesConsumed > 1 ? 's' : ''} '
            'used to protect your streak!',
          ),
          backgroundColor: ext?.tierIntermediate,
          duration: const Duration(seconds: 4),
        ),
      );
    }

    provider.clearEvaluation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.storefront),
            onPressed: () => context.push('/profile/shop'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/profile/settings'),
          ),
        ],
      ),
      body: Stack(
        children: [
          Consumer<ProfileProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const ProfileSkeleton();
              }

              if (provider.error != null) {
                final ext = Theme.of(context).extension<TerraThemeExtension>();
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: ext?.danger),
                      const SizedBox(height: 16),
                      Text(provider.error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: provider.refresh,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final user = provider.user;
              final streak = provider.streak;
              final points = provider.points;
              final stats = provider.stats;

              if (user == null)
                return const Center(child: Text('No profile data'));

              return RefreshIndicator(
                onRefresh: provider.refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Profile Header
                      _buildProfileHeader(context, provider, user, points),
                      const SizedBox(height: 20),

                      // Tier Progress
                      if (points != null)
                        _animatedSection(
                          index: 0,
                          child: TierProgressCard(points: points),
                        ),
                      const SizedBox(height: 12),

                      // Streak
                      if (streak != null)
                        _animatedSection(
                          index: 1,
                          child: StreakCard(streak: streak),
                        ),
                      const SizedBox(height: 12),

                      // Attendance Rings
                      if (stats != null)
                        _animatedSection(
                          index: 2,
                          child: AttendanceRingCard(stats: stats),
                        ),
                      const SizedBox(height: 12),

                      // Attendance Chart
                      if (provider.history != null &&
                          provider.history!.isNotEmpty)
                        _animatedSection(
                          index: 3,
                          child: AttendanceChart(data: provider.history!),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const GrainOverlay(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    ProfileProvider provider,
    dynamic user,
    dynamic points,
  ) {
    final theme = Theme.of(context);
    final ext = theme.extension<TerraThemeExtension>();

    return Column(
      children: [
        GestureDetector(
          onTap: () => _showAvatarOptions(context, provider),
          child: Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage:
                    user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                child:
                    user.avatarUrl == null || user.avatarUrl!.isEmpty
                        ? Text(
                          user.initials,
                          style: const TextStyle(fontSize: 32),
                        )
                        : null,
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
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          user.username,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (user.universityId != null)
          Text(
            user.universityId!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: ext?.textSecondary,
            ),
          ),
        if (points != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: ext?.tierGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              points.tierName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border.all(color: theme.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.monetization_on, size: 16, color: ext?.warning),
                const SizedBox(width: 6),
                Text(
                  '${points.totalPoints} coins',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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

  bool get _isMobilePlatform {
    if (kIsWeb) return false;
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.android || platform == TargetPlatform.iOS;
  }

  void _showAvatarOptions(BuildContext context, ProfileProvider provider) {
    final ext = Theme.of(context).extension<TerraThemeExtension>();
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
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
                if (provider.user?.avatarUrl != null &&
                    provider.user!.avatarUrl!.isNotEmpty)
                  ListTile(
                    leading: Icon(Icons.delete, color: ext?.danger),
                    title: Text(
                      'Remove photo',
                      style: TextStyle(color: ext?.danger),
                    ),
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
        final image = await picker.pickImage(
          source: source,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 75,
        );
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
}
