import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sanad_app/view/splash_view/splash_view.dart';

import 'package:sanad_app/config/app_theme.dart';
import 'package:sanad_app/controller/task_controller.dart';
import 'package:sanad_app/controller/notification_controller.dart';
import 'package:sanad_app/controller/settings_controller.dart';
import 'package:sanad_app/services/notification_service.dart';
import 'package:sanad_app/view/main_layout.dart';
import 'package:sanad_app/view/complete_profile_view/complete_profile_view.dart';
import 'package:sanad_app/view/profile_view/profile_view.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeDateFormatting('ar');
  await Hive.initFlutter();
  await Hive.openBox('chat_conversations');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
  ]);

  await NotificationService().initialize();
  
  Get.put(TaskController(), permanent: true);
  Get.put(NotificationController(), permanent: true);
  final settingsController = Get.put(SettingsController(), permanent: true);
  
  await settingsController.loadSettings();
  print(' ${settingsController.themeMode.value}');
  
  runApp(const SanadApp());
}

String _getInitialRoute() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return '/sign-in';
  final name = user.displayName?.trim();
  if (name == null || name.isEmpty) return '/complete-profile';
  return '/home';
}

class SanadApp extends StatelessWidget {
  const SanadApp({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController = Get.find<SettingsController>();
    
    return Obx(() {
      final currentThemeMode = settingsController.themeMode.value;
      print('🔄 بناء التطبيق مع المظهر: $currentThemeMode');
      
      return GetMaterialApp(
        key: ValueKey('theme_${currentThemeMode.index}'),
        title: 'Sanad App',
        
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: currentThemeMode,
        debugShowCheckedModeBanner: false,

        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FirebaseUILocalizations.delegate,
        ],

        initialRoute: '/splash',
        
        routes: {
          '/splash': (context) => const SplashView(),
          '/sign-in': (context) {
            return SignInScreen(
              providers: [EmailAuthProvider()],
              actions: [
                ForgotPasswordAction((context, email) {
                  Navigator.pushNamed(
                    context,
                    '/forgot-password',
                    arguments: {'email': email},
                  );
                }),
                AuthStateChangeAction<SignedIn>((context, state) {
                  final name = FirebaseAuth.instance.currentUser?.displayName?.trim();
                  if (name == null || name.isEmpty) {
                    Get.offAllNamed('/complete-profile');
                  } else {
                    Get.offAllNamed('/home');
                  }
                }),
                AuthStateChangeAction<UserCreated>((context, state) {
                  Get.offAllNamed('/complete-profile');
                }),
              ],
            );
          },

          '/forgot-password': (context) {
            final arguments = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            return ForgotPasswordScreen(
              email: arguments?['email'],
              headerMaxExtent: 200,
            );
          },

          '/complete-profile': (context) => const CompleteProfileView(),

          '/profile': (context) => const ProfileView(),

          '/home': (context) => MainLayout(),
        },
      );
    });
  }
}