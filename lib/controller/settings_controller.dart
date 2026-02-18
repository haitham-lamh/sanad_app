import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  final Rx<ThemeMode> themeMode = ThemeMode.dark.obs;
  
  final RxBool notificationSoundEnabled = true.obs;
  final RxBool notificationVibrationEnabled = true.obs;
  
  final RxString language = 'ar'.obs;
  final RxDouble fontSize = 1.0.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final themeModeIndex = prefs.getInt('themeMode');
      if (themeModeIndex != null && themeModeIndex >= 0 && themeModeIndex < ThemeMode.values.length) {
        themeMode.value = ThemeMode.values[themeModeIndex];
        print('✅ تم تحميل المظهر: ${ThemeMode.values[themeModeIndex]}');
      } else {
        themeMode.value = ThemeMode.dark;
        print('✅ استخدام المظهر الافتراضي: ${ThemeMode.dark}');
      }
      
      notificationSoundEnabled.value = prefs.getBool('notificationSound') ?? true;
      notificationVibrationEnabled.value = prefs.getBool('notificationVibration') ?? true;
      
      language.value = prefs.getString('language') ?? 'ar';
      
      fontSize.value = prefs.getDouble('fontSize') ?? 1.0;
    } catch (e) {
      print('❌ Error loading settings: $e');
      themeMode.value = ThemeMode.dark;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('themeMode', mode.index);
      print('✅ تم حفظ المظهر: $mode (index: ${mode.index})');
    } catch (e) {
      print('❌ Error saving theme mode: $e');
    }
  }

  Future<void> setNotificationSound(bool enabled) async {
    notificationSoundEnabled.value = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notificationSound', enabled);
    } catch (e) {
      print('Error saving notification sound: $e');
    }
  }

  Future<void> setNotificationVibration(bool enabled) async {
    notificationVibrationEnabled.value = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notificationVibration', enabled);
    } catch (e) {
      print('Error saving notification vibration: $e');
    }
  }

  Future<void> setLanguage(String lang) async {
    language.value = lang;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', lang);
    } catch (e) {
      print('Error saving language: $e');
    }
  }

  Future<void> setFontSize(double size) async {
    fontSize.value = size;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('fontSize', size);
    } catch (e) {
      print('Error saving font size: $e');
    }
  }
}
