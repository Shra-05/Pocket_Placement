import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DSAService {
  static const String baseUrl = 'http://localhost:5000/api/dsa';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, dynamic>> getProblem(String problemId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/problems/$problemId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch problem: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getProblems({String? topic}) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final uri = Uri.parse(
      '$baseUrl/problems',
    ).replace(queryParameters: topic == null ? null : {'topic': topic});

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['problems'] ?? []);
    }
    throw Exception('Failed to fetch problems: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> startAttempt(String problemId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/problems/$problemId/start-attempt'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to start attempt: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> checkpoint(
    String problemId, {
    List<Map<String, dynamic>>? intuitionChallengesAttempts,
    List<Map<String, dynamic>>? transferQuestionsAttempts,
    int? correctIntuitionChallenges,
    int? correctTransferQuestions,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final body = {
        if (intuitionChallengesAttempts != null)
          'intuitionChallengesAttempts': intuitionChallengesAttempts,
        if (transferQuestionsAttempts != null)
          'transferQuestionsAttempts': transferQuestionsAttempts,
        if (correctIntuitionChallenges != null)
          'correctIntuitionChallenges': correctIntuitionChallenges,
        if (correctTransferQuestions != null)
          'correctTransferQuestions': correctTransferQuestions,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/problems/$problemId/checkpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to save checkpoint: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getHint(
    String problemId,
    int hintLevel,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/problems/$problemId/hint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'hintLevel': hintLevel}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get hint: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> submitSolution(String problemId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/problems/$problemId/submit-solution'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to submit solution: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getSolution(String problemId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/problems/$problemId/solution'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch solution: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
