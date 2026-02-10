import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _phoneKey = 'user_phone';
  static const String _userDataKey = 'user_data';
  static const String _userRoleKey = 'user_role';

  static Future<void> saveAuthData({
    required String token,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_phoneKey, phone);
  }

  static Future<void> saveUserCompleteData({
    required String token,
    required Map<String, dynamic> userData,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final phone = userData['phone']?.toString() ?? '';

    await Future.wait([
      prefs.setString(_tokenKey, token),
      prefs.setString(_phoneKey, phone),
      prefs.setString(_userDataKey, json.encode(userData)),
      if (userData['role'] != null)
        prefs.setString(_userRoleKey, userData['role']!.toString()),
    ]);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);

    if (userDataString != null && userDataString.isNotEmpty) {
      try {
        return json.decode(userDataString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == 'ادمین';
  }

  static Future<bool> hasCompleteProfile() async {
    final userData = await getUserData();
    if (userData != null) {
      final name = userData['name']?.toString();
      final family = userData['family']?.toString();
      return name != null &&
          name.isNotEmpty &&
          family != null &&
          family.isNotEmpty;
    }
    return false;
  }

  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_tokenKey),
      prefs.remove(_phoneKey),
      prefs.remove(_userDataKey),
      prefs.remove(_userRoleKey),
    ]);
  }
}
