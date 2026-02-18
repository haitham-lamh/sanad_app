import 'package:get/get.dart';
import 'package:sanad_app/model/task_model.dart';
import 'package:sanad_app/controller/notification_controller.dart';
import '../db/db_helper.dart';

class TaskController extends GetxController {

  @override
  void onReady() {
    super.onReady();
    getTasks();
  }

  var taskList = <Task>[].obs;
  var filteredTaskList = <Task>[].obs;
  var searchQuery = ''.obs;
  var selectedCategory = 'All'.obs;
  var selectedPriority = 'All'.obs;
  var selectedStatus = 'All'.obs;
  var selectedDate = 'All'.obs;

  Future<int> addTask({Task? task}) async {
    if (task == null) return 0;

    final rawDueDate = task.dueDate;
    final normalized = _normalizeDate(rawDueDate);
    if (normalized.isEmpty) {
      final now = DateTime.now();
      task.dueDate =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    } else {
      task.dueDate = normalized;
    }
    if (task.icon == null) {
      task.icon = 5.toString();
    }else{
      task.icon = task.icon.toString();
    }

    final id = await DBHelper.instance.insert(task);
    task.id = id;
    getTasks();
    if (Get.isRegistered<NotificationController>()) {
      final notificationController = Get.find<NotificationController>();
      await notificationController.createTaskReminder(task);
    }
    return id;
  }

  void getTasks() async {
    List<Map<String, dynamic>> tasks = await DBHelper.instance.query();
    taskList.assignAll(tasks.map((data) => Task.fromJson(data)).toList());
    filterTasks();
  }

  Future<void> delete(Task task) async {
    await DBHelper.instance.delete(task);
    getTasks();
  }

  Future<void> markTaskCompleted(int id) async {
    await DBHelper.instance.updateCompleted(id);
    getTasks();
  }

  Future<void> updateTaskInfo(Task task) async {
    await DBHelper.instance.updateTask(task);
    getTasks();
    if (Get.isRegistered<NotificationController>()) {
      final notificationController = Get.find<NotificationController>();
      await notificationController.createTaskReminder(task);
    }
  }

  Future<void> updateTaskInMemory(Task updatedTask) async {
    final wasCompleted = (updatedTask.isCompleted ?? 0) == 1;
    await DBHelper.instance.updateTask(updatedTask);
    _replaceInList(taskList, updatedTask);
    filterTasks();
    taskList.refresh();
    
    if (wasCompleted && Get.isRegistered<NotificationController>()) {
      final notificationController = Get.find<NotificationController>();
      await notificationController.createTaskCompletedNotification(updatedTask);
    }
  }

  void _replaceInList(RxList<Task> list, Task updatedTask) {
    final index = list.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      list[index] = updatedTask;
    }
  }

  void filterTasks() {
    List<Task> tempTasks = taskList;

    if (selectedCategory.value != 'All') {
      tempTasks = tempTasks
          .where((task) => task.category == selectedCategory.value)
          .toList();
    }

    if (selectedPriority.value != 'All') {
      tempTasks = tempTasks
          .where((task) => task.interval == selectedPriority.value)
          .toList();
    }

    if (selectedStatus.value != 'All') {
      final isCompletedFilter = selectedStatus.value == 'Completed';
      tempTasks = tempTasks
          .where((task) => (task.isCompleted ?? 0) == (isCompletedFilter ? 1 : 0))
          .toList();
    }

    if (selectedDate.value != 'All') {
      final selected = selectedDate.value;
      tempTasks = tempTasks
          .where((task) => _normalizeDate(task.dueDate) == selected)
          .toList();
    }

    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      tempTasks = tempTasks.where((task) {
        final title = (task.title ?? '').toLowerCase();
        final description = (task.description ?? '').toLowerCase();
        return title.contains(query) || description.contains(query);
      }).toList();
    }

    filteredTaskList.assignAll(tempTasks);
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
      filterTasks();
  }

  void updateCategory(String category) {
    selectedCategory.value = category;
    filterTasks();
  }

  void updatePriority(String priority) {
    selectedPriority.value = priority;
    filterTasks();
  }

  void updateStatus(String status) {
    selectedStatus.value = status;
    filterTasks();
  }

  void updateDate(String date) {
    selectedDate.value = date.isEmpty ? 'All' : date;
    filterTasks();
  }

  void resetFilters() {
    selectedCategory.value = 'All';
    selectedPriority.value = 'All';
    selectedStatus.value = 'All';
    selectedDate.value = 'All';
    searchQuery.value = '';
    filterTasks();
  }

  String _normalizeDate(String? dueDate) {
    if (dueDate == null) return '';
    final trimmed = dueDate.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.split(' ').first;
  }
}
