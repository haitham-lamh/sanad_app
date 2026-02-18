import 'package:flutter/material.dart';
import 'package:sanad_app/view/widgets/custom_button.dart';
import 'package:sanad_app/view/widgets/custom_drop_down_button_field.dart';
import 'package:sanad_app/view/widgets/custom_text_form_field.dart';
import 'package:sanad_app/view/widgets/icons_grid_view.dart';

class EditTaskForm extends StatefulWidget {
  const EditTaskForm({super.key});

  @override
  State<EditTaskForm> createState() => _EditTaskFormState();
}

class _EditTaskFormState extends State<EditTaskForm> {
  int? selectedIcon;
  int? selectedColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextFormField(
          hintText: 'ادخل عنوان المهمة',
          labelText: 'عنوان المهمة',
          keyboardType: TextInputType.text,
        ),
        CustomTextFormField(
          hintText: 'ادخل وصف المهمة',
          labelText: 'وصف المهمة',
          keyboardType: TextInputType.text,
          maxLiens: 6,
        ),
        CustomDropDownButtonField(
          hintText: 'العمل',
          labelText: 'الفئة',
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
        ),
        CustomDropDownButtonField(
          hintText: 'اسبوعي',
          labelText: 'التكرار',
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
        ),
        Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(radius: 6, backgroundColor: Color(0xFF726CC9)),
                    SizedBox(width: 8),
                    Text(
                      'اختر أيقونة',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                IconsGridView(
                  onIconSelected: (icon, color) {
                    setState(() {
                      selectedIcon = icon;
                      selectedColor = color;
                    });
                  },
                ),
                SizedBox(height: 24),
                CustomButton(text: 'تعديل المهمة', hasIcon: true),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
