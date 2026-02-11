import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/checkin_provider.dart';
import '../models/lecture.dart';
import '../widgets/checkin/checkin_skeleton.dart';
import '../widgets/common/grain_overlay.dart';
import '../widgets/common/gradient_text.dart';
import '../theme/colors.dart';
import '../theme/theme_extensions.dart';
import '../utils/checkin_refresh.dart';
import 'dart:async';

class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CheckInProvider>().loadState();
    });
    _scheduleNextRefresh();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _scheduleNextRefresh() {
    _timer?.cancel();
    final now = DateTime.now();
    final next = nextCheckInRefreshTime(now);
    final delay = next.difference(now);

    _timer = Timer(delay, () {
      if (!mounted) return;
      context.read<CheckInProvider>().loadState();
      _scheduleNextRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check In'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<CheckInProvider>().refresh(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Consumer<CheckInProvider>(
            builder: (context, provider, _) {
              switch (provider.state) {
                case CheckInState.loading:
                  return const CheckInSkeleton();
                case CheckInState.error:
                  return _buildError(provider);
                case CheckInState.noLecture:
                  return _buildNoLecture(provider);
                case CheckInState.readyToCheckIn:
                case CheckInState.tooFarAway:
                  return _buildReady(provider);
                case CheckInState.checkingIn:
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Checking in...',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  );
                case CheckInState.checkedIn:
                  return _buildCheckedIn(provider);
              }
            },
          ),
          const GrainOverlay(),
        ],
      ),
    );
  }

  Widget _buildError(CheckInProvider provider) {
    final ext = Theme.of(context).extension<TerraThemeExtension>();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: ext?.danger),
          const SizedBox(height: 16),
          Text(
            provider.error ?? 'Something went wrong',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: provider.refresh,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoLecture(CheckInProvider provider) {
    final theme = Theme.of(context);
    final ext = theme.extension<TerraThemeExtension>();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 64, color: ext?.textDisabled),
            const SizedBox(height: 24),
            Text(
              'No Lecture Right Now',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (provider.nextLecture != null) ...[
              Text(
                'Next lecture:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ext?.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              _buildLectureCard(provider.nextLecture!),
              const SizedBox(height: 16),
              if (provider.timeUntilNext != null)
                Text(
                  'Starts in ${_formatDuration(provider.timeUntilNext! + const Duration(minutes: 1))}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ] else
              Text(
                'No upcoming lectures today',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ext?.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReady(CheckInProvider provider) {
    final theme = Theme.of(context);
    final ext = theme.extension<TerraThemeExtension>();
    final isTooFar = provider.state == CheckInState.tooFarAway;
    final lecture = provider.currentLecture!;
    final hasCoords = lecture.hasValidCoordinates;
    final canCheckIn = provider.canCheckIn;
    final withinWindow = provider.isWithinWindow;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildLectureCard(lecture),
          const SizedBox(height: 24),

          if (provider.distance != null)
            _buildStatusBanner(
              icon: isTooFar ? Icons.location_off : Icons.location_on,
              text:
                  isTooFar
                      ? 'You are ${provider.distance!.toStringAsFixed(0)}m away'
                      : 'Location verified (${provider.distance!.toStringAsFixed(0)}m)',
              bgColor:
                  isTooFar
                      ? (ext?.warningContainer ??
                          theme.colorScheme.errorContainer)
                      : (ext?.successContainer ??
                          theme.colorScheme.primaryContainer),
              iconColor:
                  isTooFar
                      ? (ext?.warning ?? theme.colorScheme.error)
                      : (ext?.success ?? theme.colorScheme.primary),
            ),
          if (!hasCoords)
            _buildStatusBanner(
              icon: Icons.location_off,
              text:
                  'Location unavailable; check-in allowed during lecture window',
              bgColor:
                  ext?.warningContainer ?? theme.colorScheme.errorContainer,
              iconColor: ext?.warning ?? theme.colorScheme.error,
            ),
          if (!withinWindow)
            _buildStatusBanner(
              icon: Icons.access_time,
              text: 'Check-in opens 10 minutes before the lecture',
              bgColor:
                  ext?.primaryContainer ?? theme.colorScheme.primaryContainer,
              iconColor: theme.colorScheme.primary,
            ),
          const SizedBox(height: 24),

          // Gradient check-in button with pulse
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: canCheckIn ? _pulseAnimation.value : 1.0,
                child: child,
              );
            },
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient:
                      canCheckIn
                          ? (ext?.checkinSuccessGradient ??
                              LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.secondary,
                                ],
                              ))
                          : null,
                  color: canCheckIn ? null : (ext?.textDisabled ?? Colors.grey),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ElevatedButton(
                  onPressed: canCheckIn ? () => provider.checkIn() : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    disabledBackgroundColor: ext?.textDisabled,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    canCheckIn
                        ? 'Check In (${provider.projectedPoints} pts)'
                        : 'Check In',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color:
                          canCheckIn
                              ? Colors.white
                              : (ext?.textSecondary ?? Colors.grey),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner({
    required IconData icon,
    required String text,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckedIn(CheckInProvider provider) {
    final theme = Theme.of(context);
    final ext = theme.extension<TerraThemeExtension>();
    final lecture = provider.currentLecture;
    final isLectureActive = lecture?.isActive ?? false;
    final pointsEarned = provider.activeAttendance?.pointsEarned ?? 10;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(Icons.check_circle, size: 80, color: ext?.success),
          const SizedBox(height: 16),
          Text(
            'Checked In!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          GradientText(
            '+$pointsEarned points',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            gradient: ext?.pointsGradient,
          ),
          const SizedBox(height: 24),

          if (lecture != null) _buildLectureCard(lecture),
          const SizedBox(height: 24),

          if (provider.timeRemaining != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                    ext?.primaryContainer ?? theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Time Remaining',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: ext?.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDuration(provider.timeRemaining!),
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 32),

          if (isLectureActive)
            OutlinedButton(
              onPressed: () => _showCheckOutDialog(provider),
              style: OutlinedButton.styleFrom(
                foregroundColor: ext?.danger,
                side: BorderSide(color: ext?.danger ?? theme.colorScheme.error),
              ),
              child: const Text('End Session Early'),
            ),
        ],
      ),
    );
  }

  Widget _buildLectureCard(Lecture lecture) {
    final theme = Theme.of(context);
    final ext = theme.extension<TerraThemeExtension>();
    final moduleColor =
        TerraColors.moduleColors[lecture.moduleCode.hashCode.abs() %
            TerraColors.moduleColors.length];

    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(width: 3, color: moduleColor, height: 90),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          lecture.moduleCode,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: moduleColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            lecture.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: ext?.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lecture.timeRange,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: ext?.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: ext?.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lecture.location,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: ext?.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckOutDialog(CheckInProvider provider) {
    final ext = Theme.of(context).extension<TerraThemeExtension>();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('End Session Early?'),
            content: const Text('Are you sure you want to end your session?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  provider.checkOut();
                },
                style: TextButton.styleFrom(foregroundColor: ext?.danger),
                child: const Text('End Session'),
              ),
            ],
          ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }
    return '${duration.inMinutes}m';
  }
}
