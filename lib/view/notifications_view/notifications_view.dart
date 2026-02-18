import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sanad_app/config/app_theme.dart';
import 'package:sanad_app/controller/notification_controller.dart';
import 'package:sanad_app/view/notifications_view/widgets/notification_item.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  late final NotificationController _notificationController;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _notificationController = Get.find<NotificationController>();
    _notificationController.loadNotifications();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: Obx(() {
        final notifications = _notificationController.notifications;
        final now = DateTime.now();
        final dueNotifications =
            notifications.where((n) => !n.dateTime.isAfter(now)).toList();
        final upcomingCount = notifications.length - dueNotifications.length;
        final unreadCount = dueNotifications.where((n) => !n.isRead).length;

        return Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 6,
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'الإشعارات',
                        style: TextStyle(
                          color: AppTheme.getTextPrimaryColor(context),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Row(
                    children: [
                      if (notifications.isNotEmpty)
                        TextButton(
                          onPressed:
                              () => _notificationController.markAllAsRead(),
                          child: Text(
                            'قراءة الكل',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      TextButton(
                        onPressed: () => _testNotification(),
                        child: const Text(
                          'تجربة',
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (upcomingCount > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                    child: Text(
                      'لديك $upcomingCount إشعارات قادمة',
                      style: TextStyle(
                        color: AppTheme.getTextSecondaryColor(context),
                        fontSize: 12,
                      ),
                    ),
                ),
              ),
            const SizedBox(height: 24),
            Expanded(
              child:
                  dueNotifications.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: dueNotifications.length,
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final notification = dueNotifications[index];
                          return NotificationItem(
                            notification: notification,
                            onTap: () => _onNotificationTap(notification),
                            onDismiss:
                                () => _notificationController
                                    .deleteNotification(notification.id),
                          );
                        },
                      ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_rounded,
            size: 80,
            color: AppTheme.getTextSecondaryColor(context).withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد إشعارات',
            style: TextStyle(
              color: AppTheme.getTextSecondaryColor(context),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ستظهر الإشعارات هنا عند توفرها',
            style: TextStyle(
              color: AppTheme.getTextSecondaryColor(context).withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _onNotificationTap(notification) {
    _notificationController.markAsRead(notification.id);
  }

  Future<void> _testNotification() async {
    final notificationTime = DateTime.now().add(const Duration(minutes: 1));
    await _notificationController.createTestNotification(
      title: 'إشعار تجريبي',
      message: 'هذا إشعار تجريبي - سيظهر بعد دقيقة واحدة',
      notificationTime: notificationTime,
    );
    Get.snackbar(
      'تم',
      'سيظهر الإشعار بعد دقيقة واحدة',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}
