import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // ======================================================
  // BACKEND URL
  // ======================================================

  static const String baseUrl = 'http://localhost:5000/api';

  // ======================================================
  // LOGOUT
  // ======================================================

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('auth_token');
  }

  // ======================================================
  // CHECK LOGIN
  // ======================================================

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('auth_token');

    return token != null && token.isNotEmpty;
  }

  // ======================================================
  // COMPLETE SKILL TEST
  // ======================================================

  static Future<bool> completeSkillTest() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('auth_token');

      // No token means user is not logged in
      if (token == null || token.isEmpty) {
        debugPrint('No authentication token found.');
        return false;
      }

      final response = await http.put(
        Uri.parse(
          '$baseUrl/auth/skill-test-complete',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Successful response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        debugPrint(
          'Skill test completion response: $data',
        );

        return data['success'] == true;
      }

      // Server returned an error
      debugPrint(
        'Skill test API failed: ${response.statusCode}',
      );

      debugPrint(response.body);

      return false;
    } catch (error) {
      debugPrint(
        'Complete skill test error: $error',
      );

      return false;
    }
  }
}