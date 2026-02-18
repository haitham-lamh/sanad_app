import 'package:flutter/material.dart';
import 'package:sanad_app/config/app_theme.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
    required this.userName,
    required this.icon,
    this.horPadding = 0,
    this.verPadding = 0,
    this.onPressed,
  });

  final String userName;
  final IconData icon;
  final double horPadding;
  final double verPadding;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 105,
      padding: EdgeInsets.symmetric(
        horizontal: horPadding,
        vertical: verPadding,
      ),
      decoration: BoxDecoration(color: AppTheme.getBackgroundColor(context)),
      child: Column(
        children: [
          SizedBox(height: 35),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onPressed,
                icon: Icon(icon, size: 32, color: AppTheme.getIconColor(context)),
              ),
              Spacer(),
              Text(
                userName,
                style: TextStyle(fontSize: 18, color: AppTheme.primaryColor),
              ),
              SizedBox(width: 12),
              CircleAvatar(
                radius: 26,
                backgroundColor: AppTheme.primaryColor,
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage('assets/images/profile2.png'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
