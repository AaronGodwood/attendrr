import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/checkin_provider.dart';
import '../models/lecture.dart';
import '../widgets/checkin/checkin_skeleton.dart';
import '../utils/checkin_refresh.dart';
import 'dart:async';

class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CheckInProvider>().loadState();
    });
    _scheduleNextRefresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
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
      body: Consumer<CheckInProvider>(
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
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Checking in...'),
                  ],
                ),
              );
            case CheckInState.checkedIn:
              return _buildCheckedIn(provider);
          }
        },
      ),
    );
  }

  Widget _buildError(CheckInProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(provider.error ?? 'Something went wrong'),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              'No Lecture Right Now',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (provider.nextLecture != null) ...[
              const Text('Next lecture:', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              _buildLectureCard(provider.nextLecture!),
              const SizedBox(height: 16),
              if (provider.timeUntilNext != null)
                Text(
                  'Starts in ${_formatDuration(provider.timeUntilNext! + const Duration(minutes: 1))}',
                  style: const TextStyle(fontSize: 18, color: Colors.blue),
                ),
            ] else
              const Text(
                'No upcoming lectures today',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReady(CheckInProvider provider) {
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isTooFar ? Colors.orange.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isTooFar ? Icons.location_off : Icons.location_on,
                    color: isTooFar ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isTooFar
                          ? 'You are ${provider.distance!.toStringAsFixed(0)}m away'
                          : 'Location verified (${provider.distance!.toStringAsFixed(0)}m)',
                    ),
                  ),
                ],
              ),
            ),
          if (!hasCoords)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.location_off, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Location unavailable; check-in allowed during lecture window',
                    ),
                  ),
                ],
              ),
            ),
          if (!withinWindow)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.access_time, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Check-in opens 10 minutes before the lecture'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: canCheckIn ? () => provider.checkIn() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canCheckIn ? Colors.green : Colors.grey,
              ),
              child: Text(
                canCheckIn
                    ? 'Check In (${provider.projectedPoints} pts)'
                    : 'Check In',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckedIn(CheckInProvider provider) {
    final lecture = provider.currentLecture;
    final isLectureActive = lecture?.isActive ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(Icons.check_circle, size: 80, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'Checked In!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '+${provider.activeAttendance?.pointsEarned ?? 10} points',
            style: const TextStyle(fontSize: 20, color: Colors.green),
          ),
          const SizedBox(height: 24),

          if (lecture != null) _buildLectureCard(lecture),
          const SizedBox(height: 24),

          if (provider.timeRemaining != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Time Remaining',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDuration(provider.timeRemaining!),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
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
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text('End Session Early'),
            ),
        ],
      ),
    );
  }

  Widget _buildLectureCard(Lecture lecture) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: lecture.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    lecture.moduleCode,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    lecture.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(lecture.timeRange),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(lecture.location),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckOutDialog(CheckInProvider provider) {
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
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('End Session'),
              ),
            ],
          ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0)
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    return '${duration.inMinutes}m';
  }
}
