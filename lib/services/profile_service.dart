import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const String baseUrl = "http://95.165.74.131:8080";

  static Future<Map<String, dynamic>?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) return null;

    final response = await http.get(
      Uri.parse("$baseUrl/profile/get"),
      headers: {"Authorization": token},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Ошибка загрузки профиля: ${response.body}");
      return null;
    }
  }

  static Future<bool> updateProfile({
    required String name,
    required String surname,
    required String email,
    required String phone,
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
        "name": name,
        "surname": surname,
        "email": email,
        "phone": phone,
      }),
    );

    return response.statusCode == 200;
  }
}
