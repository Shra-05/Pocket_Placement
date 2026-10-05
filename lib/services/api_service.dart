import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  // ======================================================
  // SIGNUP
  // ======================================================

  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ======================================================
  // LOGIN
  // ======================================================

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ======================================================
  // GET USER STREAK
  // ======================================================

  static Future<Map<String, dynamic>> getStreak({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/streak'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ======================================================
  // UPDATE USER STREAK
  // ======================================================

  static Future<Map<String, dynamic>> updateStreak({
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/streak/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}