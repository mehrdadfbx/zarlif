// phone_login_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/auth_response.dart'; // اضافه کردن مدل جدید
import '../Api/auth_service.dart';
import 'verification_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'لطفاً شماره تلفن را وارد کنید';
    }

    final phoneRegex = RegExp(r'^09[0-9]{9}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'شماره تلفن معتبر وارد کنید (09xxxxxxxxx)';
    }

    return null;
  }

  Future<void> _login() async {
    // بستن کیبورد
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      print('🚀 شروع فرآیند ارسال کد...');

      final response = await AuthService.requestCode(phone);

      print('✅ پاسخ دریافت شد:');
      print('   کد وضعیت: ${response.statusCode}');
      print('   وضعیت: ${response.status}');
      print('   پیام: ${response.message}');

      if (!mounted) return;

      if (response.isSuccess) {
        print('🎉 موفقیت! در حال انتقال به صفحه تأیید کد...');

        // نمایش پیام موفقیت
        _showSnackBar(response.message, Colors.green);

        // ناوبری به صفحه تأیید کد
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => VerificationScreen(phone: phone),
              ),
            );
          }
        });
      } else {
        print('⚠️ خطا در پاسخ: ${response.message}');
        _showSnackBar(response.message, Colors.orange);
      }
    } catch (error) {
      print('❌ خطای سیستمی: $error');
      if (mounted) {
        _showSnackBar(
          'خطا در ارتباط با سرور. لطفاً دوباره تلاش کنید.',
          Colors.red,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // لوگو
                    Container(
                      height: 89,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Image.asset("assets/image/Logo.jpg"),
                    ),
                    const SizedBox(height: 20),

                    // عنوان
                    const Text(
                      'ورود به سامانه',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'لطفاً شماره تلفن خود را وارد کنید',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),

                    const SizedBox(height: 32),

                    // فیلد شماره تلفن
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textAlign: TextAlign.center,
                      validator: _validatePhone,
                      decoration: InputDecoration(
                        hintText: '09123456789',
                        labelText: 'شماره موبایل',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.phone_android,
                          color: Colors.blue,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // دکمه
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'دریافت کد تأیید',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // توضیحات
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'کد تأیید برای شما پیامک خواهد شد',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
