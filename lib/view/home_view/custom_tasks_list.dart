import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sanad_app/config/app_theme.dart';
import 'package:sanad_app/controller/task_controller.dart';
import 'package:sanad_app/model/task_model.dart';
import 'package:sanad_app/utils/task_model_utils.dart';
import 'package:sanad_app/view/widgets/animated_task_card.dart';
import 'package:sanad_app/view/add_task_view/add_task_form.dart';
import 'package:sanad_app/view/task_details_view/task_details_view.dart';

class CustomTasksList extends StatefulWidget {
  const CustomTasksList({super.key, this.enableEditSheet = true});

  final bool enableEditSheet;

  @override
  State<CustomTasksList> createState() => _CustomTasksListState();
}

class _CustomTasksListState extends State<CustomTasksList>
    with TickerProviderStateMixin {
  late final TaskController _taskController;
  Worker? _taskListWorker;

  List<Task> _tasks = [];
  final Map<int, ValueNotifier<Task>> _taskNotifiers = {};
  List<AnimationController> _taskControllers = [];
  List<AnimationController> _progressControllers = [];

  @override
  void initState() {
    super.initState();
    _taskController = Get.find<TaskController>();
    _taskController.getTasks();

    _taskListWorker = ever<List<Task>>(
      _taskController.filteredTaskList,
      (tasks) => _setTasks(tasks),
    );
    _setTasks(_taskController.filteredTaskList);
  }

  void _setTasks(List<Task> tasks) {
    final newTasks = List<Task>.from(tasks);
    _syncTaskNotifiers(newTasks);
    _tasks = newTasks;
    _rebuildTaskAnimations();
    if (mounted) {
      setState(() {});
    }
  }

  void _syncTaskNotifiers(List<Task> tasks) {
    final Set<int> nextIds = {};
    for (final task in tasks) {
      final id = task.id;
      if (id == null) {
        continue;
      }
      nextIds.add(id);
      final notifier = _taskNotifiers[id];
      if (notifier == null) {
        _taskNotifiers[id] = ValueNotifier<Task>(task);
      } else {
        notifier.value = task;
      }
    }

    final removedIds =
        _taskNotifiers.keys.where((id) => !nextIds.contains(id)).toList();
    for (final id in removedIds) {
      _taskNotifiers[id]?.dispose();
      _taskNotifiers.remove(id);
    }
  }

  void _rebuildTaskAnimations() {
    for (final controller in _taskControllers) {
      controller.dispose();
    }
    for (final controller in _progressControllers) {
      controller.dispose();
    }
    _taskControllers = List.generate(
      _tasks.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      ),
    );
    _progressControllers = List.generate(
      _tasks.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      ),
    );
    _startAnimations();
  }

  Future<void> _startAnimations() async {
    if (_tasks.isEmpty) return;
    for (int i = 0; i < _taskControllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      _taskControllers[i].forward();
      await Future.delayed(const Duration(milliseconds: 200));
      _progressControllers[i].animateTo(
        normalizeProgress(_tasks[i].progress),
        duration: const Duration(milliseconds: 1500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _taskListWorker?.dispose();
    for (final controller in _taskControllers) {
      controller.dispose();
    }
    for (final controller in _progressControllers) {
      controller.dispose();
    }
    for (final notifier in _taskNotifiers.values) {
      notifier.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_tasks.isEmpty) {
      return Center(
        child: Text(
          'لا توجد مهام بعد.',
          style: TextStyle(
            color: AppTheme.getTextSecondaryColor(context),
            fontSize: 16,
          ),
          textDirection: TextDirection.rtl,
        ),
      );
    }

    return SafeArea(
      top: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverPadding(
            padding: const EdgeInsets.only(left: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final task = _tasks[index];
                final taskId = task.id;
                final notifier = taskId != null ? _taskNotifiers[taskId] : null;

                Widget cardWidget;
                if (notifier != null) {
                  cardWidget = ValueListenableBuilder<Task>(
                    valueListenable: notifier,
                    builder: (context, value, child) {
                      return AnimatedTaskCard(
                        task: _toUiTask(value),
                        cardController: _taskControllers[index],
                        progressController: _progressControllers[index],
                        isLast: index == _tasks.length - 1,
                        onTap: () => _onTaskTap(index),
                        onLongPress:
                            widget.enableEditSheet
                                ? () => _openEditSheet(value)
                                : null,
                      );
                    },
                  );
                } else {
                  cardWidget = AnimatedTaskCard(
                    task: _toUiTask(task),
                    cardController: _taskControllers[index],
                    progressController: _progressControllers[index],
                    isLast: index == _tasks.length - 1,
                    onTap: () => _onTaskTap(index),
                    onLongPress:
                        widget.enableEditSheet
                            ? () => _openEditSheet(task)
                            : null,
                  );
                }

                return _SwipeableTaskCard(
                  onSwipe: () => _openTaskDetails(task),
                  child: cardWidget,
                );
              }, childCount: _tasks.length),
            ),
          ),
        ],
      ),
    );
  }

  TaskModel _toUiTask(Task task) => convertTaskToModel(task);

  Future<void> _onTaskTap(int index) async {
    final task = _tasks[index];
    if (task.id == null) return;

    final isCompleted = (task.isCompleted ?? 0) == 1;
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      interval: task.interval,
      dueDate: task.dueDate,
      isCompleted: isCompleted ? 0 : 1,
      category: task.category,
      time: task.time,
      progress: isCompleted ? 0 : 100,
      color: task.color,
      icon: task.icon,
    );

    _tasks[index] = updatedTask;
    _taskNotifiers[task.id!]?.value = updatedTask;
    _progressControllers[index].animateTo(
      normalizeProgress(updatedTask.progress),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
    );

    await _taskController.updateTaskInMemory(updatedTask);
  }

  void _openEditSheet(Task task) {
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
                'تعديل المهمة',
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

  void _openTaskDetails(Task task) {
    final taskModel = _toUiTask(task);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TaskDetailsView(
              task: taskModel,
              onEdit:
                  widget.enableEditSheet ? () => _openEditSheet(task) : null,
              onDelete: () async {
                await _taskController.delete(task);
              },
            ),
      ),
    );
  }
}

class _SwipeableTaskCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onSwipe;

  const _SwipeableTaskCard({required this.child, required this.onSwipe});

  @override
  State<_SwipeableTaskCard> createState() => _SwipeableTaskCardState();
}

class _SwipeableTaskCardState extends State<_SwipeableTaskCard> {
  double _dragStartX = 0;
  double _dragOffset = 0;
  bool _hasSwiped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (details) {
        _dragStartX = details.globalPosition.dx;
        _dragOffset = 0;
        _hasSwiped = false;
      },
      onHorizontalDragUpdate: (details) {
        if (_hasSwiped) return;
        _dragOffset = details.globalPosition.dx - _dragStartX;

        if (_dragOffset.abs() > 100) {
          _hasSwiped = true;
          widget.onSwipe();
        }
      },
      onHorizontalDragEnd: (details) {
        if (!_hasSwiped && details.primaryVelocity != null) {
          if (details.primaryVelocity!.abs() > 300) {
            _hasSwiped = true;
            widget.onSwipe();
          }
        }
        _dragOffset = 0;
      },
      child: widget.child,
    );
  }
}
