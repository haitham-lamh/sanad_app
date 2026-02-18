import 'package:flutter/material.dart';
import 'package:sanad_app/model/task_model.dart';
import 'package:sanad_app/view/calender_view/widgets/calendar_task_item.dart';
import 'package:sanad_app/view/calender_view/widgets/section_wrapper.dart';

class MonthTasksSection extends StatelessWidget {
  const MonthTasksSection({super.key, required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    return SectionWrapper(
      title: 'مهام الشهر',
      subtitle: '${tasks.length} مهمة',
      child: Column(
        children: tasks.map((task) => CalendarTaskItem(task: task)).toList(),
      ),
    );
  }
}
