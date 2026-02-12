import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../models/lecture.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _configureLocalTimezone();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _notifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: iosSettings,
      ),
    );

    _isInitialized = true;
  }

  Future<bool> requestPermissions() async {
    bool granted = false;

    // Android permissions
    final androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final androidResult =
          await androidImplementation.requestNotificationsPermission();
      if (androidResult != null) {
        granted = granted || androidResult;
      }
    }

    // iOS permissions
    final iosImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosImplementation != null) {
      final iosResult = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (iosResult != null) {
        granted = granted || iosResult;
      }
    }

    // macOS permissions
    final macImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>();
    if (macImplementation != null) {
      final macResult = await macImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (macResult != null) {
        granted = granted || macResult;
      }
    }

    return granted;
  }

  Future<void> scheduleLectureReminder(
    Lecture lecture, {
    int minutesBefore = 15,
  }) async {
    final reminderTime = lecture.startTime.subtract(
      Duration(minutes: minutesBefore),
    );
    if (reminderTime.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      lecture.id.hashCode,
      'Lecture Starting Soon',
      '${lecture.moduleCode} - ${lecture.title} at ${lecture.location}',
      tz.TZDateTime.from(reminderTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'lecture_reminders',
          'Lecture Reminders',
          channelDescription: 'Notifications for upcoming lectures',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
        macOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> showCheckInSuccess(int points) async {
    await _notifications.show(
      0,
      'Check-in Successful! 🎉',
      'You earned $points points',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'check_in',
          'Check In Notifications',
          channelDescription: 'Notifications for check-in events',
          importance: Importance.high,
        ),
        iOS: const DarwinNotificationDetails(),
        macOS: const DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancelLectureReminder(String lectureId) async {
    await _notifications.cancel(lectureId.hashCode);
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  Future<void> _configureLocalTimezone() async {
    tz_data.initializeTimeZones();

    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      final location = tz.getLocation(timezoneName);
      tz.setLocalLocation(location);
    } catch (_) {
      // Keep default timezone if lookup fails on the current device.
    }
  }
}
