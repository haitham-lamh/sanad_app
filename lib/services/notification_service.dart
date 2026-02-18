import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Riyadh'));

      print('=== Requesting notification permissions ===');
      final notificationStatus = await Permission.notification.status;
      print('Current notification permission status: $notificationStatus');
      
      if (notificationStatus.isDenied) {
        print('Requesting notification permission...');
        final requestedStatus = await Permission.notification.request();
        print('Notification permission request result: $requestedStatus');
      }

      if (await Permission.scheduleExactAlarm.isDenied) {
        print('Requesting schedule exact alarm permission...');
        final alarmStatus = await Permission.scheduleExactAlarm.request();
        print('Schedule exact alarm permission: $alarmStatus');
      }

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      print('Initializing FlutterLocalNotificationsPlugin...');
      final initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized == true) {
        _initialized = true;
        print('✅ Notifications initialized successfully');
      } else {
        print('❌ Notifications initialization returned false');
        _initialized = false;
      }

      final finalStatus = await Permission.notification.status;
      print('Final notification permission status: $finalStatus');
      
      if (finalStatus.isGranted) {
        print('✅ Notification permission granted');
      } else {
        print('⚠️ Notification permission not granted: $finalStatus');
      }
    } catch (e, stackTrace) {
      print('❌ Error initializing notifications: $e');
      print('Stack trace: $stackTrace');
      _initialized = false;
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
  }

  Future<void> scheduleTaskReminder({
    required int id,
    required String title,
    required String body,
    required DateTime taskDateTime,
    DateTime? scheduledAt,
  }) async {
    try {
      print('=== Scheduling system notification ===');
      print('Notification ID: $id');
      print('Title: $title');
      print('Body: $body');
      print('Task DateTime: $taskDateTime');

      await initialize();

      if (!_initialized) {
        print('❌ Notifications not initialized, skipping schedule');
        return;
      }

      final notificationStatus = await Permission.notification.status;
      if (!notificationStatus.isGranted) {
        print('❌ Notification permission not granted: $notificationStatus');
        print('Attempting to request permission again...');
        final requestedStatus = await Permission.notification.request();
        if (!requestedStatus.isGranted) {
          print('❌ Notification permission still not granted after request');
        return;
      }
      }

      final notificationTime =
          scheduledAt ?? taskDateTime.subtract(const Duration(hours: 1));
      print('Notification time: $notificationTime');
      print('Current time: ${DateTime.now()}');

      if (notificationTime.isBefore(DateTime.now())) {
        print('⚠️ Notification time is in the past, skipping');
        return;
      }

      final androidDetails = AndroidNotificationDetails(
        'task_reminders',
        'تذكيرات المهام',
        channelDescription: 'إشعارات تذكير بالمهام',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
        showWhen: true,
        when: notificationTime.millisecondsSinceEpoch,
        autoCancel: false,
        ongoing: false,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final scheduledTime = tz.TZDateTime.from(notificationTime, tz.local);
      print('Scheduled time (TZ): $scheduledTime');
      print('Scheduled time (UTC): ${scheduledTime.toUtc()}');
      print('Scheduled time (Local): ${scheduledTime.toLocal()}');

      bool canScheduleExact = true;
      try {
        if (await Permission.scheduleExactAlarm.isDenied) {
          final alarmStatus = await Permission.scheduleExactAlarm.request();
          canScheduleExact = alarmStatus.isGranted;
          print('Schedule exact alarm permission: $alarmStatus');
        }
      } catch (e) {
        print('Note: scheduleExactAlarm permission check failed (may not be available on this Android version): $e');
      }

      print('Attempting to schedule notification...');
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        notificationDetails,
        androidScheduleMode: canScheduleExact 
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: id.toString(),
      );

      print('✅ System notification scheduled successfully');
      print('Notification will appear at: $scheduledTime');
      
      try {
        final pendingNotifications = await _notifications.pendingNotificationRequests();
        final scheduledNotification = pendingNotifications.firstWhere(
          (n) => n.id == id,
          orElse: () => throw Exception('Notification not found in pending list'),
        );
        print('✅ Verified: Notification is in pending list');
        print('   Scheduled ID: ${scheduledNotification.id}');
        print('   Scheduled Title: ${scheduledNotification.title}');
      } catch (e) {
        print('⚠️ Could not verify notification in pending list: $e');
        print('   This is not necessarily an error - notification may still be scheduled');
      }
    } catch (e, stackTrace) {
      print('❌ Error scheduling notification: $e');
      print('Stack trace: $stackTrace');
      rethrow; // إعادة رمي الخطأ للمساعدة في التشخيص
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
