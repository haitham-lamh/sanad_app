import 'package:flutter/material.dart';
import 'package:sanad_app/config/app_theme.dart';

class CustomSelectDateTimeField extends StatelessWidget {
  const CustomSelectDateTimeField({
    super.key,
    required this.hintText,
    required this.labelText,
    required this.keyboardType,
    this.onChanged,
    this.onPressed, required this.dateTimeController,
  });

  final String hintText;
  final String labelText;

  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final TextEditingController dateTimeController;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            TextField(
              controller: dateTimeController,
              readOnly: true,
              style: TextStyle(color: AppTheme.getTextPrimaryColor(context)),
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.getCardBackgroundColor(context),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.getBorderColor(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                ),

                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today, color: AppTheme.getTextPrimaryColor(context)),
                  onPressed: onPressed,
                ),
                hintTextDirection: TextDirection.rtl,
                hintText: hintText,
                hintStyle: TextStyle(color: AppTheme.getTextSecondaryColor(context), fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
