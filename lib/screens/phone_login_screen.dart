import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/auth_response.dart';
import '../Api/auth_service.dart';
import '../utils/storage_service.dart';
import 'home_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty || phone.length < 10) {
      _showSnackBar(
        'لطفاً شماره تلفن معتبر وارد کنید.',
        const Color.fromARGB(255, 255, 83, 71),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final AuthResponse authResponse = await AuthService.login(phone);

      if (authResponse.success) {
        // ذخیره داده‌ها با SharedPreferences
        await StorageService.saveAuthData(
          authResponse.token,
          authResponse.expiresAt,
          json.encode(authResponse.user.toJson()),
        );

        // رفتن به صفحه اصلی
        _navigateToHome();

        _showSnackBar(authResponse.message, Colors.green);
      } else {
        _showSnackBar(authResponse.message, Colors.red);
      }
    } catch (error) {
      _showSnackBar('خطا در ارتباط با سرور: $error', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // استفاده از لوگوی شرکت
                  Image.asset(
                    'assets/image/Logo.jpg',
                    height: 80,
                    width: 80,
                    fit: BoxFit.contain,
                    // errorBuilder: (context, error, stackTrace) {
                    //   // در صورت بروز خطا در بارگذاری لوگو
                    //   // return Container(
                    //   //   height: 80,
                    //   //   width: 80,
                    //   //   decoration: BoxDecoration(
                    //   //     color: Colors.grey[200],
                    //   //     borderRadius: BorderRadius.circular(12),
                    //   //   ),
                    //   //   // child: const Icon(
                    //   //   //   Icons.business,
                    //   //   //   size: 40,
                    //   //   //   color: Colors.blue,
                    //   //   // ),
                    //   // );
                    // },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ورود به سامانه',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '09xxxxxxxxx',
                      labelText: 'شماره تلفن',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      prefixIcon: const Icon(Icons.phone_android),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                    ),
                    onSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: 20),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    height: _isLoading ? 48 : 50,
                    child: _isLoading
                        ? _buildLoadingButton()
                        : _buildLoginButton(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _login,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        shadowColor: Colors.blue.withOpacity(0.5),
      ),
      child: const Text(
        'ورود',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLoadingButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
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
