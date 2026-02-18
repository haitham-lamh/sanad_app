import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sanad_app/config/app_theme.dart';
import 'package:sanad_app/controller/settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: Obx(() {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'الإعدادات',
                      style: TextStyle(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 6,
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _SettingsSection(
                  title: 'المظهر',
                  icon: Icons.palette_rounded,
                  children: [
                    _ThemeModeTile(
                      title: 'الوضع الليلي',
                      icon: Icons.dark_mode_rounded,
                      themeMode: ThemeMode.dark,
                      currentMode: settingsController.themeMode.value,
                      onTap: () => settingsController.setThemeMode(ThemeMode.dark),
                    ),
                    const SizedBox(height: 12),
                    _ThemeModeTile(
                      title: 'الوضع النهاري',
                      icon: Icons.light_mode_rounded,
                      themeMode: ThemeMode.light,
                      currentMode: settingsController.themeMode.value,
                      onTap: () => settingsController.setThemeMode(ThemeMode.light),
                    ),
                    const SizedBox(height: 12),
                    _ThemeModeTile(
                      title: 'تلقائي',
                      icon: Icons.brightness_auto_rounded,
                      themeMode: ThemeMode.system,
                      currentMode: settingsController.themeMode.value,
                      onTap: () => settingsController.setThemeMode(ThemeMode.system),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _SettingsSection(
                  title: 'الإشعارات',
                  icon: Icons.notifications_rounded,
                  children: [
                    _SwitchTile(
                      title: 'صوت الإشعارات',
                      icon: Icons.volume_up_rounded,
                      value: settingsController.notificationSoundEnabled.value,
                      onChanged: (value) =>
                          settingsController.setNotificationSound(value),
                    ),
                    const SizedBox(height: 12),
                    _SwitchTile(
                      title: 'الاهتزاز',
                      icon: Icons.vibration_rounded,
                      value: settingsController.notificationVibrationEnabled.value,
                      onChanged: (value) =>
                          settingsController.setNotificationVibration(value),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _SettingsSection(
                  title: 'إعدادات أخرى',
                  icon: Icons.settings_rounded,
                  children: [
                    _LanguageTile(
                      title: 'اللغة',
                      icon: Icons.language_rounded,
                      currentLanguage: settingsController.language.value,
                      onLanguageSelected: (lang) =>
                          settingsController.setLanguage(lang),
                    ),
                    const SizedBox(height: 12),
                    _FontSizeTile(
                      title: 'حجم الخط',
                      icon: Icons.text_fields_rounded,
                      currentSize: settingsController.fontSize.value,
                      onSizeChanged: (size) =>
                          settingsController.setFontSize(size),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _SettingsSection(
                  title: 'حول التطبيق',
                  icon: Icons.info_rounded,
                  children: [
                    _InfoTile(
                      title: 'الإصدار',
                      value: '1.0.0',
                      icon: Icons.info_outline_rounded,
                    ),
                    const SizedBox(height: 12),
                    _InfoTile(
                      title: 'المطور',
                      value: 'فريق سند',
                      icon: Icons.code_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 6,
              backgroundColor: AppTheme.primaryColor,
            ),
            const SizedBox(width: 8),
            Icon(icon, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: AppTheme.getTextPrimaryColor(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}

class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile({
    required this.title,
    required this.icon,
    required this.themeMode,
    required this.currentMode,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final ThemeMode themeMode;
  final ThemeMode currentMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = currentMode == themeMode;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.getCardBackgroundColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : AppTheme.getBorderColor(context),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppTheme.primaryColor : AppTheme.getTextSecondaryColor(context),
            ),
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? AppTheme.getTextPrimaryColor(context) : AppTheme.getTextSecondaryColor(context),
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  icon,
                  color: isSelected ? AppTheme.primaryColor : AppTheme.getTextSecondaryColor(context),
                  size: 22,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryColor,
            activeTrackColor: AppTheme.primaryColor.withOpacity(0.5),
            inactiveThumbColor: AppTheme.getTextSecondaryColor(context),
            inactiveTrackColor: AppTheme.getTextSecondaryColor(context).withOpacity(0.24),
          ),
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 22,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.title,
    required this.icon,
    required this.currentLanguage,
    required this.onLanguageSelected,
  });

  final String title;
  final IconData icon;
  final String currentLanguage;
  final ValueChanged<String> onLanguageSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              currentLanguage == 'ar' ? 'العربية' : 'English',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 22,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FontSizeTile extends StatelessWidget {
  const _FontSizeTile({
    required this.title,
    required this.icon,
    required this.currentSize,
    required this.onSizeChanged,
  });

  final String title;
  final IconData icon;
  final double currentSize;
  final ValueChanged<double> onSizeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(currentSize * 100).toInt()}%',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.getTextPrimaryColor(context),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    icon,
                    color: AppTheme.primaryColor,
                    size: 22,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: currentSize,
            min: 0.8,
            max: 1.5,
            divisions: 7,
            activeColor: AppTheme.primaryColor,
            inactiveColor: AppTheme.getTextSecondaryColor(context).withOpacity(0.24),
            onChanged: onSizeChanged,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: TextStyle(
              color: AppTheme.getTextSecondaryColor(context),
              fontSize: 14,
            ),
          ),
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 22,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
