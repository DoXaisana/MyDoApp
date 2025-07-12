import 'dart:convert';
import 'api_service.dart';

class ProfileService {
  // Fetch user profile
  static Future<Map<String, dynamic>> getProfile() async {
    final res = await ApiService.get('/profile');
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to fetch profile');
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> profile,
  ) async {
    final res = await ApiService.put('/profile', body: profile);
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to update profile');
    }
  }
}
