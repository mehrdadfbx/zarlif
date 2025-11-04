// Api/cargo_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cargomodel.dart';

class CargoApi {
  static const String baseUrl = "https://moghzi.ir/server/server.php";
  static const String addCargoAction = "add_cargo";

  static final Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  /// ثبت بار جدید
  static Future<Map<String, dynamic>> addCargo(CargoModel cargo) async {
    try {
      final uri = Uri.parse('$baseUrl?action=$addCargoAction');
      final response = await http
          .post(uri, headers: _jsonHeaders, body: jsonEncode(cargo.toJson()))
          .timeout(const Duration(seconds: 15));

      _log("ثبت بار", response);

      if (response.statusCode != 200) {
        return {"success": false, "message": "خطای سرور"};
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return {
        "success": data["success"] == true,
        "message":
            data["message"] ?? (data["success"] == true ? "ثبت موفق" : "خطا"),
      };
    } catch (e) {
      _logError("ثبت بار: $e");
      return {"success": false, "message": "خطای ارتباط"};
    }
  }

  // --- Helper ---
  static void _log(String action, http.Response r) {
    print("$action - کد: ${r.statusCode} | پاسخ: ${r.body}");
  }

  static void _logError(String msg) {
    print("خطای API: $msg");
  }
}
