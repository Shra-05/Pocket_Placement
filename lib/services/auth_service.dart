import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    return token != null && token.isNotEmpty;
  }
}