// ProfileService: Service for interacting with the backend profile API.
// Provides methods to fetch and update the user's profile (username, email, image).
import 'dart:convert';
import 'api_service.dart';

class ProfileService {
  /// Fetch the user profile from the backend API by userId.
  /// Returns a map with keys: id, username, email, image (if present).
  static Future<Map<String, dynamic>> getProfile(String userId) async {
    final res = await ApiService.get('/profile/$userId');
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to fetch profile');
    }
  }

  /// Update the user profile on the backend API by userId.
  /// [profile] should contain any fields to update (username, email, image).
  /// Returns the updated user object from the backend.
  static Future<Map<String, dynamic>> updateProfile(
    String userId,
    Map<String, dynamic> profile,
  ) async {
    final res = await ApiService.put('/profile/$userId', body: profile);
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to update profile');
    }
  }

  /// Upload a profile image for the user.
  /// Returns the updated user object from the backend.
  static Future<Map<String, dynamic>> uploadProfileImage(
    String userId,
    String filePath,
  ) async {
    final res = await ApiService.postMultipart(
      '/profile/$userId/image',
      filePath: filePath,
      fieldName: 'image',
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to upload profile image');
    }
  }

  /// Change the user's password.
  static Future<void> changePassword(
    String userId,
    String oldPassword,
    String newPassword,
  ) async {
    final res = await ApiService.post(
      '/profile/$userId/password',
      body: {'oldPassword': oldPassword, 'newPassword': newPassword},
    );
    if (res.statusCode != 200) {
      String msg = 'Failed to change password';
      try {
        final data = jsonDecode(res.body);
        if (data is Map && data['error'] != null) msg = data['error'];
      } catch (_) {}
      throw Exception(msg);
    }
  }
}
