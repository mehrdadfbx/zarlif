// Api/cargo_api.dart
// ignore_for_file: unused_element, avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cargomodel.dart';

class CargoApi {
  static const String _baseUrl = "https://moghzi.ir/server/zarlif/server.php";
  static const Duration _timeout = Duration(seconds: 20);

  // هدرهای ثابت درخواست‌ها
  static final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  // ================================
  // 🚀 ثبت بار در سرور
  // ================================
  static Future<Map<String, dynamic>> addCargo(CargoModel cargo) async {
    final uri = Uri.parse('$_baseUrl?action=add_cargo');

    try {
      final response = await http
          .post(uri, headers: _headers, body: jsonEncode(cargo.toJson()))
          .timeout(_timeout);

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      return {
        "success": data["success"] == true,
        "message": data["message"] ?? "ثبت موفق",
      };
    } catch (e) {
      return {"success": false, "message": "خطا: $e"};
    }
  }

  // ================================
  // 🚀 دریافت لیست تمام بارها
  // ================================
  static Future<List<CargoModel>> getAllCargos() async {
    final uri = Uri.parse("$_baseUrl?action=get_cargos");

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception("خطای سرور: ${response.statusCode}");
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));

      if (decoded["success"] != true) {
        throw Exception("خطا در دریافت داده: ${decoded['message']}");
      }

      final List list = decoded["data"] ?? [];

      // تبدیل تمام آیتم‌ها به مدل
      return list.map((item) => CargoModel.fromJson(item)).toList();
    } catch (e) {
      print("خطا در getAllCargos: $e");
      return [];
    }
  }

  // --- توابع کمکی برای لاگ
  static void _log(String action, http.Response r) {
    print("$action - کد: ${r.statusCode} | پاسخ: ${r.body}");
  }

  static void _logError(String msg) {
    print("خطای API: $msg");
  }
}
