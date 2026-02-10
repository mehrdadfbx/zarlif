// auth_service.dart - اضافه کردن تابع جدید
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:zarlif/models/auth_response.dart';
import 'package:zarlif/models/verify_code_response.dart';
import 'package:zarlif/models/user_info_response.dart';

dynamic computeJsonDecode(Map<String, dynamic> args) {
  final bodyBytes = args['bodyBytes'] as List<int>;
  final decoded = utf8.decode(bodyBytes);
  return jsonDecode(decoded);
}

class AuthService {
  static const String _baseUrl = 'https://www.balutapp.ir/zarlif/api';

  static Future<RequestCodeResponse> requestCode(String phone) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (kDebugMode) 'User-Agent': 'FlutterApp/Debug',
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/register'),
            headers: headers,
            body: jsonEncode({'phone': phone}),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = await compute(computeJsonDecode, {
        'bodyBytes': response.bodyBytes,
      });
      return RequestCodeResponse.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }

  static Future<VerifyCodeResponse> verifyCode(
    String phone,
    String code,
  ) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (kDebugMode) 'User-Agent': 'FlutterApp/Debug',
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/checkVerifyCode'),
            headers: headers,
            body: jsonEncode({'phone': phone, 'code': code}),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = await compute(computeJsonDecode, {
        'bodyBytes': response.bodyBytes,
      });

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
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': token,
        if (kDebugMode) 'User-Agent': 'FlutterApp/Debug',
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/updateUserInformation'),
            headers: headers,
            body: jsonEncode({'name': name, 'family': family}),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = await compute(computeJsonDecode, {
        'bodyBytes': response.bodyBytes,
      });
      return UserInfoResponse.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }

  static Future<UserInfoResponse> getUserInformation(String token) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': token,
        if (kDebugMode) 'User-Agent': 'FlutterApp/Debug',
      };

      final response = await http
          .post(Uri.parse('$_baseUrl/getUserInformation'), headers: headers)
          .timeout(const Duration(seconds: 30));

      final responseData = await compute(computeJsonDecode, {
        'bodyBytes': response.bodyBytes,
      });
      return UserInfoResponse.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }
}
