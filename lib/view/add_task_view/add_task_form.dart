import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sanad_app/controller/task_controller.dart';
import 'package:sanad_app/model/task_model.dart';
import 'package:sanad_app/view/widgets/custom_button.dart';
import 'package:sanad_app/view/widgets/custom_drop_down_button_field.dart';
import 'package:sanad_app/view/widgets/custom_select_date_time_field.dart';
import 'package:sanad_app/view/widgets/custom_text_form_field.dart';
import 'package:sanad_app/view/widgets/icons_grid_view.dart';

class AddTaskForm extends StatefulWidget {
  const AddTaskForm({super.key, this.task});

  final Task? task;
  @override
  State<AddTaskForm> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<AddTaskForm> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final TaskController _taskController = Get.find<TaskController>();

  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;

  String? title, description, category, interval;
  int? selectedIcon;
  int? selectedColor;
  String? date;
  String? time;

  final TextEditingController _dateTimeController = TextEditingController();

  Future<void> _pickDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    DateTime finalDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      _dateTimeController.text =
          "${finalDateTime.year}-${finalDateTime.month.toString().padLeft(2, '0')}-${finalDateTime.day.toString().padLeft(2, '0')} "
          "   ${pickedTime.format(context)}";
      date =
          "${finalDateTime.year}-${finalDateTime.month.toString().padLeft(2, '0')}-${finalDateTime.day.toString().padLeft(2, '0')} ";
      time = "   ${pickedTime.format(context)}";
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      title = widget.task!.title ?? "";
      description = widget.task!.description ?? "";
      date = widget.task!.dueDate;
      time = widget.task!.time;
      interval = widget.task!.interval ?? "يومي";
      category = widget.task!.category ?? "العمل";
      selectedIcon = int.tryParse(widget.task!.icon ?? '');
      selectedColor = int.tryParse(widget.task!.color ?? '');
      if ((date ?? '').isNotEmpty || (time ?? '').isNotEmpty) {
        _dateTimeController.text = '${date ?? ''} ${time ?? ''}'.trim();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formkey,
      autovalidateMode: autovalidateMode,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextFormField(
              hintText: 'ادخل عنوان المهمة',
              labelText: 'عنوان المهمة',
              keyboardType: TextInputType.text,
              initialValue: title,
              onSaved: (value) {
                title = value;
              },
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'يرجى ادخال عنوان المهمة';
                } else {
                  return null;
                }
              },
            ),
            CustomTextFormField(
              hintText: 'ادخل وصف المهمة',
              labelText: 'وصف المهمة',
              keyboardType: TextInputType.text,
              maxLiens: 6,
              initialValue: description,
              onSaved: (value) {
                description = value;
              },
            ),
            CustomDropDownButtonField(
              hintText: ' حدد الفئة',
              labelText: 'الفئة',
              category: category,
              items: const [
                DropdownMenuItem(
                  value: 'العمل',
                  alignment: Alignment.center,
                  child: Text('العمل'),
                ),
                DropdownMenuItem(
                  value: 'الدراسة',
                  alignment: Alignment.center,
                  child: Text('الدراسة'),
                ),
                DropdownMenuItem(
                  value: 'الصحة',
                  alignment: Alignment.center,
                  child: Text('الصحة'),
                ),
                DropdownMenuItem(
                  value: 'اجتماعي',
                  alignment: Alignment.center,
                  child: Text('اجتماعي'),
                ),
              ],
              onChanged: (value) {
                category = value;
              },
            ),
            CustomDropDownButtonField(
              hintText: 'حدد فترة التكرار',
              labelText: 'التكرار',
              category: interval,
              items: const [
                DropdownMenuItem(
                  value: 'مرة واحدة فقط',
                  alignment: Alignment.center,
                  child: Text('مرة واحدة فقط'),
                ),
                DropdownMenuItem(
                  value: 'يومي',
                  alignment: Alignment.center,
                  child: Text('يومي'),
                ),
                DropdownMenuItem(
                  value: 'أسبوعي',
                  alignment: Alignment.center,
                  child: Text('أسبوعي'),
                ),
                DropdownMenuItem(
                  value: 'شهري',
                  alignment: Alignment.center,
                  child: Text('شهري'),
                ),
                DropdownMenuItem(
                  value: 'سنوي',
                  alignment: Alignment.center,
                  child: Text('سنوي'),
                ),
              ],
              onChanged: (value) {
                interval = value;
              },
            ),
            CustomSelectDateTimeField(
              hintText: 'حدد التاريخ والوقت',
              labelText: "التاريخ",
              keyboardType: TextInputType.text,
              dateTimeController: _dateTimeController,
              onPressed: _pickDateTime,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  IconsGridView(
                    initialIcon: selectedIcon,
                    initialColor: selectedColor,
                    onIconSelected: (icon, color) {
                      setState(() {
                        selectedIcon = icon;
                        selectedColor = color;
                      });
                    },
                  ),
                  SizedBox(height: 24),
                  CustomButton(
                    text: widget.task == null ? 'إضافة المهمة' : 'تعديل المهمة',
                    hasIcon: true,
                    onTap: () async {
                      if (formkey.currentState!.validate()) {
                        formkey.currentState!.save();
        
                        if (widget.task == null) {
                          _addTaskToDb();
                        } else {
                          _updateTaskInDb();
                        }
                        Get.back();
                      } else {
                        autovalidateMode = AutovalidateMode.always;
                        setState(() {});
                      }
                    },
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _addTaskToDb() async {
    int value = await _taskController.addTask(
      task: Task(
        description: (description ?? '').trim().isEmpty ? null : description!.trim(),
        title: title?.trim(),
        isCompleted: 0,
        category: category,
        interval: interval,
        dueDate: (date ?? '').trim().isEmpty ? null : date!.trim(),
        time: (time ?? '').trim().isEmpty ? null : time!.trim(),
        color: selectedColor?.toString(),
        icon: selectedIcon?.toString(),
        progress: 0,
      ),
    );
    print("My id is " + "$value");
  }

  _updateTaskInDb() async {
    await _taskController.updateTaskInfo(
      Task(
        id: widget.task!.id,
        description: description,
        title: title,
        isCompleted: widget.task!.isCompleted,
        category: category,
        interval: interval,
        dueDate: date ?? widget.task!.dueDate,
        time: time ?? widget.task!.time,
        color: selectedColor?.toString() ?? widget.task!.color,
        icon: selectedIcon?.toString() ?? widget.task!.icon,
        progress: widget.task!.progress,
      ),
    );
  }
}
