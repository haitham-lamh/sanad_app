import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sanad_app/config/app_theme.dart';
import 'package:sanad_app/controller/task_controller.dart';
import 'package:sanad_app/model/task_model.dart';
import 'package:sanad_app/view/add_task_view/add_task_form.dart';
import 'package:sanad_app/view/calender_view/widgets/calendar_header.dart';
import 'package:sanad_app/view/calender_view/widgets/calendar_panel.dart';
import 'package:sanad_app/view/calender_view/widgets/month_tasks_section.dart';
import 'package:sanad_app/view/calender_view/widgets/selected_day_tasks_section.dart';
import 'package:sanad_app/view/widgets/custom_button.dart';

class CalenderView extends StatefulWidget {
  const CalenderView({super.key});

  @override
  State<CalenderView> createState() => _CalenderViewState();
}

class _CalenderViewState extends State<CalenderView> {
  late final TaskController _taskController;
  Worker? _taskWorker;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Task>> _tasksByDay = {};

  @override
  void initState() {
    super.initState();
    _taskController = Get.find<TaskController>();
    _selectedDay = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    _taskWorker = ever<List<Task>>(
      _taskController.taskList,
      (_) => _prepareTaskCollection(),
    );
    _prepareTaskCollection();
  }

  @override
  void dispose() {
    _taskWorker?.dispose();
    super.dispose();
  }

  void _prepareTaskCollection() {
    final Map<DateTime, List<Task>> grouped = {};
    for (final task in _taskController.taskList) {
      final taskDate = _parseTaskDate(task);
      if (taskDate == null) continue;
      final key = DateTime(taskDate.year, taskDate.month, taskDate.day);
      grouped.putIfAbsent(key, () => []).add(task);
    }
    setState(() {
      _tasksByDay = grouped;
    });
  }

  DateTime? _parseTaskDate(Task task) {
    final raw = task.dueDate?.trim();
    if (raw == null || raw.isEmpty) return null;
    final primary = raw.split(' ').first;
    if (primary.isEmpty) return null;
    return DateTime.tryParse(primary);
  }

  List<Task> _tasksForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    final tasks = _tasksByDay[key];
    if (tasks == null) return [];
    final sorted = List<Task>.from(tasks);
    sorted.sort((a, b) => (a.time ?? '').compareTo(b.time ?? ''));
    return sorted;
  }

  List<Task> _tasksForMonth(DateTime month) {
    final monthTasks = <Task>[];
    _tasksByDay.forEach((day, tasks) {
      if (day.year == month.year && day.month == month.month) {
        monthTasks.addAll(tasks);
      }
    });
    final sorted = List<Task>.from(monthTasks);
    sorted.sort((a, b) => (a.time ?? '').compareTo(b.time ?? ''));
    return sorted;
  }

  void _onDaySelected(DateTime selected, DateTime focused) {
    setState(() {
      _selectedDay = selected;
      _focusedDay = focused;
    });
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
  }

  void _openAddSheet({Task? task}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.getBackgroundColor(context),
      isScrollControlled: true,
      sheetAnimationStyle: AnimationStyle(
        duration: const Duration(milliseconds: 1000),
      ),
      builder: (context) {
        return SizedBox(
          height: 750,
          child: Column(
            children: [
              Container(
                width: 45,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20, top: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Text(
                task == null ? 'إضافة مهمة' : 'تعديل المهمة',
                style: TextStyle(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Divider(
                indent: 16,
                endIndent: 16,
                color: AppTheme.primaryColor,
                height: 4,
              ),
              const SizedBox(height: 24),
              Expanded(child: AddTaskForm(task: task)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedDayTasks =
        _selectedDay == null ? <Task>[] : _tasksForDay(_selectedDay!);
    final monthTasks = _tasksForMonth(_focusedDay);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          CalendarHeader(
            focusedDay: _focusedDay,
            onPrevious:
                () => _onPageChanged(
                  DateTime(_focusedDay.year, _focusedDay.month - 1, 1),
                ),
            onNext:
                () => _onPageChanged(
                  DateTime(_focusedDay.year, _focusedDay.month + 1, 1),
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                CalendarPanel(
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  onDaySelected: _onDaySelected,
                  onPageChanged: _onPageChanged,
                  tasksForDay: _tasksForDay,
                ),
                const SizedBox(height: 24),
                SelectedDayTasksSection(
                  selectedDay: _selectedDay,
                  tasks: selectedDayTasks,
                ),
                const SizedBox(height: 24),
                MonthTasksSection(tasks: monthTasks),
              ],
            ),
          ),
          CustomButton(text: 'إضافة مهمة جديدة', onTap: () => _openAddSheet()),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
