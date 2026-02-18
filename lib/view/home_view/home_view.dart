import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sanad_app/config/app_theme.dart';
import 'package:sanad_app/controller/task_controller.dart';
import 'package:sanad_app/view/home_view/custom_tasks_list.dart';
import 'package:sanad_app/view/main_layout.dart';
import 'package:sanad_app/view/widgets/custom_icon_button.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final RxString _selectedDay = 'today'.obs;
  late final TaskController _taskController;

  @override
  void initState() {
    super.initState();
    _taskController = Get.find<TaskController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTasksDate();
    });
  }

  String _getDateString({bool isTomorrow = false}) {
    final now = DateTime.now();
    final date = isTomorrow ? now.add(const Duration(days: 1)) : now;
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _onDaySelected(String day) {
    _selectedDay.value = day;
    _updateTasksDate();
  }

  void _updateTasksDate() {
    String targetDate = _getDateString(isTomorrow: _selectedDay.value == 'tomorrow');
    _taskController.updateDate(targetDate);
  }

  int _getTasksCount() {
    String targetDate = _getDateString(isTomorrow: _selectedDay.value == 'tomorrow');
    return _taskController.taskList.where((task) {
      if (task.dueDate == null) return false;
      try {
        final taskDate = task.dueDate!.trim().split(' ').first;
        return taskDate == targetDate;
      } catch (e) {
        return false;
      }
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildGreeting(context),
                  const SizedBox(height: 24),
                  _buildDateSelector(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 0),
                          child: const CustomTasksList(),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 0,
                          right: 0,
                          child: _buildChatButton(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(
          '... سنـــد',
          style: TextStyle(
            color: Color(0xFF726CC9),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 12),
        Image.asset(
          'assets/images/sanad_icon.png',
          width: 40,
          height: 40,
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير';
    if (hour >= 17) return 'مساء الخير';
    return 'مساء الخير';
  }

  Widget _buildGreeting(BuildContext context) {
    final userName = FirebaseAuth.instance.currentUser?.displayName?.trim() ?? 'ضيف';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${_getGreeting()}. $userName',
          style: TextStyle(
            color: AppTheme.getTextPrimaryColor(context),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Obx(() {
          final count = _getTasksCount();
          final isToday = _selectedDay.value == 'today';
          final dayText = isToday ? 'اليوم' : 'غداً';
          
          return Text(
            count > 0
                ? 'لديك $count ${count == 1 ? 'مهمة' : 'مهام'} $dayText.'
                : 'لا توجد مهام $dayText.',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: AppTheme.getTextSecondaryColor(context),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildFilterChip('tomorrow', 'غداً'),
              _buildFilterChip('today', 'اليوم'),
            ],
          ),
        ),
        Text(
          'جدول أعمالك',
          style: TextStyle(
            color: AppTheme.getTextPrimaryColor(context),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        const CircleAvatar(
          radius: 6,
          backgroundColor: AppTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildFilterChip(String key, String label) {
    return Obx(() {
      final isSelected = _selectedDay.value == key;
      return GestureDetector(
        onTap: () => _onDaySelected(key),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: isSelected ? null : Border.all(color: AppTheme.primaryColor),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.primaryColor,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildChatButton(BuildContext context) {
    return Center(
      child: Column(
        children: [
          CustomIconButton(
            onPressed: () {
              final mainLayoutState = MainLayout.of(context);
              if (mainLayoutState != null) {
                mainLayoutState.changePage(3);
              }
            },
            radius: 36,
            iconSize: 38,
            icon: Icons.chat,
          ),
          const SizedBox(height: 12),
          Text(
            'تحدث مع سند...',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: AppTheme.getTextSecondaryColor(context),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}