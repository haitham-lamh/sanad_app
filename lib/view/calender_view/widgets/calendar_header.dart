import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sanad_app/config/app_theme.dart';

class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    super.key,
    required this.focusedDay,
    required this.onNext,
    required this.onPrevious,
  });

  final DateTime focusedDay;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  @override
  Widget build(BuildContext context) {
    final String monthName = DateFormat.MMMM('ar').format(focusedDay);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppTheme.getTextPrimaryColor(context),
        ),
        Column(
          children: [
            Text(
              monthName.toUpperCase(),
              style: TextStyle(
                color: AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.w700,
                fontSize: 24,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              focusedDay.year.toString(),
              style: TextStyle(color: AppTheme.getTextSecondaryColor(context)),
            ),
          ],
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.arrow_forward_ios_rounded),
          color: AppTheme.getTextPrimaryColor(context),
        ),
      ],
    );
  }
}
