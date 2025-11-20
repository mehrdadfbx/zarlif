// Api/cargo_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cargomodel.dart';

class CargoApi {
  static const String _baseUrl = "https://moghzi.ir/server/server.php";
  static const Duration _timeout = Duration(seconds: 20);

  static final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  // ثبت بار
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

  // دریافت لیست بارها
  static Future<List<CargoModel>> getAllCargos() async {
    final uri = Uri.parse('$_baseUrl?action=get_lab_report');
    try {
      final response = await http.get(uri, headers: _headers).timeout(_timeout);
      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (data['success'] != true) throw Exception(data['message']);

      final List list = data['data'] as List;
      return list
          .map((json) => CargoModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('خطا در دریافت بارها: $e');
      return [];
    }
  }
}
