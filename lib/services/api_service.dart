import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = 'https://dummyjson.com';
  static const String _tokenKey = 'auth_token';
  static const String _usernameKey = 'username';
  static const String _emailKey = 'email';
  static const String _userIdKey = 'user_id';

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'expiresInMins': 60,
        }),
      )
          .timeout(const Duration(seconds: 15));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _saveToken(responseData['accessToken'] ?? '');
        await _saveUsername(
          responseData['firstName'] != null
              ? '${responseData['firstName']} ${responseData['lastName']}'
              : username,
        );
        await _saveUserId(responseData['id']?.toString() ?? '');
        await _saveEmail(responseData['email'] ?? '');
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ??
              'Login failed. Please check your credentials.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your internet connection.',
      };
    }
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> _saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_userIdKey);
  }
  static Future<void> _saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }
  static Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }
}