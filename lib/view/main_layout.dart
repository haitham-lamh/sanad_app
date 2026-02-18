import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sanad_app/config/app_theme.dart';
import 'package:sanad_app/view/calender_view/calender_view.dart';
import 'package:sanad_app/view/chat_view/chat_view.dart';
import 'package:sanad_app/view/home_view/home_view.dart';
import 'package:sanad_app/view/notifications_view/notifications_view.dart';
import 'package:sanad_app/view/settings_view/settings_view.dart';
import 'package:sanad_app/view/tasks_view/tasks_view.dart';
import 'package:sanad_app/view/widgets/custom_app_bar.dart';
import 'package:sanad_app/view/widgets/custom_drawer.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});
  static MainLayoutState? of(BuildContext context) {
    return context.findAncestorStateOfType<MainLayoutState>();
  }

  @override
  State<MainLayout> createState() => MainLayoutState();
}

class MainLayoutState extends State<MainLayout> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  int currentIndex = 0;

  final List<Widget> pages = [
    HomeView(),
    const TasksView(),
    const CalenderView(),
    const ChatView(),
    const NotificationsView(),
    const SettingsView(),
  ];

  void changePage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final userName = user?.displayName?.trim().isNotEmpty == true
            ? (user!.displayName ?? 'ضيف')
            : 'ضيف';

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: AppTheme.getBackgroundColor(context),
            key: scaffoldKey,
            drawer: CustomDrawer(
              onPageSelected: changePage,
              userName: userName,
            ),
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: Directionality(
                textDirection: TextDirection.ltr,
                child: CustomAppBar(
                  userName: userName,
                  icon: Icons.menu,
                  horPadding: 16,
                  onPressed: () {
                    scaffoldKey.currentState!.openDrawer();
                  },
                ),
              ),
            ),
            body: Directionality(
              textDirection: TextDirection.ltr,
              child: IndexedStack(index: currentIndex, children: pages),
            ),
          ),
        );
      },
    );
  }
}
