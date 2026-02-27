import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/story_model.dart';

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _storage = const FlutterSecureStorage();
  
  // Base URL handling
  String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080/api';
    return 'http://localhost:8080/api';
  }

  // Helper for headers with token
  Future<Map<String, String>> _getHeaders() async {
    String? token = await _storage.read(key: 'jwt_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // --- Authentication ---

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token']; // Adjust based on actual backend response
        await _storage.write(key: 'jwt_token', value: token);
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('Login Error: $e');
      return false;
    }
  }

  Future<String?> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return null; // Success
      } else {
        final data = jsonDecode(response.body);
        return data['message'] ?? 'Registration failed: ${response.statusCode}';
      }
    } catch (e) {
      if (kDebugMode) print('Register Error: $e');
      return 'Connection Error: $e';
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<bool> isLoggedIn() async {
    String? token = await _storage.read(key: 'jwt_token');
    return token != null;
  }

  // --- Data Fetching ---

  Future<User?> getUserProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/users/me'), // Assuming /me endpoint exists, or adjust
        headers: headers,
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      if (kDebugMode) print('Get User Error: $e');
    }
    return null;
  }

  Future<List<Post>> getPosts() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/posts'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Post.fromJson(json)).toList();
      }
    } catch (e) {
      if (kDebugMode) print('Get Posts Error: $e');
    }
    return [];
  }

  Future<List<Story>> getStories() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/stories'), // Assuming endpoint
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Story.fromJson(json)).toList();
      }
    } catch (e) {
      if (kDebugMode) print('Get Stories Error: $e');
    }
    return [];
  }
}
