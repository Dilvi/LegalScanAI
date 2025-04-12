import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'home_page.dart';
import 'saved_check.dart';

class ResultPage extends StatefulWidget {
  final String analyzedText;
  final String? originalText;
  final bool? hasRisk;

  const ResultPage({
    super.key,
    required this.analyzedText,
    this.originalText,
    this.hasRisk,
  });

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late TextEditingController _textController;
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.analyzedText);
    initializeDateFormatting('ru_RU', null);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _handleBack();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: SvgPicture.asset("assets/back_button.svg", width: 24, height: 24),
            onPressed: _handleBack,
          ),
          title: const Text(
            "Результат анализа",
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: SelectableText.rich(
              _formatAnalyzedText(widget.analyzedText),
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomPanel(context),
      ),
    );
  }

  TextSpan _formatAnalyzedText(String text) {
    List<TextSpan> spans = [];

    for (String line in text.split('\n')) {
      if (line.startsWith('💬 Рекомендация от LegalScanAI:')) {
        spans.add(const TextSpan(
          text: '\n💬 Рекомендация от LegalScanAI:\n',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
        ));
        continue;
      }

      spans.add(
        TextSpan(
          text: '$line\n',
          style: TextStyle(
            fontSize: 16,
            fontWeight: (line.contains('<b>') && line.contains('</b>'))
                ? FontWeight.bold
                : FontWeight.normal,
            color: Colors.black,
          ),
        ),
      );
    }
    return TextSpan(children: spans);
  }

  Widget _buildBottomPanel(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: const BoxDecoration(
        color: Color(0xFF800000),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSquare("Расширенный\nанализ", "assets/advanced_analysis_icon.svg", () {}),
              _buildSquare(
                "Сохранить",
                "assets/save_icon.svg",
                isSaved ? null : _saveResult,
              ),
              _buildSquare("Поделиться", "assets/share_icon.svg", () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSquare(String label, String iconPath, VoidCallback? onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          elevation: 1,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            splashColor: onTap != null ? Colors.red.withOpacity(0.2) : Colors.transparent,
            child: SizedBox(
              width: 52,
              height: 52,
              child: Center(
                child: SvgPicture.asset(
                  iconPath,
                  width: 24,
                  height: 24,
                  color: const Color(0xFF800000).withOpacity(onTap != null ? 1 : 0.4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 74,
          height: 34,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: onTap != null ? Colors.white : Colors.white.withOpacity(0.4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleBack() async {
    if (!isSaved) {
      final prefs = await SharedPreferences.getInstance();
      final recent = prefs.getStringList('recentChecks') ?? [];

      final docMatch = RegExp(r'📝 Тип документа: (.+?) \(уверенность').firstMatch(widget.analyzedText);
      final docType = docMatch?.group(1)?.trim() ?? 'Документ';

      final formattedDate = DateFormat('dd MMMM yyyy, HH:mm', 'ru_RU').format(DateTime.now());

      final checkData = {
        'type': docType,
        'date': formattedDate,
        'hasRisk': widget.hasRisk ?? true,
      };

      recent.insert(0, jsonEncode(checkData));
      await prefs.setStringList('recentChecks', recent.take(10).toList());
    }

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
    );
  }

  Future<void> _saveResult() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recent = prefs.getStringList('recentChecks') ?? [];

      final originalText = widget.originalText ?? 'Текст недоступен';
      final match = RegExp(r'💬 Рекомендация от LegalScanAI:\s*\n([\s\S]+)').firstMatch(widget.analyzedText);
      final recommendation = match?.group(1)?.trim() ?? 'Рекомендация не найдена';
      final docMatch = RegExp(r'📝 Тип документа: (.+?) \(уверенность').firstMatch(widget.analyzedText);
      final docType = docMatch?.group(1)?.trim() ?? 'Документ';

      final alreadySaved = recent.any((entry) {
        final decoded = jsonDecode(entry);
        return decoded['type'] == docType && decoded['filePath'] != null;
      });

      if (alreadySaved) return;

      final filePath = '${(await getTemporaryDirectory()).path}/saved_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File(filePath);
      await file.writeAsString('📝 Оригинальный текст:\n$originalText\n\n💬 Рекомендация:\n$recommendation');

      final formattedDate = DateFormat('dd MMMM yyyy, HH:mm', 'ru_RU').format(DateTime.now());

      final newCheck = {
        'type': docType,
        'date': formattedDate,
        'hasRisk': widget.hasRisk ?? true,
        'filePath': filePath,
      };

      recent.insert(0, jsonEncode(newCheck));
      await prefs.setStringList('recentChecks', recent.take(10).toList());

      if (!mounted) return;

      setState(() {
        isSaved = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Результат сохранён'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка: $e"), backgroundColor: Colors.red),
      );
    }
  }
}
