import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sanad_app/config/app_theme.dart';
import 'package:sanad_app/model/task_model.dart';
import 'package:sanad_app/view/calender_view/widgets/calendar_task_item.dart';
import 'package:sanad_app/view/calender_view/widgets/section_wrapper.dart';

class SelectedDayTasksSection extends StatelessWidget {
  const SelectedDayTasksSection({
    super.key,
    required this.selectedDay,
    required this.tasks,
  });

  final DateTime? selectedDay;
  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        selectedDay == null
            ? 'اختر يوم لعرض مهام اليوم'
            : DateFormat.yMMMMd('ar').format(selectedDay!);
    return SectionWrapper(
      title: 'مهام اليوم',
      subtitle: dateLabel,
      child: tasks.isEmpty
          ? Text(
              'لا توجد مهام في هذا اليوم.',
              style: TextStyle(color: AppTheme.getTextSecondaryColor(context)),
            )
          : Column(
              children: tasks
                  .map(
                    (task) => CalendarTaskItem(task: task, highlight: true),
                  )
                  .toList(),
            ),
    );
  }
}
