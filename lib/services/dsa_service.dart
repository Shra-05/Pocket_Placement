import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DSAService {
  static const String baseUrl = 'http://localhost:5000/api/dsa';

  // Helper: Get auth token from SharedPreferences
  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Helper: Build headers with auth token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ============ FETCH PROBLEM ============
  // Get problem details + user's progress on it
  static Future<Map<String, dynamic>> getProblem(String problemId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/problems/$problemId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 404) {
        throw Exception('Problem not found.');
      } else {
        throw Exception('Error fetching problem: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching problem: $e');
    }
  }

  // ============ START ATTEMPT ============
  // Begin a new attempt on a problem
  static Future<Map<String, dynamic>> startAttempt(String problemId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/problems/$problemId/start-attempt'),
        headers: headers,
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Error starting attempt: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error starting attempt: $e');
    }
  }

  // ============ SUBMIT CHECKPOINT ============
  // Submit answer to a reasoning checkpoint
  static Future<Map<String, dynamic>> submitCheckpoint({
    required String problemId,
    required int checkpointNumber,
    required String checkpointType,
    required String userResponse,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/problems/$problemId/checkpoint'),
        headers: headers,
        body: jsonEncode({
          'checkpointNumber': checkpointNumber,
          'checkpointType': checkpointType,
          'userResponse': userResponse,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 400) {
        throw Exception('Invalid checkpoint submission.');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Error submitting checkpoint: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error submitting checkpoint: $e');
    }
  }

  // ============ GET HINT ============
  // Request a hint at a specific level
  static Future<Map<String, dynamic>> getHint({
    required String problemId,
    required int hintLevel,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/problems/$problemId/hint'),
        headers: headers,
        body: jsonEncode({'hintLevel': hintLevel}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 400) {
        throw Exception('Cannot get hint. Check your attempt status.');
      } else if (response.statusCode == 404) {
        throw Exception('Hint not found.');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Error getting hint: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting hint: $e');
    }
  }

  // ============ SUBMIT SOLUTION ============
  // Submit final approach + explanation after working through checkpoints
  static Future<Map<String, dynamic>> submitSolution({
    required String problemId,
    required String selectedApproach,
    required String selectedApproachExplanation,
    required String userThoughtProcess,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/problems/$problemId/submit-solution'),
        headers: headers,
        body: jsonEncode({
          'selectedApproach': selectedApproach,
          'selectedApproachExplanation': selectedApproachExplanation,
          'userThoughtProcess': userThoughtProcess,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 400) {
        throw Exception('Invalid solution submission.');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Error submitting solution: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error submitting solution: $e');
    }
  }

  // ============ GET OPTIMAL SOLUTION ============
  // View the optimal solution explanation (only after submission)
  static Future<Map<String, dynamic>> getOptimalSolution(
    String problemId,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/problems/$problemId/solution'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 400) {
        throw Exception('You must attempt the problem first.');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 404) {
        throw Exception('Problem not found.');
      } else {
        throw Exception('Error fetching solution: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching solution: $e');
    }
  }
}
