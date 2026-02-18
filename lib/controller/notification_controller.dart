import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sanad_app/config/app_theme.dart';
import 'package:sanad_app/controller/task_controller.dart';
import 'package:sanad_app/model/notification_model.dart';
import 'package:sanad_app/model/task_model.dart';
import 'package:sanad_app/services/notification_service.dart';
import '../db/db_helper.dart';

class NotificationController extends GetxController {
  final NotificationService _notificationService = NotificationService();
  var notifications = <NotificationModel>[].obs;
  Timer? _refreshTimer;
  Set<String> _shownNotificationIds = {};

  static const String _tableName = 'notifications';

  @override
  void onReady() {
    super.onReady();
    _init();
  }

  Future<void> _init() async {
    await _initializeDatabase();
    await loadNotifications();
    _scheduleExistingTasks();
    _startRefreshTimer();
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => loadNotifications(),
    );
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  Future<void> _scheduleExistingTasks() async {
    if (Get.isRegistered<TaskController>()) {
      final taskController = Get.find<TaskController>();
      taskController.getTasks();
      await Future.delayed(const Duration(milliseconds: 500));
      for (final task in taskController.taskList) {
        if ((task.isCompleted ?? 0) == 0 && task.dueDate != null) {
          await createTaskReminder(task);
        }
      }
    }
  }

  Future<void> createTestNotification({
    required String title,
    required String message,
    required DateTime notificationTime,
  }) async {
    try {
      if (notificationTime.isBefore(DateTime.now())) {
        print('Test notification time is in the past');
        return;
      }

      final notification = NotificationModel(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        message: message,
        dateTime: notificationTime,
        isRead: false,
        icon: Icons.notifications_active_rounded,
        iconColor: const Color(0xFF6366F1),
        taskId: null,
      );

      await _saveNotification(notification);

      await _notificationService.scheduleTaskReminder(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: title,
        body: message,
        taskDateTime: notificationTime.add(const Duration(hours: 1)),
      );

      await loadNotifications();

      if (notificationTime.isBefore(
        DateTime.now().add(const Duration(seconds: 5)),
      )) {
        _showNotificationSnackBar(notification);
        _shownNotificationIds.add(notification.id);
      }

      print('Test notification created for: $notificationTime');
    } catch (e) {
      print('Error creating test notification: $e');
    }
  }

  Future<void> _initializeDatabase() async {
    final db = await DBHelper.instance.mydb;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName(
        id TEXT PRIMARY KEY,
        title TEXT,
        message TEXT,
        dateTime TEXT,
        isRead INTEGER,
        iconCode INTEGER,
        iconColor INTEGER,
        taskId TEXT
      )
    ''');
  }

  Future<void> loadNotifications() async {
    try {
      await _initializeDatabase();
      final db = await DBHelper.instance.mydb;
      final results = await db.query(_tableName, orderBy: 'dateTime DESC');
      final newNotifications = results.map((row) => _fromMap(row)).toList();

      final now = DateTime.now();
      final newDueNotifications =
          newNotifications.where((n) {
            final timeDiff = now.difference(n.dateTime);
            final isDue = !n.dateTime.isAfter(now) && timeDiff.inSeconds < 5;
            final isNew = !_shownNotificationIds.contains(n.id);
            return isDue && isNew;
          }).toList();

      for (final notification in newDueNotifications) {
        _showNotificationSnackBar(notification);
        _shownNotificationIds.add(notification.id);
      }

      notifications.assignAll(newNotifications);
    } catch (e) {
      print('Error loading notifications: $e');
      notifications.clear();
    }
  }

  void _showNotificationSnackBar(NotificationModel notification) {
    Get.snackbar(
      '',
      '',
      snackPosition: SnackPosition.TOP,
      borderRadius: 16,
      backgroundColor: Colors.transparent,
      duration: const Duration(seconds: 4),
      animationDuration: const Duration(milliseconds: 400),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      onTap: (snack) {
        Get.back();
      },
      messageText: Builder(
        builder:
            (context) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.getCardBackgroundColor(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: notification.iconColor.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: notification.iconColor.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: notification.iconColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      notification.icon,
                      color: notification.iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          notification.title,
                          style: TextStyle(
                            color: AppTheme.getTextPrimaryColor(context),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: TextStyle(
                            color: AppTheme.getTextSecondaryColor(context),
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.close_rounded,
                      color: AppTheme.getTextSecondaryColor(context),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
      ),
      titleText: const SizedBox.shrink(), // إخفاء العنوان الافتراضي
    );
  }

  Future<void> createTaskReminder(Task task) async {
    print('=== Creating task reminder ===');
    print('Task ID: ${task.id}');
    print('Task Title: ${task.title}');
    print('Task DueDate: ${task.dueDate}');
    print('Task Time: ${task.time}');

    if (task.dueDate == null || task.time == null) {
      print('Task missing date or time, skipping notification');
      return;
    }

    if ((task.isCompleted ?? 0) == 1) {
      print('Task is already completed, skipping notification');
      return;
    }

    try {
      final dateTime = _parseTaskDateTime(task.dueDate!, task.time!);
      if (dateTime == null) {
        print('Failed to parse date/time');
        return;
      }

      print('Parsed DateTime: $dateTime');

      final notificationTime = dateTime.subtract(const Duration(hours: 1));
      print('Notification time: $notificationTime');
      print('Current time: ${DateTime.now()}');

      if (notificationTime.isAfter(DateTime.now())) {
        final notification = NotificationModel(
          id: 'task_${task.id}_${dateTime.millisecondsSinceEpoch}',
          title: 'تذكير: مهمة قريبة',
          message: 'لديك مهمة "${task.title ?? "بدون عنوان"}" بعد ساعة واحدة',
          dateTime: notificationTime,
          isRead: false,
          icon: Icons.notifications_active_rounded,
          iconColor: const Color(0xFF6366F1),
          taskId: task.id?.toString(),
        );

        print('Saving notification (1 hour before) to database...');
        await _saveNotification(notification);
        print('Notification saved (1 hour before)');

        print('Scheduling system notification (1 hour before)...');
        await _notificationService.scheduleTaskReminder(
          id: (task.id ?? 0) * 1000,
          title: notification.title,
          body: notification.message,
          taskDateTime: dateTime,
          scheduledAt: notificationTime,
        );
        print('System notification scheduled (1 hour before)');
      } else {
        print('Skipping 1-hour notification (time already passed)');
      }

      if (dateTime.isAfter(DateTime.now())) {
        print('Creating notification at task time...');
        final taskTimeNotification = NotificationModel(
          id: 'task_time_${task.id}_${dateTime.millisecondsSinceEpoch}',
          title: 'حان وقت المهمة',
          message: 'موعد مهمة "${task.title ?? "بدون عنوان"}" الآن',
          dateTime: dateTime,
          isRead: false,
          icon: Icons.alarm_rounded,
          iconColor: const Color(0xFFF59E0B),
          taskId: task.id?.toString(),
        );

        await _saveNotification(taskTimeNotification);
        print('Task time notification saved to database');

        print('Scheduling system notification (at task time)...');
        await _notificationService.scheduleTaskReminder(
          id: (task.id ?? 0) * 1000 + 1,
          title: taskTimeNotification.title,
          body: taskTimeNotification.message,
          taskDateTime: dateTime,
          scheduledAt: dateTime,
        );
        print('System notification scheduled (at task time)');
      }

      await loadNotifications();
      print('=== Task reminder created successfully ===');
    } catch (e, stackTrace) {
      print('Error creating task reminder: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> createTaskCompletedNotification(Task task) async {
    final notification = NotificationModel(
      id: 'completed_${task.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'مهمة مكتملة',
      message: 'تم إكمال مهمة "${task.title ?? "بدون عنوان"}" بنجاح',
      dateTime: DateTime.now(),
      isRead: false,
      icon: Icons.check_circle_rounded,
      iconColor: Colors.green,
      taskId: task.id.toString(),
    );

    _shownNotificationIds.add(notification.id);

    await _saveNotification(notification);

    await _updateNotificationsList();

    _showNotificationSnackBar(notification);
  }

  Future<void> _updateNotificationsList() async {
    try {
      await _initializeDatabase();
      final db = await DBHelper.instance.mydb;
      final results = await db.query(_tableName, orderBy: 'dateTime DESC');
      notifications.assignAll(results.map((row) => _fromMap(row)).toList());
    } catch (e) {
      print('Error updating notifications list: $e');
      notifications.clear();
    }
  }

  Future<void> _saveNotification(NotificationModel notification) async {
    try {
      await _initializeDatabase();
      final db = await DBHelper.instance.mydb;
      await db.insert(
        _tableName,
        _toMap(notification),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error saving notification: $e');
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _initializeDatabase();
      final db = await DBHelper.instance.mydb;
      await db.update(
        _tableName,
        {'isRead': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
      await loadNotifications();
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _initializeDatabase();
      final db = await DBHelper.instance.mydb;
      await db.update(_tableName, {'isRead': 1});
      await loadNotifications();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _initializeDatabase();
      final db = await DBHelper.instance.mydb;
      await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);

      notifications.removeWhere((n) => n.id == id);

      await Future.delayed(const Duration(milliseconds: 50));
      await loadNotifications();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  DateTime? _parseTaskDateTime(String date, String time) {
    try {
      print('Parsing date: "$date", time: "$time"');

      final datePart = date.trim().split(' ').first;
      final timePart = time.trim();

      print('Date part: "$datePart", Time part: "$timePart"');

      final dateParts = datePart.split('-');
      if (dateParts.length != 3) {
        print('Invalid date format');
        return null;
      }

      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);

      print('Parsed date: year=$year, month=$month, day=$day');

      int hour = 0, minute = 0;
      final cleanTime = timePart.replaceAll(RegExp(r'\s+'), ' ').trim();

      if (cleanTime.contains('AM') || cleanTime.contains('PM')) {
        final timeOnly = cleanTime.replaceAll(RegExp(r'[^\d:]'), '');
        print('Time only (after cleaning): "$timeOnly"');

        final timeParts = timeOnly.split(':');
        if (timeParts.length == 2) {
          hour = int.parse(timeParts[0].trim());
          minute = int.parse(timeParts[1].trim());
          if (cleanTime.toUpperCase().contains('PM') && hour != 12) hour += 12;
          if (cleanTime.toUpperCase().contains('AM') && hour == 12) hour = 0;
        } else {
          print('Invalid time format: $timeOnly');
          return null;
        }
      } else {
        final timeParts = cleanTime.split(':');
        if (timeParts.length == 2) {
          hour = int.parse(timeParts[0].trim());
          minute = int.parse(timeParts[1].trim());
        } else {
          print('Invalid time format: $cleanTime');
          return null;
        }
      }

      print('Parsed time: hour=$hour, minute=$minute');

      final result = DateTime(year, month, day, hour, minute);
      print('Final DateTime: $result');

      return result;
    } catch (e, stackTrace) {
      print('Error parsing date/time: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  Map<String, dynamic> _toMap(NotificationModel notification) {
    return {
      'id': notification.id,
      'title': notification.title,
      'message': notification.message,
      'dateTime': notification.dateTime.toIso8601String(),
      'isRead': notification.isRead ? 1 : 0,
      'iconCode': notification.icon.codePoint,
      'iconColor': notification.iconColor.value,
      'taskId': notification.taskId,
    };
  }

  NotificationModel _fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      dateTime: DateTime.parse(map['dateTime'] as String),
      isRead: (map['isRead'] as int) == 1,
      icon: IconData(map['iconCode'] as int, fontFamily: 'MaterialIcons'),
      iconColor: Color(map['iconColor'] as int),
      taskId: map['taskId'] as String?,
    );
  }
}
