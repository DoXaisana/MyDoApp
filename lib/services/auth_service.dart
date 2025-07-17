import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'config.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static String baseUrl = AppConfig.baseUrl;
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static void setBaseUrl(String url) {
    baseUrl = url;
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      debugPrint('Login response status:  [32m${res.statusCode} [0m');
      debugPrint('Login response body: ${res.body}');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final token = data['token'];
        if (token != null) {
          await _storage.write(key: 'jwt_token', value: token);
          return {'success': true};
        }
        return {'success': false, 'message': 'Invalid response from server'};
      } else {
        // Try to parse error message from backend
        try {
          final data = jsonDecode(res.body);
          final message = data['error'] ?? data['message'] ?? 'Login failed';
          return {'success': false, 'message': message};
        } catch (_) {
          return {'success': false, 'message': 'Login failed'};
        }
      }
    } catch (e) {
      debugPrint('Login exception: $e');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  static Future<bool> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );
      debugPrint('Register response status: ${res.statusCode}');
      debugPrint('Register response body: ${res.body}');
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('Register exception: $e');
      rethrow;
    }
  }

  static Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }
}
