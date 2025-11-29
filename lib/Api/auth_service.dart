// auth_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zarlif/models/auth_response.dart';

class AuthService {
  static const String _baseUrl =
      'https://moghzi.ir/server/zarlif/php-auth-system.php';

  // درخواست کد تأیید
  static Future<AuthResponse> requestCode(String phone) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl?action=request_code'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'phone': phone}),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(responseData);
      } else {
        throw Exception(responseData['message'] ?? 'خطا در ارتباط با سرور');
      }
    } on http.ClientException catch (e) {
      throw Exception('خطا در ارتباط با سرور: ${e.message}');
    } on TimeoutException {
      throw Exception('اتصال به سرور زمان‌بر شد');
    } catch (e) {
      throw Exception('خطای ناشناخته: $e');
    }
  }

  // تأیید کد شش رقمی
  static Future<AuthResponse> verifyCode(String phone, String code) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl?action=verify_login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'phone': phone, 'code': code}),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(responseData);
      } else {
        throw Exception(responseData['message'] ?? 'خطا در تأیید کد');
      }
    } on http.ClientException catch (e) {
      throw Exception('خطا در ارتباط با سرور: ${e.message}');
    } on TimeoutException {
      throw Exception('اتصال به سرور زمان‌بر شد');
    } catch (e) {
      throw Exception('خطای ناشناخته: $e');
    }
  }
}
