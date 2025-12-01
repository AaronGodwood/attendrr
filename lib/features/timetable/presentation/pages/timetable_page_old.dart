import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  DateTime _selectedWeek = DateTime.now();

  // Template lecture data
  final List<Map<String, dynamic>> _lectures = [
    {
      'moduleCode': 'CS101',
      'title': 'Introduction to Programming',
      'location': 'Room A101',
      'startTime': DateTime.now()
          .subtract(Duration(days: DateTime.now().weekday - 1))
          .add(const Duration(hours: 9)),
      'endTime': DateTime.now()
          .subtract(Duration(days: DateTime.now().weekday - 1))
          .add(const Duration(hours: 11)),
      'attended': true,
    },
    {
      'moduleCode': 'CS102',
      'title': 'Data Structures',
      'location': 'Room B203',
      'startTime': DateTime.now()
          .subtract(Duration(days: DateTime.now().weekday - 1))
          .add(const Duration(hours: 13)),
      'endTime': DateTime.now()
          .subtract(Duration(days: DateTime.now().weekday - 1))
          .add(const Duration(hours: 15)),
      'attended': false,
    },
    {
      'moduleCode': 'MATH201',
      'title': 'Linear Algebra',
      'location': 'Room C305',
      'startTime': DateTime.now()
          .subtract(Duration(days: DateTime.now().weekday - 2))
          .add(const Duration(hours: 10)),
      'endTime': DateTime.now()
          .subtract(Duration(days: DateTime.now().weekday - 2))
          .add(const Duration(hours: 12)),
      'attended': true,
    },
    {
      'moduleCode': 'CS103',
      'title': 'Algorithms',
      'location': 'Room A102',
      'startTime': DateTime.now()
          .subtract(Duration(days: DateTime.now().weekday - 3))
          .add(const Duration(hours: 14)),
      'endTime': DateTime.now()
          .subtract(Duration(days: DateTime.now().weekday - 3))
          .add(const Duration(hours: 16)),
      'attended': null,
    },
    {
      'moduleCode': 'CS104',
      'title': 'Database Systems',
      'location': 'Room D401',
      'startTime': DateTime.now()
          .subtract(Duration(days: DateTime.now().weekday - 4))
          .add(const Duration(hours: 9)),
      'endTime': DateTime.now()
          .subtract(Duration(days: DateTime.now().weekday - 4))
          .add(const Duration(hours: 11)),
      'attended': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_view_week),
            onPressed: () {
              // Toggle view mode
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: _buildWeekSelector(),
        ),
      ),
      body: _buildWeekView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Syncing timetable...')),
          );
        },
        child: const Icon(Icons.sync),
      ),
    );
  }

  Widget _buildWeekSelector() {
    final weekStart = _getWeekStart(_selectedWeek);
    final weekEnd = weekStart.add(const Duration(days: 6));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedWeek = _selectedWeek.subtract(const Duration(days: 7));
              });
            },
          ),
          Text(
            '${DateFormat('MMM d').format(weekStart)} - ${DateFormat('MMM d, yyyy').format(weekEnd)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedWeek = _selectedWeek.add(const Duration(days: 7));
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekView() {
    return Column(
      children: [
        // Day headers
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        const Divider(height: 1),
        // Timetable grid
        Expanded(
          child: SingleChildScrollView(
            child: SizedBox(
              height: 600, // 10 hours * 60 pixels per hour
              child: Stack(
                children: [
                  // Time indicators
                  _buildTimeIndicators(),
                  // Lecture cards
                  ..._buildLectureCards(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeIndicators() {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: 60,
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Column(
          children: List.generate(11, (index) {
            final hour = index + 8; // Start from 8 AM
            return SizedBox(
              height: 60,
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  '$hour:00',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  List<Widget> _buildLectureCards() {
    return _lectures.map((lecture) {
      final startTime = lecture['startTime'] as DateTime;
      final endTime = lecture['endTime'] as DateTime;
      final dayIndex = startTime.weekday - 1; // 0-4 for Mon-Fri

      if (dayIndex < 0 || dayIndex > 4) return const SizedBox.shrink();

      final startMinutes = startTime.hour * 60 + startTime.minute;
      final duration = endTime.difference(startTime).inMinutes;
      final topPosition = ((startMinutes - 480) / 60) * 60; // 480 = 8am

      return Positioned(
        left: 60 + (dayIndex * ((MediaQuery.of(context).size.width - 60) / 5)),
        top: topPosition,
        width: ((MediaQuery.of(context).size.width - 60) / 5) - 4,
        height: (duration / 60) * 60,
        child: _buildLectureCard(lecture),
      );
    }).toList();
  }

  Widget _buildLectureCard(Map<String, dynamic> lecture) {
    final attended = lecture['attended'] as bool?;
    final endTime = lecture['endTime'] as DateTime;

    Color backgroundColor;
    if (attended == true) {
      backgroundColor = Colors.green.shade100;
    } else if (attended == false || endTime.isBefore(DateTime.now())) {
      backgroundColor = Colors.red.shade100;
    } else {
      backgroundColor = Colors.blue.shade100;
    }

    return Card(
      margin: const EdgeInsets.all(2),
      color: backgroundColor,
      child: InkWell(
        onTap: () => _showLectureDetails(lecture),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lecture['moduleCode'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                lecture['title'],
                style: const TextStyle(fontSize: 9),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 9),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      lecture['location'],
                      style: const TextStyle(fontSize: 9),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLectureDetails(Map<String, dynamic> lecture) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lecture['moduleCode']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lecture['title'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat('HH:mm').format(lecture['startTime'])} - ${DateFormat('HH:mm').format(lecture['endTime'])}',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 8),
                Text(lecture['location']),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(DateFormat('EEEE, MMM d, yyyy')
                    .format(lecture['startTime'])),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }
}
