import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:sanad_app/config/app_theme.dart';
import 'package:sanad_app/view/widgets/custom_button.dart';
import 'package:sanad_app/view/widgets/custom_text_form_field.dart';

class CompleteProfileView extends StatefulWidget {
  const CompleteProfileView({super.key});

  @override
  State<CompleteProfileView> createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<CompleteProfileView> {
  final _formKey = GlobalKey<FormState>();
  String _savedName = '';
  bool _loading = false;

  Future<void> _saveName() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final name = _savedName.trim();
    if (name.isEmpty) return;

    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.currentUser?.updateProfile(displayName: name);
      if (mounted) Get.offAllNamed('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(context),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'أكمل ملفك',
            style: TextStyle(color: AppTheme.getTextPrimaryColor(context)),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'ما اسمك؟',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getTextPrimaryColor(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'سنستخدمه للترحيب بك في التطبيق.',
                    style: TextStyle(
                      color: AppTheme.getTextSecondaryColor(context),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomTextFormField(
                    labelText: 'الاسم',
                    hintText: 'أدخل اسمك',
                    keyboardType: TextInputType.name,
                    initialValue: FirebaseAuth.instance.currentUser?.displayName,
                    onSaved: (v) => _savedName = v ?? '',
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'أدخل اسمك';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: _loading ? 'جاري الحفظ...' : 'حفظ',
                    onTap: _loading ? null : _saveName,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
