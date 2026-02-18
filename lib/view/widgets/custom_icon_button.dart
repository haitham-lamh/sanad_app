import 'package:flutter/material.dart';
import 'package:sanad_app/config/app_theme.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.radius,
    required this.iconSize,
  });

  final void Function()? onPressed;
  final IconData icon;
  final double radius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Color(0xff716CC7),
      child: CircleAvatar(
        radius: radius - 1,
        backgroundColor: AppTheme.getCardBackgroundColor(context),
        child: CircleAvatar(
          radius: radius - 5,
          backgroundColor: Color(0xff716CC7),
          child: IconButton(
            color: Colors.white54,
            icon: Icon(icon, color: Colors.white, size: iconSize),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
