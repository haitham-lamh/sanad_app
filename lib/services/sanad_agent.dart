import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sanad_app/constants/constants.dart';
import 'package:sanad_app/controller/task_controller.dart';
import 'package:sanad_app/model/task_model.dart';

class SanadAgent {
  static Task? _taskFromArgs(Map<String, dynamic> args) {
    final title = (args['title'] as String?)?.trim();
    if (title == null || title.isEmpty) return null;

    final description = (args['description'] as String?)?.trim();
    var category = (args['category'] as String?)?.trim();
    var interval = (args['interval'] as String?)?.trim();
    var dueDate = (args['dueDate'] as String?)?.trim();
    var time = (args['time'] as String?)?.trim();

    if (category == null || category.isEmpty) category = 'العمل';
    if (interval == null || interval.isEmpty) interval = 'يومي';

    var iconIndex = 0;
    final i = args['iconIndex'] ?? args['icon_index'];
    if (i != null) {
      if (i is int) {
        iconIndex = i.clamp(0, 14);
      } else if (i is double) {
        iconIndex = i.round().clamp(0, 14);
      } else if (i is String) {
        final parsed = int.tryParse(i.trim());
        if (parsed != null) iconIndex = parsed.clamp(0, 14);
      }
    }
    if (i == null || (i is String && int.tryParse(i.trim()) == null)) {
      switch (category) {
        case 'الدراسة':
          iconIndex = 1;
          break;
        case 'الصحة':
          iconIndex = 6;
          break;
        case 'اجتماعي':
          iconIndex = 7;
          break;
        case 'العمل':
        default:
          iconIndex = 5;
          break;
      }
    }

    final iconCodePoint = iconIndex.clamp(0, kIcons.length - 1);
    final iconItem = kIcons[iconCodePoint];
    final String iconValue =
        (iconItem['icon'] as IconData).codePoint.toString();
    final String colorValue =
        (iconItem['color'] as Color).value.toString();

    if (dueDate != null && dueDate.isNotEmpty) {
      dueDate = dueDate.split(' ').first;
    }
    final timeStr = ((time == null || time.isEmpty) ? '00:00' : time).trim();

    return Task(
      title: title,
      description: (description == null || description.isEmpty) ? null : description,
      category: category,
      interval: interval,
      dueDate: (dueDate == null || dueDate.isEmpty) ? null : dueDate,
      time: timeStr,
      icon: iconValue,
      color: colorValue,
      progress: 0,
      isCompleted: 0,
    );
  }

  static Future<String> createTaskFromCall(Map<String, dynamic> args) async {
    print('args: $args');
    final task = _taskFromArgs(args);
    if (task == null) {
      return 'لم أستطع إنشاء المهمة: العنوان مطلوب.';
    }
    try {
      final tc = Get.find<TaskController>();
      await tc.addTask(task: task);
      final when = (task.dueDate != null && task.dueDate!.isNotEmpty) &&
              (task.time != null && task.time!.isNotEmpty)
          ? ' (${task.dueDate} ${task.time})'
          : '';
      return 'تم إنشاء المهمة «${task.title}» وجدولتها.$when';
    } catch (e) {
      return 'حدث خطأ أثناء إنشاء المهمة: $e';
    }
  }

  static Future<String> createTasksFromCall(Map<String, dynamic> args) async {
    final raw = args['tasks'];
    if (raw is! List || raw.isEmpty) {
      return 'لم أستطع إنشاء المهام: قائمة المهام فارغة أو غير صحيحة.';
    }
    final tc = Get.find<TaskController>();
    int created = 0;
    for (final item in raw) {
      if (item is! Map<String, dynamic>) continue;
      final task = _taskFromArgs(item);
      if (task == null) continue;
      try {
        await tc.addTask(task: task);
        created++;
      } catch (_) {}
    }
    if (created == 0) {
      return 'لم أستطع إنشاء أي مهمة (العناوين مطلوبة).';
    }
    return 'تم إنشاء $created مهام لجدول المذاكرة. راجع قائمة المهام.';
  }
}
