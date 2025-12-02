import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/lecture.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');


    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _notifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings,
      macOS: iosSettings),
    );
  }

  Future<void> requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleLectureReminder(Lecture lecture, {int minutesBefore = 15}) async {
    final reminderTime = lecture.startTime.subtract(Duration(minutes: minutesBefore));
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
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
}