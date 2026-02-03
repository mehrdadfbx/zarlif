// auth_service.dart - اضافه کردن تابع جدید
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zarlif/models/auth_response.dart';
import 'package:zarlif/models/verify_code_response.dart';
import 'package:zarlif/models/user_info_response.dart';

class AuthService {
  static const String _baseUrl = 'https://www.balutapp.ir/zarlif/api';

  // درخواست کد تأیید
  static Future<RequestCodeResponse> requestCode(String phone) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/register'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'phone': phone}),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);
      return RequestCodeResponse.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }

  // تأیید کد شش رقمی
  static Future<VerifyCodeResponse> verifyCode(
    String phone,
    String code,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/checkVerifyCode'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'phone': phone, 'code': code}),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

      // استخراج توکن از هدر
      String? token;
      if (response.headers.containsKey('authorization')) {
        token = response.headers['authorization'];
      }

      return VerifyCodeResponse.fromJson(responseData, token: token);
    } catch (e) {
      rethrow;
    }
  }

  static Future<UserInfoResponse> updateUserInformation({
    required String token,
    required String name,
    required String family,
  }) async {
    try {
      print('✏️ به‌روزرسانی اطلاعات کاربر...');
      print('   نام: $name');
      print('   نام خانوادگی: $family');
      print('   توکن: ${token.substring(0, 20)}...');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/updateUserInformation'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': token,
            },
            body: json.encode({'name': name, 'family': family}),
          )
          .timeout(const Duration(seconds: 30));

      print('📡 وضعیت: ${response.statusCode}');
      print('📦 بدنه: ${response.body}');
      print('🔑 هدرها: ${response.headers}');

      final responseData = json.decode(response.body);

      return UserInfoResponse.fromJson(responseData);
    } catch (e) {
      print('❌ خطا در updateUserInformation: $e');
      rethrow;
    }
  }

  // دریافت اطلاعات کاربر با توکن
  static Future<UserInfoResponse> getUserInformation(String token) async {
    try {
      print('🔍 درخواست اطلاعات کاربر...');
      print('🔑 توکن: ${token.substring(0, 20)}...');

      final response = await http
          .get(
            Uri.parse('$_baseUrl/getUserInformation'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': token,
            },
          )
          .timeout(const Duration(seconds: 30));

      print('📡 وضعیت: ${response.statusCode}');
      print('📦 بدنه: ${response.body}');

      final responseData = json.decode(response.body);

      // لاگ جزئیات پاسخ
      if (responseData['data'] != null) {
        final data = responseData['data'];
        print('👤 اطلاعات کاربر دریافت شد:');
        print('   نام: ${data['name']}');
        print('   فامیل: ${data['family']}');
        print('   تلفن: ${data['phone']}');
        print('   نقش: ${data['role']}');
        print('   وضعیت فعال: ${data['activation']}');
        print('   تأیید تلفن: ${data['phone_is_verify']}');
      }

      return UserInfoResponse.fromJson(responseData);
    } catch (e) {
      print('❌ خطا در getUserInformation: $e');
      rethrow;
    }
  }
}
