import 'package:flutter/material.dart';
import 'package:sanad_app/config/app_theme.dart';
import 'package:sanad_app/model/drawer_item_model.dart';
import 'package:sanad_app/view/widgets/custom_app_bar.dart';
import 'package:sanad_app/view/widgets/custom_drawer_items_list_view.dart';

typedef PageSelectionCallback = void Function(int index);

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    super.key,
    required this.onPageSelected,
    this.userName = 'ضيف',
  });

  final PageSelectionCallback onPageSelected;
  final String userName;

  @override
  Widget build(BuildContext context) {
    List<DrawerItemModel> items = [
      DrawerItemModel(
        title: 'الملف الشخصي',
        icon: Icons.person_rounded,
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/profile');
        },
      ),
      DrawerItemModel(
        title: 'الرئيسية',
        icon: Icons.home_rounded,
        onTap: () {
          onPageSelected(0);
          Navigator.pop(context);
        },
      ),
      DrawerItemModel(
        title: 'المهام',
        icon: Icons.task_rounded,
        onTap: () {
          onPageSelected(1);
          Navigator.pop(context);
        },
      ),
      DrawerItemModel(
        title: 'التقويم',
        icon: Icons.calendar_month_rounded,
        onTap: () {
          onPageSelected(2);
          Navigator.pop(context); // ⭐️ إضافة أمر الإغلاق هنا
        },
      ),
      DrawerItemModel(
        title: 'سنــد',
        icon: Icons.chat,
        onTap: () {
          onPageSelected(3);
          Navigator.pop(context);
        },
      ),
      DrawerItemModel(
        title: 'الإشعارات',
        icon: Icons.notifications_rounded,
        onTap: () {
          onPageSelected(4);
          Navigator.pop(context);
        },
      ),
    ];
    return Drawer(
      backgroundColor: AppTheme.getBackgroundColor(context),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            DrawerHeader(
              duration: Duration(seconds: 1900),
              curve: Curves.linear,
              child: CustomAppBar(
                userName: userName,
                icon: Icons.close,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            CustomDrawerItemsListView(items: items),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ListTile(
                    onTap: () {
                      onPageSelected(5);
                      Navigator.pop(context);
                    },
                    trailing: Icon(
                      Icons.settings,
                      size: 26,
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                    title: Text(
                      "الإعدادات",
                      textDirection: TextDirection.rtl,
                      style: TextStyle(color: AppTheme.getTextPrimaryColor(context)),
                    ),
                  ),
                  ListTile(
                    trailing: Icon(
                      Icons.policy_rounded,
                      size: 26,
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                    title: Text(
                      "الخصوصية والامان",
                      textDirection: TextDirection.rtl,
                      style: TextStyle(color: AppTheme.getTextPrimaryColor(context)),
                    ),
                  ),
                  SizedBox(height: 42),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
