import 'package:flutter/material.dart';
import 'package:sanad_app/config/app_theme.dart';

class CustomDropDownButtonField extends StatelessWidget {
  const CustomDropDownButtonField({
    super.key,
    this.category,
    required this.hintText,
    required this.labelText,
    this.onChanged,
    this.onSaved,
    required this.items,
  });

  final void Function(String?)? onChanged;
  final void Function(String?)? onSaved;

  final String? category;

  final String hintText;
  final String labelText;

  final List<DropdownMenuItem<String>>? items;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(radius: 6, backgroundColor: AppTheme.primaryColor),
                SizedBox(width: 8),
                Text(
                  labelText,
                  style: TextStyle(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Directionality(
              textDirection: TextDirection.rtl,
              child: DropdownButtonFormField(
                value: category,
                onChanged: onChanged,
                onSaved: onSaved,
                dropdownColor: AppTheme.primaryColor,
                style: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
                items:items,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'يرجى تحديد الفئة';
                  } else {
                    return null;
                  }
                },
                hint: Text(
                  hintText,
                  style: TextStyle(color: AppTheme.getTextSecondaryColor(context), fontSize: 14),
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppTheme.getTextPrimaryColor(context),
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppTheme.getCardBackgroundColor(context),
                  contentPadding: EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppTheme.getBorderColor(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                  hintText: hintText,
                  hintStyle: TextStyle(color: AppTheme.getTextSecondaryColor(context)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder buildBorder([color]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color ?? Colors.white),
    );
  }
}
