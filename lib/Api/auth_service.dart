import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_response.dart';

class AuthService {
  static const String _baseUrl = 'https://your-api-domain.com';

  static Future<AuthResponse> login(String phone) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'phone': phone}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return AuthResponse.fromJson(responseData);
    } else {
      throw Exception('خطا در ارتباط با سرور: ${response.statusCode}');
    }
  }
}
