import 'package:flutter/material.dart';

class IconSelectItem extends StatelessWidget {
  const IconSelectItem({super.key, required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(6),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, size: 42, color: Colors.black87),
    );
  }
}
