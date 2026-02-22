import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/timetable_provider.dart';
import '../models/lecture.dart';
import '../theme/colors.dart';
import '../theme/theme_extensions.dart';
import '../widgets/timetable/timetable_skeleton.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage>
    with SingleTickerProviderStateMixin {
  static const int _visibleStartHour = 7;
  static const int _visibleEndHour = 22; // 10pm
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
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TimetableProvider>().loadWeek(_selectedDate);
        _scrollToCurrentTime();
      }
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
          scrollPosition =
              ((hour - _visibleStartHour - 2).clamp(
                    0,
                    _visibleEndHour - _visibleStartHour,
                  ) *
                  60.0);
        } else {
          // For other days, scroll to 8 AM (middle of typical day)
          scrollPosition =
              (8 - _visibleStartHour).clamp(
                0,
                _visibleEndHour - _visibleStartHour,
              ) *
              60.0;
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
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

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
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

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
        title: const Text('Timetable'),
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
    final days = List.generate(
      7,
      (index) => weekStart.add(Duration(days: index)),
    );

    final theme = Theme.of(context);
    final ext = theme.extension<TerraThemeExtension>();

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline, width: 1),
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
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 40, height: 40),
            tooltip: 'Previous day',
          ),
          // Days selector
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                const spacing = 2.0;
                const minDayWidth = 32.0;
                final baseDayWidth = (availableWidth - (spacing * 6)) / 7;
                final dayWidth = baseDayWidth.clamp(minDayWidth, 72.0);
                final totalWidth = (dayWidth * 7) + (spacing * 6);

                Widget buildDayTile(DateTime date) {
                  final isSelected = _isSameDay(date, _selectedDate);
                  final isToday = _isToday(date);
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      final dayDifference =
                          date.difference(_selectedDate).inDays;
                      if (dayDifference != 0) {
                        _slideAnimation = Tween<Offset>(
                          begin: Offset(dayDifference > 0 ? 1.0 : -1.0, 0.0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeInOut,
                          ),
                        );
                        _animationController.forward(from: 0.0);
                      }
                      setState(() {
                        _selectedDate = date;
                      });
                      _scrollToCurrentTime();
                      if (!_isSameWeek(_selectedDate, provider.selectedWeek)) {
                        provider.loadWeek(_selectedDate);
                      }
                    },
                    child: Container(
                      width: dayWidth,
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? theme.colorScheme.primary
                                : isToday
                                ? (ext?.primaryContainer ??
                                    theme.colorScheme.primaryContainer)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('EEE').format(date).substring(0, 3),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: dayWidth < 36 ? 10 : 11,
                              fontWeight: FontWeight.w600,
                              color:
                                  isSelected
                                      ? theme.colorScheme.onPrimary
                                      : isToday
                                      ? theme.colorScheme.primary
                                      : ext?.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${date.day}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: dayWidth < 36 ? 14 : 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  isSelected
                                      ? theme.colorScheme.onPrimary
                                      : isToday
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (totalWidth <= availableWidth) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int index = 0; index < days.length; index++) ...[
                        buildDayTile(days[index]),
                        if (index < days.length - 1)
                          const SizedBox(width: spacing),
                      ],
                    ],
                  );
                }

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  itemCount: days.length,
                  separatorBuilder: (_, _) => const SizedBox(width: spacing),
                  itemBuilder: (context, index) => buildDayTile(days[index]),
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
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 40, height: 40),
            tooltip: 'Next day',
          ),
        ],
      ),
    );
  }

  Widget _buildDayView(TimetableProvider provider) {
    final dayLectures =
        provider.lectures
            .where((l) => _isSameDay(l.lecture.startTime, _selectedDate))
            .toList();

    final theme = Theme.of(context);
    final ext = theme.extension<TerraThemeExtension>();

    if (provider.lectures.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: ext?.textDisabled),
            const SizedBox(height: 16),
            Text('No lectures this week', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Import your timetable in Settings',
              style: TextStyle(color: ext?.textSecondary),
            ),
          ],
        ),
      );
    }

    if (dayLectures.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: ext?.textDisabled),
            const SizedBox(height: 16),
            Text(
              'No lectures on ${DateFormat('EEEE, MMM d').format(_selectedDate)}',
              style: theme.textTheme.bodyLarge,
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
              height: (_visibleEndHour - _visibleStartHour) * 60.0,
              child: Stack(
                children: List.generate(
                  _visibleEndHour - _visibleStartHour + 1,
                  (index) {
                    final hour = _visibleStartHour + index;
                    final top = (hour - _visibleStartHour) * 60.0;

                    return Positioned(
                      top: top,
                      right: 8,
                      child: Text(
                        _formatHour(hour),
                        style: TextStyle(
                          fontSize: 12,
                          color: ext?.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
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
              height: (_visibleEndHour - _visibleStartHour) * 60.0,
              child: Stack(
                children: [
                  // Hour lines
                  ...List.generate(_visibleEndHour - _visibleStartHour + 1, (
                    index,
                  ) {
                    final hour = _visibleStartHour + index;
                    final now = DateTime.now();
                    final isCurrentHour =
                        _isToday(_selectedDate) && now.hour == hour;
                    final top = (hour - _visibleStartHour) * 60.0;

                    return Positioned(
                      top: top,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 1,
                        color:
                            isCurrentHour
                                ? theme.colorScheme.primary.withValues(
                                  alpha: 0.2,
                                )
                                : theme.colorScheme.outline.withValues(
                                  alpha: 0.3,
                                ),
                      ),
                    );
                  }),

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
    final startMinutes = _visibleStartHour * 60;
    final endMinutes = _visibleEndHour * 60;

    if (minutesSinceMidnight < startMinutes ||
        minutesSinceMidnight > endMinutes) {
      return const SizedBox.shrink();
    }

    final topPosition = (minutesSinceMidnight - startMinutes).toDouble();

    final dangerColor =
        Theme.of(context).extension<TerraThemeExtension>()?.danger ??
        Theme.of(context).colorScheme.error;

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
              color: dangerColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(child: Container(height: 2, color: dangerColor)),
        ],
      ),
    );
  }

  Widget _buildLectureBlock(
    Lecture lecture,
    LectureWithAttendance lectureWithAttendance,
  ) {
    final startMinutes = lecture.startTime.hour * 60 + lecture.startTime.minute;
    final endMinutes = lecture.endTime.hour * 60 + lecture.endTime.minute;
    final visibleStart = _visibleStartHour * 60;
    final visibleEnd = _visibleEndHour * 60;
    final clippedStart = startMinutes.clamp(visibleStart, visibleEnd);
    final clippedEnd = endMinutes.clamp(visibleStart, visibleEnd);
    final durationMinutes = clippedEnd - clippedStart;

    if (durationMinutes <= 0) {
      return const SizedBox.shrink();
    }

    final topPosition = (clippedStart - visibleStart).toDouble();
    final height = durationMinutes.toDouble();

    final status = lectureWithAttendance.status;
    final themeData = Theme.of(context);
    final ext = themeData.extension<TerraThemeExtension>();

    // Module color for left-border accent
    final moduleColor =
        TerraColors.moduleColors[lecture.moduleCode.hashCode.abs() %
            TerraColors.moduleColors.length];

    // Status-dependent background tint
    final bgColor = switch (status) {
      LectureStatus.attended => (ext?.success ??
              themeData.colorScheme.secondary)
          .withValues(alpha: 0.1),
      LectureStatus.missed => (ext?.danger ?? themeData.colorScheme.error)
          .withValues(alpha: 0.1),
      LectureStatus.inProgress => moduleColor.withValues(alpha: 0.15),
      LectureStatus.upcoming => moduleColor.withValues(alpha: 0.08),
    };

    final textColor = themeData.colorScheme.onSurface;
    final secondaryTextColor =
        ext?.textSecondary ??
        themeData.colorScheme.onSurface.withValues(alpha: 0.6);

    // Status icon colors
    final statusIconColor = switch (status) {
      LectureStatus.attended => ext?.success,
      LectureStatus.missed => ext?.danger,
      _ => null,
    };

    // Determine what to show based on height
    final showTime = height > 65;
    final titleMaxLines = height > 72 ? 2 : 1;

    return Positioned(
      top: topPosition,
      left: 8,
      right: 8,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('lecture_${lecture.id}'),
          borderRadius: BorderRadius.circular(10),
          onTap: () => _showLectureDetails(lecture, lectureWithAttendance),
          child: Container(
            height: height,
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border(left: BorderSide(color: moduleColor, width: 3)),
            ),
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
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.check_circle,
                            size: 14,
                            color: statusIconColor,
                          ),
                        )
                      else if (status == LectureStatus.missed)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.cancel,
                            size: 14,
                            color: statusIconColor,
                          ),
                        ),
                      Expanded(
                        child: RichText(
                          overflow: TextOverflow.ellipsis,
                          maxLines: titleMaxLines,
                          text: TextSpan(
                            style: TextStyle(fontSize: 12, color: textColor),
                            children: [
                              TextSpan(
                                text: lecture.moduleCode,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: moduleColor,
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
      ),
    );
  }

  void _showLectureDetails(
    Lecture lecture,
    LectureWithAttendance lectureWithAttendance,
  ) {
    final status = lectureWithAttendance.status;
    final points = lectureWithAttendance.pointsEarned;
    final isWide = MediaQuery.of(context).size.width >= 700;

    final theme = Theme.of(context);
    final ext = theme.extension<TerraThemeExtension>();
    final moduleColor =
        TerraColors.moduleColors[lecture.moduleCode.hashCode.abs() %
            TerraColors.moduleColors.length];

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: moduleColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${lecture.moduleCode} • ${lecture.title}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.access_time, size: 16, color: ext?.textSecondary),
            const SizedBox(width: 6),
            Text(
              lecture.timeRange,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ext?.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.location_on, size: 16, color: ext?.textSecondary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                lecture.location,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ext?.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              status == LectureStatus.attended
                  ? Icons.check_circle
                  : status == LectureStatus.missed
                  ? Icons.cancel
                  : status == LectureStatus.inProgress
                  ? Icons.play_circle
                  : Icons.schedule,
              size: 16,
              color:
                  status == LectureStatus.attended
                      ? ext?.success
                      : status == LectureStatus.missed
                      ? ext?.danger
                      : theme.colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text('Status: ${status.name}', style: theme.textTheme.bodyMedium),
          ],
        ),
        if (points != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.star, size: 16, color: ext?.warning),
              const SizedBox(width: 6),
              Text(
                'Points: $points',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );

    if (isWide) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Lecture Details'),
              content: content,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder:
            (context) =>
                Padding(padding: const EdgeInsets.all(16), child: content),
      );
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
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
