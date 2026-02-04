// api/sender_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sender_model.dart';
import '../utils/storage_service.dart';

class SenderApi {
  static const String _baseUrl = 'https://www.balutapp.ir/zarlif/api';

  // دریافت لیست فرستنده‌ها
  static Future<GetSendersResponse> getSenders() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('توکن یافت نشد. لطفاً مجدداً وارد شوید.');
      }

      print('📡 دریافت لیست فرستنده‌ها...');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/getAllSenders'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': token,
            },
          )
          .timeout(const Duration(seconds: 30));

      print('📡 وضعیت: ${response.statusCode}');
      print('📦 بدنه: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return GetSendersResponse.fromJson(responseData);
      } else {
        throw Exception('خطا در ارتباط با سرور: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ خطا در getSenders: $e');
      rethrow;
    }
  }

  // افزودن فرستنده جدید
  static Future<AddSenderResponse> addSender({
    required String name,
    required String phone,
    required String address,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('توکن یافت نشد. لطفاً مجدداً وارد شوید.');
      }

      print('📝 افزودن فرستنده جدید...');
      print('   نام: $name');
      print('   تلفن: $phone');
      print('   آدرس: $address');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/addSender'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': token,
            },
            body: json.encode({
              'name': name,
              'phone': phone,
              'address': address,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('📡 وضعیت: ${response.statusCode}');
      print('📦 بدنه: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return AddSenderResponse.fromJson(responseData);
      } else {
        throw Exception('خطا در ارتباط با سرور: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ خطا در addSender: $e');
      rethrow;
    }
  }

  // به‌روزرسانی فرستنده
  static Future<AddSenderResponse> updateSender({
    required int id,
    required String name,
    required String phone,
    required String address,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('توکن یافت نشد. لطفاً مجدداً وارد شوید.');
      }

      print('✏️ به‌روزرسانی فرستنده...');
      print('   ID: $id');
      print('   نام: $name');
      print('   تلفن: $phone');
      print('   آدرس: $address');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/updateSender'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': token,
            },
            body: json.encode({
              'id': id,
              'name': name,
              'phone': phone,
              'address': address,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('📡 وضعیت: ${response.statusCode}');
      print('📦 بدنه: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return AddSenderResponse.fromJson(responseData);
      } else {
        throw Exception('خطا در ارتباط با سرور: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ خطا در updateSender: $e');
      rethrow;
    }
  }

  // حذف فرستنده
  static Future<DeleteSenderResponse> deleteSender(int id) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('توکن یافت نشد. لطفاً مجدداً وارد شوید.');
      }

      print('🗑️ حذف فرستنده...');
      print('   ID: $id');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/deleteSender'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': token,
            },
            body: json.encode({'id': id}),
          )
          .timeout(const Duration(seconds: 30));

      print('📡 وضعیت: ${response.statusCode}');
      print('📦 بدنه: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return DeleteSenderResponse.fromJson(responseData);
      } else {
        throw Exception('خطا در ارتباط با سرور: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ خطا در deleteSender: $e');
      rethrow;
    }
  }
}
