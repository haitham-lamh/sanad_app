import 'package:flutter/material.dart';

class DrawerItemModel {
  final String title;
  final IconData icon;
  final void Function()? onTap;

  const DrawerItemModel({this.onTap, required this.title, required this.icon});
}
