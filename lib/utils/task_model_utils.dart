import 'package:flutter/material.dart';
import 'package:sanad_app/model/task_model.dart';

TaskModel convertTaskToModel(Task task) {
  final int? colorValue = int.tryParse(task.color ?? '');
  final int? iconValue = int.tryParse(task.icon ?? '');
  final Color categoryColor =
      colorValue != null ? Color(colorValue) : const Color(0xFF726CC9);
  final IconData icon = iconValue != null
      ? IconData(iconValue, fontFamily: 'MaterialIcons')
      : Icons.task_alt;

  return TaskModel(
    title: task.title ?? 'بدون عنوان',
    desc: task.description,
    time: (task.time ?? '--:--').trim(),
    date: task.dueDate,
    duration: task.interval ?? 'بدون تكرار',
    progress: normalizeProgress(task.progress),
    isCompleted: (task.isCompleted ?? 0) == 1,
    category: task.category ?? 'غير محدد',
    categoryColor: categoryColor,
    icon: icon,
  );
}

double normalizeProgress(num? progress) {
  if (progress == null) return 0.0;
  final value = progress.toDouble();
  final normalized = value > 1 ? value / 100 : value;
  return normalized.clamp(0.0, 1.0).toDouble();
}
