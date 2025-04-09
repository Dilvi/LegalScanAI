import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:legal_scan_ai/load.dart';
import 'package:legal_scan_ai/result_page.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'package:docx_to_text/docx_to_text.dart';




class UploadFilePage extends StatefulWidget {
  const UploadFilePage({super.key});

  @override
  State<UploadFilePage> createState() => _UploadFilePageState();
}

class _UploadFilePageState extends State<UploadFilePage> {
  Future<void> _pickAndAnalyzeFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        String text = '';

        if (file.path.endsWith('.txt')) {
          text = await file.readAsString();
        } else if (file.path.endsWith('.docx')) {
          Uint8List bytes = await file.readAsBytes();
          text = docxToText(bytes);
        }

        if (text.trim().isEmpty) {
          throw Exception("Не удалось извлечь текст из файла");
        }

        Navigator.push(context, MaterialPageRoute(builder: (_) => const LoadPage()));

        final response = await ApiService.analyzeText(text);
        final resultText = response['result'];
        final hasRisk = response['hasRisk'] ?? false;

        // 🧩 Логируем результат
        print('📤 Ответ нейросети:\n$resultText');
        print('🚨 Определено наличие риска: $hasRisk');

        await _saveToRecentChecks(resultText, hasRisk);

        if (mounted) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ResultPage(analyzedText: resultText)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки файла: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  Future<void> _saveToRecentChecks(String result, bool hasRisk) async {
    final prefs = await SharedPreferences.getInstance();

    final RegExp typeReg = RegExp(r'📝 Тип документа: (.+?) \(уверенность');
    final match = typeReg.firstMatch(result);
    final docType = match != null ? match.group(1)! : 'Неизвестно';

    final checkData = {
      'type': docType,
      'date': DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now()),
      'hasRisk': hasRisk,
    };

    final existing = prefs.getStringList('recentChecks') ?? [];
    existing.insert(0, jsonEncode(checkData));
    if (existing.length > 10) existing.removeRange(10, existing.length);

    await prefs.setStringList('recentChecks', existing);
  }

  @override
  void initState() {
    super.initState();
    _pickAndAnalyzeFile();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF800000)),
      ),
    );
  }
}
