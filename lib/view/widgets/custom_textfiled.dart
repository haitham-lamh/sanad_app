import 'package:flutter/material.dart';
import 'package:sanad_app/config/app_theme.dart';
import 'package:sanad_app/view/main_layout.dart';
import 'package:sanad_app/view/widgets/custom_icon_button.dart';

class CustomTextFormFiled extends StatelessWidget {
  const CustomTextFormFiled({
    super.key,
    required this.hintText,
    required this.keyboardType,
    this.onChanged,
    this.obscureText,
  });
  final String hintText;

  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final bool? obscureText;

  @override
  Widget build(BuildContext context) {
    const int calenderPageIndex = 2;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Directionality(
            textDirection: TextDirection.rtl,
            child: CustomIconButton(
              icon: Icons.send,
              radius: 31,
              iconSize: 32,
              onPressed: () {
                final mainLayoutState = MainLayout.of(context);

                if (mainLayoutState != null) {
                  mainLayoutState.changePage(calenderPageIndex);
                } else {
                  print("Error: MainLayout not found in the widget tree.");
                }
              },
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: TextField(
                style: TextStyle(color: AppTheme.getTextPrimaryColor(context)),
                cursorColor: AppTheme.primaryColor,
                cursorRadius: Radius.circular(12),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppTheme.getCardBackgroundColor(context),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppTheme.getBorderColor(context),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  hintTextDirection: TextDirection.rtl,
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                  suffixIcon: CircleAvatar(
                    backgroundColor: Colors.transparent, // لون خلفية الزر
                    child: IconButton(
                      color: AppTheme.getTextSecondaryColor(context),
                      onPressed: () {},
                      icon: Icon(
                        Icons.mic,
                        color: AppTheme.getTextPrimaryColor(context),
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
