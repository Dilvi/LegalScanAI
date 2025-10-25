import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  // 📡 — поставь свой IP или домен сервера FastAPI
  static const String _baseUrl = "http://95.165.74.131:8000";
  static const Map<String, String> _headers = {
    "Content-Type": "application/json; charset=utf-8",
  };

  /// =======================
  /// 📝 Анализ текста
  /// =======================
  static Future<Map<String, dynamic>> analyzeText(
      String text, {
        required String docType,
      }) async {
    final url = Uri.parse("$_baseUrl/analyze");

    try {
      final response = await http
          .post(
        url,
        headers: _headers,
        body: jsonEncode({
          "text": text,
          "docType": docType,
        }),
      )
          .timeout(const Duration(seconds: 30)); // ⏳ таймаут

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return {
          'result': data['result'] ?? "Нет результата",
          'hasRisk': data['has_risk'] ?? false,
        };
      } else {
        throw HttpException(
            "Ошибка сервера (${response.statusCode}): ${response.reasonPhrase}");
      }
    } on SocketException {
      throw Exception("❌ Нет подключения к серверу");
    } on HttpException catch (e) {
      throw Exception("❌ $e");
    } on FormatException {
      throw Exception("❌ Некорректный формат ответа от сервера");
    } catch (e) {
      throw Exception("❌ Неизвестная ошибка: $e");
    }
  }

  /// =======================
  /// 📸 Анализ изображения
  /// =======================
  static Future<String> analyzeImage(
      String imagePath, {
        required String docType,
      }) async {
    final url = Uri.parse("$_baseUrl/analyze-image");

    try {
      var request = http.MultipartRequest('POST', url);
      request.fields['docType'] = docType;

      // 📌 Определяем MIME-тип
      final mimeType = lookupMimeType(imagePath) ?? 'image/jpeg';
      final mimeParts = mimeType.split('/');

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imagePath,
        contentType: MediaType(mimeParts[0], mimeParts[1]),
      ));

      var streamedResponse =
      await request.send().timeout(const Duration(seconds: 60));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['result'] ?? "Нет результата";
      } else {
        throw HttpException(
            "Ошибка сервера (${response.statusCode}): ${response.reasonPhrase}");
      }
    } on SocketException {
      return "❌ Нет подключения к серверу";
    } on HttpException catch (e) {
      return "❌ $e";
    } on FormatException {
      return "❌ Некорректный формат ответа от сервера";
    } catch (e) {
      return "❌ Неизвестная ошибка: $e";
    }
  }

  /// =======================
  /// 💬 Чат (LegalMind)
  /// =======================
  static Future<String> sendMessage(String text) async {
    final url = Uri.parse("$_baseUrl/chat");

    try {
      final response = await http
          .post(
        url,
        headers: _headers,
        body: jsonEncode({"text": text}),
      )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['response']?.toString() ?? "Нет ответа";
      } else {
        throw HttpException(
            "Ошибка сервера (${response.statusCode}): ${response.reasonPhrase}");
      }
    } on SocketException {
      return "❌ Нет подключения к серверу";
    } on HttpException catch (e) {
      return "❌ $e";
    } on FormatException {
      return "❌ Некорректный формат ответа от сервера";
    } catch (e) {
      return "❌ Неизвестная ошибка: $e";
    }
  }
}
