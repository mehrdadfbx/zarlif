import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zarlif/Api/auth_service.dart';
import 'package:zarlif/models/verify_code_response.dart';
// import 'package:zarlif/services/auth_service.dart';
import 'package:zarlif/utils/storage_service.dart';
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
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _focusNodes[0].requestFocus();
        }
      });
    });
  }

  void _setupFocusListeners() {
    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        if (!_focusNodes[i].hasFocus && _controllers[i].text.isEmpty) {
          if (i > 0) {
            Future.delayed(const Duration(milliseconds: 10), () {
              if (mounted) {
                _focusNodes[i - 1].requestFocus();
              }
            });
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
      final VerifyCodeResponse response = await AuthService.verifyCode(
        widget.phone,
        code,
      );

      if (response.isSuccess) {
        if (response.token != null && response.token!.isNotEmpty) {
          await StorageService.saveAuthData(
            token: response.token!,
            phone: widget.phone,
          );
        }

        _showSnackBar(response.message, Colors.green);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const HomeScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          }
        });
      } else {
        _showSnackBar(response.message, Colors.orange);
        _clearAllFields();
      }
    } catch (error) {
      _showSnackBar('خطا در تأیید کد: ${error.toString()}', Colors.red);
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
      final response = await AuthService.requestCode(widget.phone);

      if (response.isSuccess) {
        _showSnackBar('کد جدید ارسال شد', Colors.green);
        _clearAllFields();
        _startResendTimer();
      } else {
        _showSnackBar(response.message, Colors.orange);
      }
    } catch (error) {
      _showSnackBar('خطا در ارسال مجدد کد: ${error.toString()}', Colors.red);
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
      Future.delayed(const Duration(milliseconds: 10), () {
        _focusNodes[0].requestFocus();
      });
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
        Future.delayed(const Duration(milliseconds: 10), () {
          if (mounted) {
            _focusNodes[index + 1].requestFocus();
          }
        });
      } else {
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            _focusNodes[index].unfocus();
            _verifyCode();
          }
        });
      }
    } else if (value.isEmpty) {
      if (index > 0) {
        Future.delayed(const Duration(milliseconds: 10), () {
          if (mounted) {
            _focusNodes[index - 1].requestFocus();
          }
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
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
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

                        Text(
                          'تأیید کد',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 22 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'کد ۶ رقمی به ${widget.phone} ارسال شد',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 24),

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
                                    color: _canResend
                                        ? Colors.blue
                                        : Colors.grey,
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
      ),
    );
  }
}
