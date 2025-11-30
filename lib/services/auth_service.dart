import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "http://95.165.74.131:8080";

  /// 🔤 СЛОВАРЬ ПЕРЕВОДА
  final Map<String, String> planTranslations = {
    "standard_monthly": "Месячная Стандарт",
    "premium_yearly": "Годовая Премиум",
    "standard": "Стандарт",
    "premium": "Премиум",
  };

  /// Метод для перевода
  String translatePlan(String? raw) {
    if (raw == null) return "";
    return planTranslations[raw] ?? raw;
  }

  /// 📌 Регистрация
  Future<bool> register(String email, String password, String fullName) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
        "fullName": fullName,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final token = data['token'];

      if (token == null) return false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('email', email);

      return true;
    }

    print("Ошибка регистрации: ${utf8.decode(response.bodyBytes)}");
    return false;
  }

  /// 📌 Вход
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final token = data['token'];

      if (token == null) return false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('email', email);

      return true;
    }

    print("Ошибка входа: ${utf8.decode(response.bodyBytes)}");
    return false;
  }

  /// 📌 Проверка авторизации
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

  /// 📌 Получение токена
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// 📌 Выход
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('email');
  }
}
