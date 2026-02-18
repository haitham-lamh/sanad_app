import 'package:flutter/material.dart';

class TaskModel {
  String title;
  String? desc;
  String time;
  String? date;
  String duration;
  double progress = 0;
  bool isCompleted;
  String category;
  Color categoryColor;
  IconData icon;

  TaskModel({
    required this.title,
    this.desc,
    required this.time,
    this.date,
    required this.duration,
    required this.progress,
    required this.isCompleted,
    required this.category,
    required this.categoryColor,
    required this.icon,
  });
}

class Task {
  int? id;
  String? title;
  String? description;
  String? interval;
  String? dueDate;
  int? isCompleted;
  String? category;
  String? time;
  double? progress;
  String? color;
  String? icon;

  Task({
    this.id,
    this.title,
    this.description,
    this.interval,
    this.dueDate,
    this.isCompleted,
    this.category,
    this.time,
    this.progress,
    this.color,
    this.icon,
  });

  Task.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    interval = json['interval'];
    dueDate = json['dueDate'];
    isCompleted = json['isCompleted'];
    category = json['category'];
    time = json['time'];
    final rawProgress = json['progress'];
    if (rawProgress is int) {
      progress = rawProgress.toDouble();
    } else if (rawProgress is double) {
      progress = rawProgress;
    } else if (rawProgress is String) {
      progress = double.tryParse(rawProgress);
    } else {
      progress = null;
    }
    color = json['color'];
    icon = json['icon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['interval'] = interval;
    data['dueDate'] = dueDate;
    data['isCompleted'] = isCompleted;
    data['category'] = category;
    data['time'] = time;
    data['progress'] = progress;
    data['color'] = color;
    data['icon'] = icon;
    return data;
  }
}
