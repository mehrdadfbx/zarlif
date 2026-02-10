// api/cargo_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zarlif/utils/storage_service.dart';
import '../models/CargoModel.dart';

class CargoApi {
  static const String _baseUrl = 'https://www.balutapp.ir/zarlif/api';
  static const String _saveExperimentEndpoint = '/saveExperiment';

  // متد برای ساخت هدرها
  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': ?token,
    };
  }

  // متد ذخیره آزمایش
  static Future<SaveExperimentResponse> saveExperiment(
    SaveExperimentRequest request,
  ) async {
    try {
      final url = Uri.parse('$_baseUrl$_saveExperimentEndpoint');

      print('📤 ارسال درخواست به: $url');
      print('📦 بدنه درخواست: ${request.toJsonString()}');

      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: request.toJsonString(),
      );

      print('📥 وضعیت پاسخ: ${response.statusCode}');
      print('📄 بدنه پاسخ: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);

          return SaveExperimentResponse(
            statusCode: response.statusCode,
            status: responseData['status'] ?? 'success',
            message: responseData['message'] ?? 'آزمایش با موفقیت ذخیره شد',
            data: responseData['data'],
            success: true,
          );
        } catch (e) {
          // اگر JSON نامعتبر است
          return SaveExperimentResponse(
            statusCode: response.statusCode,
            status: 'success',
            message: 'آزمایش با موفقیت ذخیره شد',
            data: response.body,
            success: true,
          );
        }
      } else {
        // خطای سرور
        try {
          final responseData = json.decode(response.body);
          return SaveExperimentResponse(
            statusCode: response.statusCode,
            status: 'error',
            message:
                responseData['message'] ??
                'خطا در ارتباط با سرور: ${response.statusCode}',
            data: responseData,
            success: false,
          );
        } catch (e) {
          return SaveExperimentResponse(
            statusCode: response.statusCode,
            status: 'error',
            message: 'خطا در ارتباط با سرور: ${response.statusCode}',
            data: null,
            success: false,
          );
        }
      }
    } catch (e) {
      // خطای شبکه یا دیگر خطاها
      print('❌ خطا در ذخیره آزمایش: $e');
      return SaveExperimentResponse(
        statusCode: 0,
        status: 'error',
        message: 'خطا در ارتباط با سرور: $e',
        data: null,
        success: false,
      );
    }
  }
}

// کلاس مدیریت خطاهای API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorType;

  ApiException(this.message, {this.statusCode, this.errorType});

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException [$errorType]: $message (Status: $statusCode)';
    }
    return 'ApiException [$errorType]: $message';
  }
}
