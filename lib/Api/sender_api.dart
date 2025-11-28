import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sender_model.dart';

class ApiActions {
  static const String addSender = "add_sender";
  static const String getSenders = "get_senders";
  static const String updateSender = "update_sender";
  static const String deleteSender = "delete_sender";
}

class SenderApi {
  static const String baseUrl = "https://moghzi.ir/server/zarlif/server.php";

  static final Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  /// افزودن فرستنده
  static Future<bool> addSender(Sender sender) async {
    try {
      final uri = Uri.parse('$baseUrl?action=${ApiActions.addSender}');
      final response = await http
          .post(
            uri,
            headers: _jsonHeaders,
            body: jsonEncode(sender.toMap()), // فقط داده‌ها (بدون action)
          )
          .timeout(const Duration(seconds: 15));

      _log("افزودن", response);

      if (response.statusCode != 200) return false;
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data["success"] == true;
    } catch (e) {
      _logError("افزودن: $e");
      return false;
    }
  }

  /// دریافت لیست
  static Future<List<Sender>> getSenders() async {
    try {
      final uri = Uri.parse('$baseUrl?action=${ApiActions.getSenders}');
      final response = await http
          .post(
            uri,
            headers: _jsonHeaders,
            body: jsonEncode({}), // body خالی
          )
          .timeout(const Duration(seconds: 15));

      _log("دریافت لیست", response);

      if (response.statusCode != 200) return [];
      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (data["success"] != true || data["data"] == null) return [];

      final List list = data["data"];
      return list.map<Sender>((item) => Sender.fromMap(item)).toList();
    } catch (e) {
      _logError("دریافت: $e");
      return [];
    }
  }

  /// ویرایش
  static Future<bool> updateSender(Sender sender) async {
    if (sender.id == null) return false;
    try {
      final uri = Uri.parse('$baseUrl?action=${ApiActions.updateSender}');
      final response = await http
          .post(uri, headers: _jsonHeaders, body: jsonEncode(sender.toMap()))
          .timeout(const Duration(seconds: 15));

      _log("ویرایش", response);
      if (response.statusCode != 200) return false;
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data["success"] == true;
    } catch (e) {
      _logError("ویرایش: $e");
      return false;
    }
  }

  /// حذف
  static Future<bool> deleteSender(int id) async {
    try {
      final uri = Uri.parse('$baseUrl?action=${ApiActions.deleteSender}');
      final response = await http
          .post(uri, headers: _jsonHeaders, body: jsonEncode({"id": id}))
          .timeout(const Duration(seconds: 15));

      _log("حذف", response);
      if (response.statusCode != 200) return false;
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data["success"] == true;
    } catch (e) {
      _logError("حذف: $e");
      return false;
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
