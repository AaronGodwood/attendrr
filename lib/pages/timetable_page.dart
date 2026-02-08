import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/timetable_provider.dart';
import '../models/lecture.dart';
import '../widgets/timetable/timetable_skeleton.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  final ScrollController _timeScrollController = ScrollController();
  final ScrollController _labelScrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimetableProvider>().loadWeek(_selectedDate);
      _scrollToCurrentTime();
    });

    // Sync scroll controllers
    _timeScrollController.addListener(_syncScroll);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timeScrollController.removeListener(_syncScroll);
    _timeScrollController.dispose();
    _labelScrollController.dispose();
    super.dispose();
  }

  void _syncScroll() {
    if (_labelScrollController.hasClients && _timeScrollController.hasClients) {
      _labelScrollController.jumpTo(_timeScrollController.offset);
    }
  }

  void _scrollToCurrentTime() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_timeScrollController.hasClients) {
        final now = DateTime.now();
        double scrollPosition;

        if (_isToday(_selectedDate)) {
          // For today, scroll to current time minus 2 hours for context
          final hour = now.hour;
          scrollPosition = ((hour - 2).clamp(0, 24) * 60.0);
        } else {
          // For other days, scroll to 8 AM (middle of typical day)
          scrollPosition = 8 * 60.0;
        }

        _timeScrollController.animateTo(
          scrollPosition,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _goToPreviousDay() {
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward(from: 0.0);

    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
    final provider = context.read<TimetableProvider>();
    if (!_isSameWeek(_selectedDate, provider.selectedWeek)) {
      provider.loadWeek(_selectedDate);
    }
    _scrollToCurrentTime();
  }

  void _goToNextDay() {
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward(from: 0.0);

    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
    final provider = context.read<TimetableProvider>();
    if (!_isSameWeek(_selectedDate, provider.selectedWeek)) {
      provider.loadWeek(_selectedDate);
    }
    _scrollToCurrentTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(DateFormat('MMMM yyyy').format(_selectedDate)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
              });
              context.read<TimetableProvider>().loadWeek(_selectedDate);
              _scrollToCurrentTime();
            },
          ),
        ],
      ),
      body: Consumer<TimetableProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const TimetableSkeleton();
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          return Column(
            children: [
              _buildDaySelector(provider),
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildDayView(provider),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDaySelector(TimetableProvider provider) {
    final weekStart = _getWeekStart(_selectedDate);
    final days = List.generate(7, (index) => weekStart.add(Duration(days: index)));

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Left arrow
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              HapticFeedback.lightImpact();
              _goToPreviousDay();
            },
            tooltip: 'Previous day',
          ),
          // Days selector
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate width for each day based on available space
                final availableWidth = constraints.maxWidth;
                final dayWidth = (availableWidth / 7).clamp(50.0, 80.0);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: days.map((date) {
                    final isSelected = _isSameDay(date, _selectedDate);
                    final isToday = _isToday(date);

                    final isDark = Theme.of(context).brightness == Brightness.dark;

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();

                        // Determine animation direction based on selected date
                        final dayDifference = date.difference(_selectedDate).inDays;

                        if (dayDifference != 0) {
                          _slideAnimation = Tween<Offset>(
                            begin: Offset(dayDifference > 0 ? 1.0 : -1.0, 0.0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeInOut,
                          ));

                          _animationController.forward(from: 0.0);
                        }

                        setState(() {
                          _selectedDate = date;
                        });
                        _scrollToCurrentTime();
                        // Load new week if needed
                        if (!_isSameWeek(_selectedDate, provider.selectedWeek)) {
                          provider.loadWeek(_selectedDate);
                        }
                      },
                      child: Container(
                        width: dayWidth,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : isToday
                                  ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                DateFormat('EEE').format(date).substring(0, 3),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : isToday
                                          ? Theme.of(context).primaryColor
                                          : isDark
                                              ? Colors.grey[300]
                                              : Colors.grey[600],
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${date.day}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : isToday
                                          ? Theme.of(context).primaryColor
                                          : isDark
                                              ? Colors.white
                                              : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          // Right arrow
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              HapticFeedback.lightImpact();
              _goToNextDay();
            },
            tooltip: 'Next day',
          ),
        ],
      ),
    );
  }

  Widget _buildDayView(TimetableProvider provider) {
    final dayLectures = provider.lectures
        .where((l) => _isSameDay(l.lecture.startTime, _selectedDate))
        .toList();

    if (provider.lectures.isEmpty) {
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

    if (dayLectures.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No lectures on ${DateFormat('EEEE, MMM d').format(_selectedDate)}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        // Time labels
        SizedBox(
          width: 60,
          child: SingleChildScrollView(
            controller: _labelScrollController,
            physics: const NeverScrollableScrollPhysics(),
            child: SizedBox(
              height: 24 * 60.0, // 24 hours * 60px per hour
              child: Column(
                children: List.generate(24, (hour) {
                  return SizedBox(
                    height: 60,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          _formatHour(hour),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),

        // Time slots with lectures
        Expanded(
          child: SingleChildScrollView(
            controller: _timeScrollController,
            physics: const ClampingScrollPhysics(),
            child: SizedBox(
              height: 24 * 60.0, // 24 hours * 60px per hour
              child: Stack(
                children: [
                  // Hour lines
                  Column(
                    children: List.generate(24, (hour) {
                      final now = DateTime.now();
                      final isCurrentHour = _isToday(_selectedDate) && now.hour == hour;

                      return Container(
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          color: isCurrentHour
                              ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
                              : null,
                        ),
                      );
                    }),
                  ),

                  // Current time indicator
                  if (_isToday(_selectedDate)) _buildCurrentTimeIndicator(),

                  // Lectures
                  ...dayLectures.map((lectureWithAttendance) {
                    final lecture = lectureWithAttendance.lecture;
                    return _buildLectureBlock(lecture, lectureWithAttendance);
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentTimeIndicator() {
    final now = DateTime.now();
    final minutesSinceMidnight = now.hour * 60 + now.minute;
    final topPosition = (minutesSinceMidnight / 60) * 60.0;

    return Positioned(
      top: topPosition,
      left: 0,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(
              height: 2,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLectureBlock(Lecture lecture, LectureWithAttendance lectureWithAttendance) {
    final startMinutes = lecture.startTime.hour * 60 + lecture.startTime.minute;
    final endMinutes = lecture.endTime.hour * 60 + lecture.endTime.minute;
    final durationMinutes = endMinutes - startMinutes;

    final topPosition = (startMinutes / 60) * 60.0;
    final height = (durationMinutes / 60) * 60.0;

    final status = lectureWithAttendance.status;
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get text color based on background
    final textColor = _getLectureTextColor(status, primaryColor, isDark);
    final secondaryTextColor = _getLectureSecondaryTextColor(status, primaryColor, isDark);

    // Determine what to show based on height
    final showTime = height > 65;

    return Positioned(
      top: topPosition,
      left: 8,
      right: 8,
      child: Container(
        height: height,
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: _getLectureBackgroundColor(status, primaryColor, isDark),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getLectureBorderColor(status, primaryColor, isDark),
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Module code and title on same line
                Row(
                  children: [
                    if (status == LectureStatus.attended)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.check_circle, size: 14, color: Colors.green),
                      )
                    else if (status == LectureStatus.missed)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.cancel, size: 14, color: Colors.red),
                      ),
                    Expanded(
                      child: RichText(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 12,
                            color: textColor,
                          ),
                          children: [
                            TextSpan(
                              text: lecture.moduleCode,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: ' ${lecture.title}',
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Location (always show if available)
                if (lecture.location.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 11,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          lecture.location,
                          style: TextStyle(
                            fontSize: 11,
                            color: secondaryTextColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
                // Time
                if (showTime) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 11,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        lecture.timeRange,
                        style: TextStyle(
                          fontSize: 10,
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getLectureBackgroundColor(LectureStatus status, Color primaryColor, bool isDark) {
    if (isDark) {
      // Use a nice green color for dark mode with slight translucency
      switch (status) {
        case LectureStatus.attended:
          return const Color(0xE62D5F2E); // Dark green with 90% opacity
        case LectureStatus.missed:
          return const Color(0xE65F2D2D); // Dark red with 90% opacity
        case LectureStatus.inProgress:
          return const Color(0xE62E4F3D); // Medium green with 90% opacity
        case LectureStatus.upcoming:
          return const Color(0xE6264033); // Softer green with 90% opacity
      }
    } else {
      // Light mode colors with slight translucency
      switch (status) {
        case LectureStatus.attended:
          return Colors.green.withValues(alpha: 0.12);
        case LectureStatus.missed:
          return Colors.red.withValues(alpha: 0.12);
        case LectureStatus.inProgress:
          return primaryColor.withValues(alpha: 0.2);
        case LectureStatus.upcoming:
          return primaryColor.withValues(alpha: 0.08);
      }
    }
  }

  Color _getLectureBorderColor(LectureStatus status, Color primaryColor, bool isDark) {
    if (isDark) {
      // Brighter borders for dark mode
      switch (status) {
        case LectureStatus.attended:
          return const Color(0xFF4CAF50); // Bright green
        case LectureStatus.missed:
          return const Color(0xFFEF5350); // Bright red
        case LectureStatus.inProgress:
          return const Color(0xFF66BB6A); // Light green
        case LectureStatus.upcoming:
          return const Color(0xFF4DB6AC); // Teal green
      }
    } else {
      // Light mode uses primary color
      return primaryColor;
    }
  }

  Color _getLectureTextColor(LectureStatus status, Color primaryColor, bool isDark) {
    if (isDark) {
      // Darker shade of the background color for text in dark mode
      switch (status) {
        case LectureStatus.attended:
          return const Color(0xFF93D693); // Lighter green
        case LectureStatus.missed:
          return const Color(0xFFE69393); // Lighter red
        case LectureStatus.inProgress:
          return const Color(0xFF7FD6A8); // Lighter medium green
        case LectureStatus.upcoming:
          return const Color(0xFF6BC9B8); // Lighter teal
      }
    } else {
      // Darker shade of the background color for text in light mode
      switch (status) {
        case LectureStatus.attended:
          return const Color(0xFF1B5E20); // Dark green
        case LectureStatus.missed:
          return const Color(0xFFB71C1C); // Dark red
        case LectureStatus.inProgress:
          return primaryColor.withValues(alpha: 0.9);
        case LectureStatus.upcoming:
          return primaryColor.withValues(alpha: 0.8);
      }
    }
  }

  Color _getLectureSecondaryTextColor(LectureStatus status, Color primaryColor, bool isDark) {
    if (isDark) {
      // Slightly muted version for secondary text in dark mode
      switch (status) {
        case LectureStatus.attended:
          return const Color(0xFF7ABF7A); // Muted lighter green
        case LectureStatus.missed:
          return const Color(0xFFCC7A7A); // Muted lighter red
        case LectureStatus.inProgress:
          return const Color(0xFF66BB8F); // Muted lighter medium green
        case LectureStatus.upcoming:
          return const Color(0xFF52AFA0); // Muted lighter teal
      }
    } else {
      // Muted darker shade for secondary text in light mode
      switch (status) {
        case LectureStatus.attended:
          return const Color(0xFF2E7D32); // Slightly lighter dark green
        case LectureStatus.missed:
          return const Color(0xFFC62828); // Slightly lighter dark red
        case LectureStatus.inProgress:
          return primaryColor.withValues(alpha: 0.75);
        case LectureStatus.upcoming:
          return primaryColor.withValues(alpha: 0.65);
      }
    }
  }

  String _formatHour(int hour) {
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  DateTime _getWeekStart(DateTime date) {
    return DateTime(date.year, date.month, date.day - (date.weekday - 1));
  }

  bool _isSameWeek(DateTime date1, DateTime date2) {
    final weekStart1 = _getWeekStart(date1);
    final weekStart2 = _getWeekStart(date2);
    return weekStart1.year == weekStart2.year &&
        weekStart1.month == weekStart2.month &&
        weekStart1.day == weekStart2.day;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}