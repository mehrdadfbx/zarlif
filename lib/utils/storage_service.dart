// storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _tokenExpiryKey = 'token_expires_at';
  static const String _userDataKey = 'user_data';

  static Future<void> saveAuthData(
    String token,
    String expiresAt,
    String userData,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setString(_tokenKey, token),
        prefs.setString(_tokenExpiryKey, expiresAt),
        prefs.setString(_userDataKey, userData),
      ]);
    } catch (e) {
      throw Exception('خطا در ذخیره اطلاعات: $e');
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userDataKey);
  }

  // اضافه کردن چک کردن انقضای توکن
  static Future<bool> isTokenValid() async {
    final prefs = await SharedPreferences.getInstance();
    final expiresAt = prefs.getString(_tokenExpiryKey);

    if (expiresAt == null) return false;

    try {
      final expiryDate = DateTime.parse(expiresAt);
      return expiryDate.isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  static Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_tokenKey),
        prefs.remove(_tokenExpiryKey),
        prefs.remove(_userDataKey),
      ]);
    } catch (e) {
      throw Exception('خطا در پاک کردن اطلاعات: $e');
    }
  }
}
