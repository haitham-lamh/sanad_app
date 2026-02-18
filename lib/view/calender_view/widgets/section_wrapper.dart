import 'package:flutter/material.dart';
import 'package:sanad_app/config/app_theme.dart';

class SectionWrapper extends StatelessWidget {
  const SectionWrapper({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppTheme.getTextPrimaryColor(context),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(radius: 6, backgroundColor: AppTheme.primaryColor),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
