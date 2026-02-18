import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sanad_app/config/app_theme.dart';
import 'package:sanad_app/controller/notification_controller.dart';
import 'package:sanad_app/model/drawer_item_model.dart';

class CustomDrawerItem extends StatelessWidget {
  const CustomDrawerItem({super.key, required this.drawerItemModel});

  final DrawerItemModel drawerItemModel;

  @override
  Widget build(BuildContext context) {
    final isNotifications = drawerItemModel.title == 'الإشعارات';
    
    return GestureDetector(
      onTap: drawerItemModel.onTap,
      child: ListTile(
        trailing: isNotifications
            ? Obx(() {
                final notificationController = Get.find<NotificationController>();
                final now = DateTime.now();
                final unreadCount = notificationController.notifications
                    .where((n) => !n.isRead && !n.dateTime.isAfter(now))
                    .length;
                
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      drawerItemModel.icon,
                      size: 24,
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: -8,
                        top: -8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.getBackgroundColor(context),
                              width: 2,
                            ),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              })
            : Icon(
                drawerItemModel.icon,
                size: 24,
                color: AppTheme.getTextSecondaryColor(context),
              ),
        title: Text(
          drawerItemModel.title,
          textDirection: TextDirection.rtl,
          style: TextStyle(color: AppTheme.getTextPrimaryColor(context)),
        ),
      ),
    );
  }
}
