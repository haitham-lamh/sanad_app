import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sanad_app/config/app_theme.dart';
import 'package:sanad_app/controller/task_controller.dart';
import 'package:sanad_app/view/add_task_view/add_task_form.dart';
import 'package:sanad_app/view/home_view/custom_tasks_list.dart';
import 'package:sanad_app/view/widgets/custom_button.dart';

class TasksView extends StatelessWidget {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find<TaskController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'قائمة المهام',
                style: TextStyle(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(radius: 6, backgroundColor: AppTheme.primaryColor),
            ],
          ),
          const SizedBox(height: 12),
          _TasksFilterBar(taskController: taskController),
          const Expanded(child: CustomTasksList()),
          CustomButton(
            text: 'إضافة مهمة جديدة',
            hasIcon: true,
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: AppTheme.getBackgroundColor(context),
                isScrollControlled: true,
                sheetAnimationStyle: AnimationStyle(
                  duration: const Duration(milliseconds: 1500),
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
                          'إضافة مهمة',
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
                        const Expanded(child: AddTaskForm()),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}

class _TasksFilterBar extends StatefulWidget {
  const _TasksFilterBar({required this.taskController});

  final TaskController taskController;

  @override
  State<_TasksFilterBar> createState() => _TasksFilterBarState();
}

class _TasksFilterBarState extends State<_TasksFilterBar> {
  late final TextEditingController _searchController;
  Worker? _searchWorker;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.taskController.searchQuery.value,
    );
    _searchWorker = ever<String>(widget.taskController.searchQuery, (value) {
      if (_searchController.text != value) {
        _searchController.text = value;
        _searchController.selection = TextSelection.collapsed(
          offset: value.length,
        );
      }
    });
  }

  @override
  void dispose() {
    _searchWorker?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) {
      return;
    }
    final String formatted =
        '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
    widget.taskController.updateDate(formatted);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            style: TextStyle(color: AppTheme.getTextPrimaryColor(context)),
            cursorColor: AppTheme.primaryColorVariant,
            cursorRadius: const Radius.circular(12),
            onChanged: widget.taskController.updateSearchQuery,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.getCardBackgroundColor(context),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.getBorderColor(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
              ),
              hintTextDirection: TextDirection.rtl,
              hintText: 'ابحث بالاسم أو الوصف',
              hintStyle: TextStyle(color: AppTheme.getTextSecondaryColor(context), fontSize: 14),
              prefixIcon: Icon(Icons.search, color: AppTheme.getTextSecondaryColor(context)),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(
              () => Row(
                children: [
                  _FilterDropdown(
                    label: 'الفئة',
                    value: widget.taskController.selectedCategory.value,
                    items: const [
                      'All',
                      'العمل',
                      'الدراسة',
                      'الصحة',
                      'اجتماعي',
                    ],
                    onChanged: widget.taskController.updateCategory,
                  ),
                  const SizedBox(width: 10),
                  _FilterDropdown(
                    label: 'التكرار',
                    value: widget.taskController.selectedPriority.value,
                    items: const ['All', 'مرة واحدة فقط', 'يومي', 'أسبوعي', 'شهري', 'سنوي'],
                    onChanged: widget.taskController.updatePriority,
                  ),
                  const SizedBox(width: 10),
                  _FilterDropdown(
                    label: 'الحالة',
                    value: widget.taskController.selectedStatus.value,
                    items: const ['All', 'Completed', 'Incomplete'],
                    onChanged: widget.taskController.updateStatus,
                    displayMapper: (value) {
                      switch (value) {
                        case 'Completed':
                          return 'مكتملة';
                        case 'Incomplete':
                          return 'غير مكتملة';
                        default:
                          return 'الكل';
                      }
                    },
                  ),
                  const SizedBox(width: 10),
                  _DateFilterChip(
                    label: 'التاريخ',
                    value: widget.taskController.selectedDate.value,
                    onPick: () => _pickDate(context),
                    onClear: () => widget.taskController.updateDate(''),
                  ),
                  const SizedBox(width: 10),
                  _ActionChip(
                    label: 'الكل',
                    icon: Icons.refresh,
                    onTap: widget.taskController.resetFilters,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.displayMapper,
  });

  final String label;
  final String value;
  final List<String> items;
  final void Function(String) onChanged;
  final String Function(String value)? displayMapper;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox.shrink(),
        dropdownColor: AppTheme.primaryColor,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppTheme.getTextPrimaryColor(context),
        ),
        style: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        items:
            items
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    alignment: Alignment.centerRight,
                    child: Text(
                      displayMapper?.call(item) ??
                          (item == 'All' ? 'الكل' : item),
                    ),
                  ),
                )
                .toList(),
        onChanged: (newValue) {
          if (newValue == null) return;
          onChanged(newValue);
        },
        hint: Text(label, style: TextStyle(color: AppTheme.getTextSecondaryColor(context))),
      ),
    );
  }
}

class _DateFilterChip extends StatelessWidget {
  const _DateFilterChip({
    required this.label,
    required this.value,
    required this.onPick,
    required this.onClear,
  });

  final String label;
  final String value;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final bool hasValue = value != 'All' && value.isNotEmpty;
    return GestureDetector(
      onTap: onPick,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.getCardBackgroundColor(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.getBorderColor(context)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month, color: AppTheme.getTextSecondaryColor(context), size: 18),
            const SizedBox(width: 6),
            Text(
              hasValue ? value : label,
              style: TextStyle(color: hasValue ? AppTheme.getTextPrimaryColor(context) : AppTheme.getTextSecondaryColor(context)),
            ),
            if (hasValue) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close, color: AppTheme.getTextSecondaryColor(context), size: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.getCardBackgroundColor(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.getBorderColor(context)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.getTextSecondaryColor(context), size: 18),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: AppTheme.getTextPrimaryColor(context))),
          ],
        ),
      ),
    );
  }
}
