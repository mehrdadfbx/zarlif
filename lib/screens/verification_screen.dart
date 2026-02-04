// verification_screen.dart - بخش اصلاح شده
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/verify_code_response.dart';
import '../Api/auth_service.dart';
import '../utils/storage_service.dart';
import 'home_screen.dart';

class VerificationScreen extends StatefulWidget {
  final String phone;

  const VerificationScreen({super.key, required this.phone});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;
  int _resendTimer = 60;
  bool _canResend = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _setupFocusListeners();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _setupFocusListeners() {
    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        if (!_focusNodes[i].hasFocus && _controllers[i].text.isEmpty) {
          if (i > 0) {
            _focusNodes[i - 1].requestFocus();
          }
        }
      });
    }
  }

  void _startResendTimer() {
    _canResend = false;
    _resendTimer = 60;
    setState(() {});

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _resendTimer--;
        });
        if (_resendTimer <= 0) {
          _canResend = true;
          timer.cancel();
          setState(() {});
        }
      }
    });
  }

  Future<void> _verifyCode() async {
    String code = _controllers.map((controller) => controller.text).join();

    print('🧩 کد وارد شده: $code');

    if (code.length != 6) {
      _showSnackBar('لطفاً کد ۶ رقمی را کامل وارد کنید', Colors.red);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });

    try {
      final VerifyCodeResponse response = await AuthService.verifyCode(
        widget.phone,
        code,
      );

      print('📊 پاسخ تأیید کد:');
      print('   کد وضعیت: ${response.statusCode}');
      print('   وضعیت: ${response.status}');
      print('   پیام: ${response.message}');
      print(
        '   توکن: ${response.token != null ? "دارد (${response.token!.substring(0, 20)}...)" : "ندارد"}',
      );

      if (response.isSuccess) {
        // ذخیره توکن اگر وجود دارد
        if (response.token != null && response.token!.isNotEmpty) {
          await StorageService.saveAuthData(
            token: response.token!,
            phone: widget.phone,
          );
          print('💾 توکن ذخیره شد: ${response.token!.substring(0, 20)}...');
        }

        _showSnackBar(response.message, Colors.green);

        // ناوبری مستقیم به صفحه اصلی
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        });
      } else {
        _showSnackBar(response.message, Colors.orange);
        _clearAllFields();
      }
    } catch (error) {
      print('❌ خطا: $error');
      _showSnackBar('خطا در تأیید کد: $error', Colors.red);
      _clearAllFields();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendCode() async {
    if (!_canResend) return;

    setState(() {
      _isResending = true;
    });

    try {
      print('🔄 ارسال مجدد کد...');
      final response = await AuthService.requestCode(widget.phone);

      if (response.isSuccess) {
        _showSnackBar('کد جدید ارسال شد', Colors.green);
        _clearAllFields();
        _startResendTimer();
      } else {
        _showSnackBar(response.message, Colors.orange);
      }
    } catch (error) {
      _showSnackBar('خطا در ارسال مجدد کد: $error', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _clearAllFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    if (mounted) {
      _focusNodes[0].requestFocus();
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

  void _handleTextChange(String value, int index) {
    if (value.isNotEmpty && !RegExp(r'^[0-9]$').hasMatch(value)) {
      _controllers[index].text = '';
      return;
    }

    if (value.isNotEmpty) {
      if (index < 5) {
        Future.delayed(Duration.zero, () {
          _focusNodes[index + 1].requestFocus();
        });
      } else {
        Future.delayed(Duration.zero, () {
          _focusNodes[index].unfocus();
          _verifyCode();
        });
      }
    } else if (value.isEmpty) {
      if (index > 0) {
        Future.delayed(Duration.zero, () {
          _focusNodes[index - 1].requestFocus();
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 400;
    final double fieldSize = isSmallScreen ? 36 : 40;

    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: screenWidth * 0.9),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // آیکون
                      Container(
                        width: isSmallScreen ? 70 : 80,
                        height: isSmallScreen ? 70 : 80,
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.verified,
                          size: isSmallScreen ? 40 : 50,
                          color: Colors.blue,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // عنوان
                      Text(
                        'تأیید کد',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 22 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // توضیح
                      Text(
                        'کد ۶ رقمی به ${widget.phone} ارسال شد',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      // کدهای ۶ رقمی - نسخه اصلاح شده
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(6, (index) {
                              return SizedBox(
                                width: fieldSize,
                                height: fieldSize + 20,
                                child: TextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  style: TextStyle(
                                    fontSize: fieldSize * 0.6,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Colors.blue,
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (value) =>
                                      _handleTextChange(value, index),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // دکمه تأیید
                      SizedBox(
                        width: double.infinity,
                        height: isSmallScreen ? 46 : 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _verifyCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: isSmallScreen ? 20 : 24,
                                  width: isSmallScreen ? 20 : 24,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : Text(
                                  'تأیید کد',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // دکمه ارسال مجدد
                      TextButton(
                        onPressed: _canResend && !_isResending
                            ? _resendCode
                            : null,
                        child: _isResending
                            ? SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.blue,
                                ),
                              )
                            : Text(
                                _canResend
                                    ? 'ارسال مجدد کد'
                                    : 'ارسال مجدد ($_resendTimer ثانیه)',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 14,
                                  color: _canResend ? Colors.blue : Colors.grey,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
