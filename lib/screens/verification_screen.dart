// verification_screen.dart
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/auth_response.dart';
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

    // فوکوس خودکار روی اولین باکس
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

    if (code.length != 6) {
      _showSnackBar('لطفاً کد ۶ رقمی را کامل وارد کنید', Colors.red);
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final AuthResponse authResponse = await AuthService.verifyCode(
        widget.phone,
        code,
      );

      if (authResponse.success) {
        await StorageService.saveAuthData(
          authResponse.token,
          authResponse.expiresAt,
          json.encode(authResponse.user.toJson()),
        );

        _navigateToHome();
        _showSnackBar(authResponse.message, Colors.green);
      } else {
        _showSnackBar(authResponse.message, Colors.orange);
        _clearAllFields();
      }
    } catch (error) {
      _showSnackBar('خطا: $error', Colors.red);
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
      final AuthResponse authResponse = await AuthService.requestCode(
        widget.phone,
      );

      if (authResponse.success) {
        _showSnackBar('کد جدید ارسال شد', Colors.green);
        _clearAllFields();
        _startResendTimer();
      } else {
        _showSnackBar(authResponse.message, Colors.orange);
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
        content: Text(message, style: const TextStyle(fontFamily: 'Vazir')),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleTextChange(String value, int index) {
    // پاک کردن مقادیر غیر عددی
    if (value.isNotEmpty && !RegExp(r'^[0-9]$').hasMatch(value)) {
      _controllers[index].text = '';
      return;
    }

    if (value.isNotEmpty) {
      // حرکت به باکس بعدی (از راست به چپ)
      if (index > 0) {
        Future.delayed(Duration.zero, () {
          _focusNodes[index - 1].requestFocus();
        });
      } else {
        // اگر آخرین باکس بود، کیبورد را ببند و تأیید کن
        Future.delayed(Duration.zero, () {
          _focusNodes[index].unfocus();
          _verifyCode();
        });
      }
    } else {
      // اگر پاک کرد، به باکس قبلی برو (از چپ به راست)
      if (index < 5) {
        Future.delayed(Duration.zero, () {
          _focusNodes[index + 1].requestFocus();
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
    final bool isSmallScreen = MediaQuery.of(context).size.width < 400;
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isLandscape ? 500 : 400),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 20.0 : 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // لوگو
                      Container(
                        width: isSmallScreen ? 60 : 80,
                        height: isSmallScreen ? 60 : 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.verified_user,
                          size: isSmallScreen ? 30 : 40,
                          color: Colors.blue,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // عنوان
                      Text(
                        'تأیید شماره تلفن',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 20 : 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontFamily: 'Vazir',
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      // متن توضیحی
                      Text(
                        'کد تأیید به شماره ${widget.phone} ارسال شد',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Colors.grey,
                          fontFamily: 'Vazir',
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      // کدهای ۶ رقمی - چیدمان از راست به چپ
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:
                              List.generate(6, (index) {
                                    final double fieldSize = isSmallScreen
                                        ? 40
                                        : 45;

                                    return SizedBox(
                                      width: fieldSize,
                                      height: fieldSize,
                                      child: TextField(
                                        controller: _controllers[index],
                                        focusNode: _focusNodes[index],
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        maxLength: 1,
                                        textDirection: TextDirection.ltr,
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 16 : 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Vazir',
                                          color:
                                              Colors.black, // تضمین نمایش واضح
                                        ),
                                        decoration: InputDecoration(
                                          counterText: '',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Colors.blue,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding: EdgeInsets
                                              .zero, // برای نمایش بهتر متن
                                        ),
                                        onChanged: (value) =>
                                            _handleTextChange(value, index),
                                        onTap: () {
                                          // انتخاب تمام متن هنگام tap
                                          _controllers[index]
                                              .selection = TextSelection(
                                            baseOffset: 0,
                                            extentOffset:
                                                _controllers[index].text.length,
                                          );
                                        },
                                      ),
                                    );
                                  }).reversed
                                  .toList(), // معکوس کردن لیست برای نمایش از راست به چپ
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 16 : 20),

                      // دکمه تأیید
                      SizedBox(
                        width: double.infinity,
                        height: isSmallScreen ? 46 : 50,
                        child: _isLoading
                            ? _buildLoadingButton(isSmallScreen)
                            : _buildVerifyButton(isSmallScreen),
                      ),

                      SizedBox(height: isSmallScreen ? 12 : 16),

                      // دکمه ارسال مجدد
                      _buildResendButton(isSmallScreen),
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

  Widget _buildVerifyButton(bool isSmallScreen) {
    return ElevatedButton(
      onPressed: _verifyCode,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        shadowColor: Colors.blue.withOpacity(0.5),
      ),
      child: Text(
        'تأیید کد',
        style: TextStyle(
          fontSize: isSmallScreen ? 14 : 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Vazir',
        ),
      ),
    );
  }

  Widget _buildLoadingButton(bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: SizedBox(
          height: isSmallScreen ? 20 : 24,
          width: isSmallScreen ? 20 : 24,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
        ),
      ),
    );
  }

  Widget _buildResendButton(bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: _canResend && !_isResending ? _resendCode : null,
          child: _isResending
              ? SizedBox(
                  height: isSmallScreen ? 18 : 20,
                  width: isSmallScreen ? 18 : 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue,
                  ),
                )
              : Text(
                  _canResend ? 'ارسال مجدد کد' : 'ارسال مجدد ($_resendTimer)',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: _canResend ? Colors.blue : Colors.grey,
                    fontFamily: 'Vazir',
                  ),
                ),
        ),
      ],
    );
  }
}
