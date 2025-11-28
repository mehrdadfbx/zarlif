// Api/laboratory_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/laboratory_report.dart';

class LaboratoryApi {
  static const String baseUrl = 'https://moghzi.ir/server/zarlif/server.php';

  static Future<LaboratoryReport> fetchReport() async {
    final uri = Uri.parse('$baseUrl?action=get_laboratory_reports');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) throw Exception('خطای سرور');

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data['success'] != true) throw Exception(data['message'] ?? 'خطا');

      return LaboratoryReport.fromJson(data);
    } catch (e) {
      print('خطا در دریافت گزارش آزمایشگاه: $e');
      rethrow;
    }
  }
}
