import 'package:flutter/material.dart';
import 'package:sanad_app/config/app_theme.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.hintText,
    required this.keyboardType,
    this.onChanged,
    this.obscureText,
    required this.labelText,
    this.maxLiens = 1,
    this.onSaved,
    this.validator,
    this.initialValue,
  });

  final String hintText;
  final String labelText;

  final int maxLiens;

  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final bool? obscureText;

  final String? Function(String?)? validator;
  final String? initialValue;

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
            TextFormField(
              initialValue: initialValue,
              style: TextStyle(color: AppTheme.getTextPrimaryColor(context)),
              cursorColor: AppTheme.primaryColorVariant,
              cursorRadius: Radius.circular(12),
              maxLines: maxLiens,
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
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: const Color.fromARGB(255, 195, 41, 30), width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
                hintTextDirection: TextDirection.rtl,
                hintText: hintText,
                hintStyle: TextStyle(color: AppTheme.getTextSecondaryColor(context), fontSize: 14),
              ),
              onChanged: onChanged,
              onSaved: onSaved,
              validator:validator ,
            ),
          ],
        ),
      ),
    );
  }
}
