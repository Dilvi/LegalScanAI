import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const String baseUrl = "http://95.165.74.131:8080";

  /// ================================
  /// Загрузка профиля
  /// ================================
  static Future<Map<String, dynamic>?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) return null;

    final response = await http.get(
      Uri.parse("$baseUrl/profile/get"),
      headers: {
        "Authorization": token,
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      print("Ошибка загрузки профиля: ${utf8.decode(response.bodyBytes)}");
      return null;
    }
  }

  /// ================================
  /// Обновление профиля
  /// ================================
  static Future<bool> updateProfile({
    required String fullName,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) return false;

    final response = await http.post(
      Uri.parse("$baseUrl/profile/update"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": token,
      },
      body: jsonEncode({
        "fullName": fullName,
        "email": email,
      }),
    );

    return response.statusCode == 200;
  }
}
