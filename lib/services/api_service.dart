import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'config.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/auth_service.dart';
import '../pages/login_page.dart';
import '../pages/home_page.dart';

class ApiService {
  static String baseUrl = AppConfig.baseUrl;
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static void setBaseUrl(String url) {
    baseUrl = url;
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  static Future<void> setToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  static Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final token = await getToken();
    final allHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };
    return http.get(Uri.parse('$baseUrl$endpoint'), headers: allHeaders);
  }

  static Future<http.Response> post(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final token = await getToken();
    final allHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };
    return http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: allHeaders,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> put(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final token = await getToken();
    final allHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };
    return http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: allHeaders,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final token = await getToken();
    final allHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };
    return http.delete(Uri.parse('$baseUrl$endpoint'), headers: allHeaders);
  }

  static Future<http.Response> postMultipart(
    String endpoint, {
    required String filePath,
    required String fieldName,
    Map<String, String>? fields,
  }) async {
    final token = await getToken();
    var uri = Uri.parse('$baseUrl$endpoint');
    var request = http.MultipartRequest('POST', uri);
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
    if (fields != null) {
      request.fields.addAll(fields);
    }
    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
}
