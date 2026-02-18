import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sanad_app/constants/constants.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  bool _isFirstLaunch = false;
  bool _showTitle = false;
  bool _showSubtitle1 = false;
  bool _showSubtitle2 = false;
  bool _showButton = false;
  bool _checkedIntro = false;

  @override
  void initState() {
    super.initState();
    _checkAndStart();
  }

  Future<void> _checkAndStart() async {
    final prefs = await SharedPreferences.getInstance();
    final introShown = prefs.getBool(kIntroShownKey) ?? false;
    if (!mounted) return;
    setState(() {
      _isFirstLaunch = !introShown;
      _checkedIntro = true;
    });
    if (_isFirstLaunch) {
      _playIntroAnimation();
    } else {
      _goToNextScreen();
    }
  }

  Future<void> _playIntroAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _showTitle = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _showSubtitle1 = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _showSubtitle2 = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _showButton = true);
  }

  Future<void> _onStartPressed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kIntroShownKey, true);
    if (!mounted) return;
    _goToNextScreen();
  }

  Future<void> _goToNextScreen() async {
    if (_isFirstLaunch && !_showButton) return;
    if (!_isFirstLaunch) {
      await Future.delayed(const Duration(seconds: 2));
    }
    if (!mounted) return;
    final route = _getInitialRoute();
    Get.offAllNamed(route);
  }

  String _getInitialRoute() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return '/sign-in';
    final name = user.displayName?.trim();
    if (name == null || name.isEmpty) return '/complete-profile';
    return '/home';
  }

  @override
  Widget build(BuildContext context) {
    if (!_checkedIntro) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).colorScheme.primary,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/sanad_icon_white.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_isFirstLaunch) {
      return _buildIntroScreen(context);
    }

    return _buildNormalSplash(context);
  }

  Widget _buildIntroScreen(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).colorScheme.primary,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Image.asset(
                'assets/images/sanad_icon_white.png',
                width: 88,
                height: 88,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              AnimatedOpacity(
                opacity: _showTitle ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                child: const Text(
                  'سند',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AnimatedOpacity(
                opacity: _showSubtitle1 ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                child: const Text(
                  'سكرتيرك الشخصي',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AnimatedOpacity(
                opacity: _showSubtitle2 ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                child: Text(
                  'نظّم مهامك، تواصل مع المساعد الذكي، وتابع تقويمك وإشعاراتك',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ),
              const Spacer(flex: 2),
              AnimatedOpacity(
                opacity: _showButton ? 1 : 0,
                duration: const Duration(milliseconds: 400),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _showButton ? _onStartPressed : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'ابدأ',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNormalSplash(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).colorScheme.primary,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/sanad_icon_white.png',
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              const Text(
                'سند',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              Text(
                'سكرتيرك الشخصي وأكثر',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Color.fromARGB(143, 255, 255, 255),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
