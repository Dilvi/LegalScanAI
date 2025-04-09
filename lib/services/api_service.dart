import 'dart:convert'; // Для работы с JSON
// Для работы с файлами
import 'package:http/http.dart' as http; // Для выполнения HTTP-запросов
import 'package:mime/mime.dart'; // Для определения MIME-типа
import 'package:http_parser/http_parser.dart'; // Для работы с MediaType

class ApiService {
  static const String _baseUrl = "http://localhost:8000"; // Локальный сервер через ADB

  // 🔍 Анализ текста
  static Future<Map<String, dynamic>> analyzeText(String text) async {
    final url = Uri.parse("$_baseUrl/analyze");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return {
          'result': data['result'] ?? "Нет результата",
          'hasRisk': data['has_risk'] ?? false,
        };
      } else {
        throw Exception("Ошибка сервера: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Ошибка подключения: $e");
    }
  }


  // 📷 Анализ изображения
  static Future<String> analyzeImage(String imagePath) async {
    final url = Uri.parse("$_baseUrl/analyze-image");
    try {
      var request = http.MultipartRequest('POST', url);
      String mimeType = lookupMimeType(imagePath) ?? 'image/jpeg';
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imagePath,
        contentType: MediaType(mimeType.split('/')[0], mimeType.split('/')[1]),
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        final data = jsonDecode(utf8.decode(responseData.bodyBytes)); // Используем utf8.decode
        return data['result'] ?? "Нет результата";
      } else {
        return "Ошибка сервера: ${response.statusCode}";
      }
    } catch (e) {
      return "Ошибка при распознавании изображения: $e";
    }
  }

  // 💬 Отправка сообщения в чат LegalMind
  static Future<String> sendMessage(String text) async {
    final url = Uri.parse("$_baseUrl/chat");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['response']?.toString() ?? "Нет ответа"; // Исправлено
      } else {
        return "Ошибка сервера: ${response.statusCode}";
      }
    } catch (e) {
      return "Ошибка подключения: $e";
    }
  }
}
