// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:zarlif/screens/laboratory_report_screen.dart';
import 'package:zarlif/screens/CargoRegistration_Screen.dart';
import 'package:zarlif/screens/complete_profile_screen.dart';
import 'package:zarlif/Api/auth_service.dart';
import 'package:zarlif/utils/storage_service.dart';
import 'package:zarlif/models/user_info_response.dart';
import 'sender_screen.dart';
import 'sell_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  bool _isCheckingProfile = false;
  UserData? _userData;
  String? _userFullName;
  String? _userPhone;

  @override
  void initState() {
    super.initState();
    _checkUserProfile();
  }

  Future<void> _checkUserProfile() async {
    if (_isCheckingProfile) return;

    _isCheckingProfile = true;

    try {
      // بررسی آیا کاربر لاگین کرده است
      final isLoggedIn = await StorageService.isLoggedIn();

      if (!isLoggedIn) {
        // اگر لاگین نکرده، به صفحه لاگین برگردانیم
        _navigateToLogin();
        return;
      }

      // دریافت توکن
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        _navigateToLogin();
        return;
      }

      // دریافت اطلاعات کاربر
      final userInfoResponse = await AuthService.getUserInformation(token);

      if (userInfoResponse.isSuccess && userInfoResponse.data != null) {
        _userData = userInfoResponse.data;
        _userPhone = _userData!.phone;
        _userFullName = _userData!.fullName;

        // بررسی آیا کاربر نام کامل دارد یا نه
        final hasCompleteProfile = _userData!.fullName.isNotEmpty;

        if (!hasCompleteProfile) {
          // اگر نام کامل ندارد، پاپ‌اپ اجباری نمایش بده
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showCompleteProfilePopup(token, isRequired: true);
          });
        }
      } else {
        // اگر اطلاعات کاربر دریافت نشد
        _showError('خطا در دریافت اطلاعات کاربر');
      }
    } catch (error) {
      print('❌ خطا در بررسی پروفایل: $error');
      _showError('خطا در ارتباط با سرور');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isCheckingProfile = false;
        });
      }
    }
  }

  void _showCompleteProfilePopup(String token, {bool isRequired = true}) {
    showDialog(
      context: context,
      barrierDismissible: !isRequired, // اگر اجباری است، کاربر نتواند ببندد
      barrierColor: Colors.black54,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: CompleteProfileScreen(
            userData: _userData!,
            token: token,
            isRequired: isRequired,
            onProfileComplete: () {
              // وقتی پروفایل تکمیل شد، پاپ‌اپ را ببند و اطلاعات را ریفرش کن
              Navigator.of(context).pop();
              _refreshUserData();
            },
          ),
        );
      },
    );
  }

  Future<void> _refreshUserData() async {
    setState(() {
      _isLoading = true;
    });

    await _checkUserProfile();
  }

  void _navigateToLogin() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _logout() async {
    await StorageService.clearAuthData();
    _navigateToLogin();
  }

  Future<void> _editProfile() async {
    final token = await StorageService.getToken();
    if (token != null && _userData != null) {
      _showCompleteProfilePopup(token, isRequired: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.blue[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'در حال بارگذاری اطلاعات...',
                style: TextStyle(color: Colors.blue[700], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'سامانه ثبت و گزارش بار زرلیف',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              actions: [
                // آیکون خروج
                IconButton(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: Colors.white),
                  tooltip: 'خروج',
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/image/Logo.jpg',
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            size: 20,
                            color: Colors.blue,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
              shadowColor: Colors.transparent,
            ),
          ),
        ),
      ),

      // بدنه اصلی
      body: RefreshIndicator(
        onRefresh: () async {
          await _refreshUserData();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // ✅ کارت کاربر
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.blue[100],
                            child: const Icon(
                              Icons.person,
                              color: Colors.blue,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userFullName ?? 'نامشخص',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _userPhone ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _editProfile,
                            icon: const Icon(Icons.edit, size: 20),
                            tooltip: 'ویرایش پروفایل',
                          ),
                        ],
                      ),
                      if (_userData != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                _userData!.role,
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: _userData!.isAdmin
                                  ? Colors.blue[100]
                                  : Colors.grey[200],
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _userData!.isPhoneVerified
                                  ? Icons.verified
                                  : Icons.warning,
                              color: _userData!.isPhoneVerified
                                  ? Colors.green
                                  : Colors.orange,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _userData!.isPhoneVerified
                                  ? 'تلفن تأیید شده'
                                  : 'تلفن تأیید نشده',
                              style: TextStyle(
                                fontSize: 12,
                                color: _userData!.isPhoneVerified
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ✅ گرید منوها
              Expanded(child: _buildMenuGrid(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildMenuButton(
          title: 'ورود اطلاعات بارهای دریافتی',
          icon: Icons.input,
          color: Colors.green,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CargoRegistrationScreen(),
              ),
            );
          },
        ),
        _buildMenuButton(
          title: 'گزارش واحد فروش',
          icon: Icons.bar_chart,
          color: Colors.orange,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SalesScreen()),
            );
          },
        ),
        _buildMenuButton(
          title: 'فرستنده‌های بار',
          icon: Icons.send,
          color: Colors.purple,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SenderManagementScreen(isSelectionMode: false),
              ),
            );
          },
        ),
        _buildMenuButton(
          title: 'گزارش واحد آزمایشگاه',
          icon: Icons.science,
          color: Colors.red,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) =>
                    const LaboratoryReportScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
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
