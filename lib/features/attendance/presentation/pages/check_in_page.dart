import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum CheckInState {
  noLecture,
  readyToCheckIn,
  checkingIn,
  checkedIn,
  lectureEnded,
}

class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  CheckInState _state = CheckInState.readyToCheckIn;
  double? _distance = 35.0; // Template distance in meters
  bool _appLockEnabled = false;
  int _allowedAppsCount = 3;

  // Template current lecture data
  final Map<String, dynamic> _currentLecture = {
    'moduleCode': 'CS101',
    'title': 'Introduction to Programming',
    'location': 'Room A101',
    'startTime': DateTime.now().add(const Duration(minutes: -10)),
    'endTime': DateTime.now().add(const Duration(hours: 1, minutes: 50)),
  };

  // Template next lecture data
  final Map<String, dynamic> _nextLecture = {
    'moduleCode': 'CS102',
    'title': 'Data Structures',
    'location': 'Room B203',
    'startTime': DateTime.now().add(const Duration(hours: 3)),
    'endTime': DateTime.now().add(const Duration(hours: 5)),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check In'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case CheckInState.noLecture:
        return _buildNoLectureView();
      case CheckInState.readyToCheckIn:
        return _buildReadyToCheckInView();
      case CheckInState.checkingIn:
        return _buildCheckingInView();
      case CheckInState.checkedIn:
        return _buildCheckedInView();
      case CheckInState.lectureEnded:
        return _buildLectureEndedView();
    }
  }

  Widget _buildNoLectureView() {
    final timeUntilNext = _nextLecture['startTime'].difference(DateTime.now());
    final hoursUntil = timeUntilNext.inHours;
    final minutesUntil = timeUntilNext.inMinutes % 60;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.event_busy,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'No Current Lecture',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'You don\'t have any lectures right now',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Next Lecture',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _nextLecture['moduleCode'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _nextLecture['title'],
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Starts in $hoursUntil hours $minutesUntil minutes',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                      ),
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

  Widget _buildReadyToCheckInView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Current Lecture Card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.book, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentLecture['moduleCode'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              _currentLecture['title'],
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${DateFormat('HH:mm').format(_currentLecture['startTime'])} - ${DateFormat('HH:mm').format(_currentLecture['endTime'])}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Expanded(child: Text(_currentLecture['location'])),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.navigation, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _distance != null
                            ? '${_distance!.toStringAsFixed(0)}m away'
                            : 'Calculating distance...',
                        style: TextStyle(
                          color: _distance != null && _distance! <= 50
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Check In Button
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _distance != null && _distance! <= 50
                  ? () {
                      setState(() => _state = CheckInState.checkingIn);
                      Future.delayed(const Duration(seconds: 2), () {
                        setState(() => _state = CheckInState.checkedIn);
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                _distance != null && _distance! <= 50
                    ? 'CHECK IN'
                    : 'Move closer to check in',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // App Lock Settings
          Card(
            child: ExpansionTile(
              title: const Text('App Lock Settings'),
              subtitle: const Text('Apps will be locked during lecture'),
              children: [
                SwitchListTile(
                  title: const Text('Enable App Lock'),
                  value: _appLockEnabled,
                  onChanged: (value) {
                    setState(() => _appLockEnabled = value);
                  },
                ),
                if (_appLockEnabled)
                  ListTile(
                    title: const Text('Manage Allowed Apps'),
                    subtitle: Text('$_allowedAppsCount apps allowed'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showAppSelector,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckingInView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(strokeWidth: 3),
          SizedBox(height: 24),
          Text(
            'Checking In...',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            'Verifying location and locking apps',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckedInView() {
    final endTime = _currentLecture['endTime'] as DateTime;
    final remaining = endTime.difference(DateTime.now());
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            const Text(
              'Checked In Successfully!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your apps are locked until the lecture ends',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Time Remaining',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${hours}h ${minutes}m',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Points Earned: +10',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 48),
            TextButton(
              onPressed: _showBreakLockWarning,
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Emergency: Break Lock'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLectureEndedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.celebration,
              size: 100,
              color: Colors.amber,
            ),
            const SizedBox(height: 24),
            const Text(
              'Lecture Ended!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Great job attending your lecture',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          icon: Icons.star,
                          color: Colors.amber,
                          value: '+10',
                          label: 'Points',
                        ),
                        _buildStatItem(
                          icon: Icons.local_fire_department,
                          color: Colors.orange,
                          value: '13',
                          label: 'Day Streak',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                setState(() => _state = CheckInState.noLecture);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  void _showAppSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Allowed Apps'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              CheckboxListTile(
                title: const Text('Notes'),
                value: true,
                onChanged: (value) {},
              ),
              CheckboxListTile(
                title: const Text('Calculator'),
                value: true,
                onChanged: (value) {},
              ),
              CheckboxListTile(
                title: const Text('Canvas'),
                value: true,
                onChanged: (value) {},
              ),
              CheckboxListTile(
                title: const Text('Instagram'),
                value: false,
                onChanged: (value) {},
              ),
              CheckboxListTile(
                title: const Text('TikTok'),
                value: false,
                onChanged: (value) {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showBreakLockWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Break Lock'),
        content: const Text(
          'Breaking the lock early will reduce your points for this lecture from 10 to 5. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              setState(() => _state = CheckInState.lectureEnded);
            },
            child: const Text('Break Lock'),
          ),
        ],
      ),
    );
  }
}

