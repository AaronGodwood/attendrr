import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/timetable_provider.dart';
import '../widgets/timetable/lecture_card.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimetableProvider>().loadWeek();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () => context.read<TimetableProvider>().goToToday(),
          ),
        ],
      ),
      body: Consumer<TimetableProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Week selector
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: provider.previousWeek,
                    ),
                    Text(
                      _formatWeek(provider.selectedWeek),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: provider.nextWeek,
                    ),
                  ],
                ),
              ),

              // Loading/Error/Content
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.error != null
                    ? Center(child: Text(provider.error!))
                    : provider.lectures.isEmpty
                    ? _buildEmpty()
                    : _buildCalendar(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No lectures this week', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text('Import your timetable in Settings', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildCalendar(TimetableProvider provider) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

    return Column(
      children: [
        // Day headers
        Container(
          height: 40,
          child: Row(
            children: days.asMap().entries.map((e) {
              final dayNum = e.key + 1;
              final date = provider.selectedWeek.add(Duration(days: e.key));
              final isToday = _isToday(date);

              return Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isToday ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(e.value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isToday ? Theme.of(context).primaryColor : null)),
                      Text('${date.day}', style: TextStyle(fontSize: 12, color: isToday ? Theme.of(context).primaryColor : Colors.grey)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Lectures
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(5, (dayIndex) {
                final dayLectures = provider.lecturesByDay[dayIndex + 1] ?? [];
                return Expanded(
                  child: Column(
                    children: dayLectures.map((l) => LectureCard(lectureWithAttendance: l)).toList(),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  String _formatWeek(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    final format = DateFormat('MMM d');
    return '${format.format(weekStart)} - ${format.format(weekEnd)}';
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}