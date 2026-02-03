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
          print('💾 توکن ذخیره شد');
        }

        _showSnackBar(response.message, Colors.green);

        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            _navigateToHome();
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

  void _navigateToHome() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
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
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SafeArea(
        child: Center(
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
                    // آیکون
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.verified,
                        size: 50,
                        color: Colors.blue,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // عنوان
                    const Text(
                      'تأیید کد',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // توضیح
                    Text(
                      'کد ۶ رقمی به ${widget.phone} ارسال شد',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 30),

                    // کدهای ۶ رقمی
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 45,
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.blue,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (value) =>
                                  _handleTextChange(value, index),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // دکمه تأیید
                    SizedBox(
                      width: double.infinity,
                      height: 50,
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
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text(
                                'تأیید کد',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // دکمه ارسال مجدد
                    TextButton(
                      onPressed: _canResend && !_isResending
                          ? _resendCode
                          : null,
                      child: _isResending
                          ? const SizedBox(
                              height: 20,
                              width: 20,
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
    );
  }
}
