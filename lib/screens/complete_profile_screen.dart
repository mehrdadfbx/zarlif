import 'package:flutter/material.dart';
import '../models/user_info_response.dart';
import '../Api/auth_service.dart';
import '../utils/storage_service.dart';

class CompleteProfileScreen extends StatefulWidget {
  final UserData userData;
  final String token;
  final VoidCallback? onProfileComplete;
  final bool isRequired;

  const CompleteProfileScreen({
    super.key,
    required this.userData,
    required this.token,
    this.onProfileComplete,
    this.isRequired = true,
  });

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _familyController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // اگر قبلاً نام وارد شده، آن را نمایش دهیم
    if (widget.userData.name != null) {
      _nameController.text = widget.userData.name!;
    }
    if (widget.userData.family != null) {
      _familyController.text = widget.userData.family!;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });

    try {
      print('💾 درخواست به‌روزرسانی اطلاعات کاربر...');

      // فراخوانی API به‌روزرسانی اطلاعات
      final response = await AuthService.updateUserInformation(
        token: widget.token,
        name: _nameController.text.trim(),
        family: _familyController.text.trim(),
      );

      if (response.isSuccess) {
        print('✅ اطلاعات کاربر با موفقیت به‌روزرسانی شد');

        // به‌روزرسانی اطلاعات کاربر در حافظه محلی
        final updatedUserData = widget.userData.toJson();
        updatedUserData['name'] = _nameController.text.trim();
        updatedUserData['family'] = _familyController.text.trim();

        await StorageService.saveUserCompleteData(
          token: widget.token,
          userData: updatedUserData,
        );

        _showSnackBar('اطلاعات شما با موفقیت ذخیره شد', Colors.green);

        // دریافت اطلاعات به‌روزشده از سرور
        await _fetchUpdatedUserData();

        // Callback را فراخوانی کن
        widget.onProfileComplete?.call();
      } else {
        _showSnackBar(response.message, Colors.orange);
      }
    } catch (error) {
      print('❌ خطا در ذخیره پروفایل: $error');
      _showSnackBar('خطا در ذخیره اطلاعات: $error', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchUpdatedUserData() async {
    try {
      print('🔄 دریافت اطلاعات به‌روزشده کاربر...');

      final updatedResponse = await AuthService.getUserInformation(
        widget.token,
      );

      if (updatedResponse.isSuccess && updatedResponse.data != null) {
        // ذخیره اطلاعات به‌روزشده
        await StorageService.saveUserCompleteData(
          token: widget.token,
          userData: updatedResponse.data!.toJson(),
        );

        print('✅ اطلاعات به‌روزشده ذخیره شد');
      }
    } catch (error) {
      print('⚠️ خطا در دریافت اطلاعات به‌روزشده: $error');
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'لطفاً نام خود را وارد کنید';
    }
    if (value.trim().length < 2) {
      return 'نام باید حداقل ۲ حرف باشد';
    }
    if (value.trim().length > 50) {
      return 'نام نمی‌تواند بیش از ۵۰ حرف باشد';
    }
    return null;
  }

  String? _validateFamily(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'لطفاً نام خانوادگی خود را وارد کنید';
    }
    if (value.trim().length < 2) {
      return 'نام خانوادگی باید حداقل ۲ حرف باشد';
    }
    if (value.trim().length > 50) {
      return 'نام خانوادگی نمی‌تواند بیش از ۵۰ حرف باشد';
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _familyController.dispose();
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
            child: Column(
              children: [
                // لوگو
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.person_add_alt_1,
                    size: 60,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(height: 30),

                // عنوان
                const Text(
                  'تکمیل پروفایل',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'خوش آمدید ${widget.userData.phone}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),

                const SizedBox(height: 30),

                // فرم
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // نام
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'نام',
                              hintText: 'مثال: علی',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: _validateName,
                            textInputAction: TextInputAction.next,
                            maxLength: 50,
                          ),

                          const SizedBox(height: 20),

                          // نام خانوادگی
                          TextFormField(
                            controller: _familyController,
                            decoration: InputDecoration(
                              labelText: 'نام خانوادگی',
                              hintText: 'مثال: رضایی',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: _validateFamily,
                            textInputAction: TextInputAction.done,
                            maxLength: 50,
                          ),

                          const SizedBox(height: 30),

                          // دکمه ذخیره
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveProfile,
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
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.save),
                                        SizedBox(width: 8),
                                        Text(
                                          'ذخیره اطلاعات',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          if (!widget.isRequired) ...[
                            const SizedBox(height: 15),

                            // دکمه رد کردن (اختیاری) - فقط اگر اجباری نباشد
                            TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      Navigator.pop(context);
                                    },
                              child: const Text(
                                'بعداً تکمیل می‌کنم',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // توضیحات
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[100]?.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: Colors.blue, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    'تکمیل پروفایل به شخصی‌سازی تجربه شما کمک می‌کند. ',
                                style: TextStyle(color: Colors.blue[800]),
                              ),
                              if (!widget.isRequired)
                                TextSpan(
                                  text: '(اختیاری)',
                                  style: TextStyle(
                                    color: Colors.orange[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
