import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = "http://10.0.2.2:8000";

  static Future<String> analyzeText(String text) async {
    final url = Uri.parse("$_baseUrl/analyze");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['result'] ?? "Нет результата";
      } else {
        return "Ошибка сервера: ${response.statusCode}";
      }
    } catch (e) {
      return "Ошибка подключения: $e";
    }
  }
}
