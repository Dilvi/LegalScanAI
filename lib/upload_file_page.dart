import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:legal_scan_ai/load.dart';
import 'package:legal_scan_ai/result_page.dart';
import '../services/api_service.dart';
import 'package:docx_to_text/docx_to_text.dart';

class UploadFilePage extends StatefulWidget {
  const UploadFilePage({super.key});

  @override
  State<UploadFilePage> createState() => _UploadFilePageState();
}

class _UploadFilePageState extends State<UploadFilePage> {
  @override
  void initState() {
    super.initState();
    _pickAndAnalyzeFile();
  }

  Future<void> _pickAndAnalyzeFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'docx'],
      );

      if (result == null || result.files.single.path == null) {
        // ⛔ Пользователь отменил выбор — возвращаемся назад
        if (mounted) Navigator.pop(context);
        return;
      }

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

      if (mounted) {
        Navigator.pop(context); // закрываем LoadPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultPage(
              analyzedText: resultText,
              originalText: text,
              hasRisk: hasRisk,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // закрываем LoadPage
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки файла: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
