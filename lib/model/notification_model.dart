import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime dateTime;
  final bool isRead;
  final IconData icon;
  final Color iconColor;
  final String? taskId; // ربط بالإشعار بمهمة معينة

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.dateTime,
    this.isRead = false,
    required this.icon,
    required this.iconColor,
    this.taskId,
  });
}
