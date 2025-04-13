import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'subscription_page.dart';
import 'home_page.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';




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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildFormattedSections(widget.analyzedText),
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomPanel(context),
      ),
    );
  }

  List<Widget> _buildFormattedSections(String fullText) {
    final List<Widget> widgets = [];
    final parts = fullText.split('💬 Рекомендация от LegalScanAI:');

    if (parts.isNotEmpty) {
      widgets.add(
        SelectableText(
          parts.first.trim(),
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
      );
    }

    if (parts.length > 1) {
      widgets.add(
        const SizedBox(height: 24),
      );
      widgets.add(
        const Text(
          '💬 Рекомендация от LegalScanAI:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      );
      widgets.add(
        const SizedBox(height: 8),
      );
      widgets.add(
        Html(
          data: parts.last.trim(),
          style: {
            "body": Style(
              fontSize: FontSize(16),
              fontFamily: 'DM Sans',
              color: Colors.black,
            ),
          },
        ),
      );
    }

    return widgets;
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
              _buildSquare("Расширенный\nанализ", "assets/advanced_analysis_icon.svg", _handleAdvancedAnalysis),
              _buildSquare(
                "Сохранить",
                "assets/save_icon.svg",
                isSaved ? null : _saveResult,
              ),
              _buildSquare("Поделиться", "assets/share_icon.svg", _shareResult),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareResult() async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/shared_result_${DateTime.now().millisecondsSinceEpoch}.html';
      final file = File(filePath);

      final originalText = widget.originalText ?? 'Текст недоступен';
      final match = RegExp(r'💬 Рекомендация от LegalScanAI:\s*\n([\s\S]+)').firstMatch(widget.analyzedText);
      final recommendation = match?.group(1)?.trim() ?? 'Рекомендация не найдена';

      // HTML-шаблон
      final htmlContent = '''
  <!DOCTYPE html>
  <html lang="ru">
  <head>
    <meta charset="UTF-8">
    <title>Результат анализа</title>
    <style>
      body {
        font-family: Arial, sans-serif;
        padding: 20px;
        background-color: #ffffff;
        color: #000000;
        position: relative;
      }
  
      h2 {
        color: #800000;
        margin-top: 24px;
      }
  
      .original, .recommendation {
        white-space: pre-wrap;
        line-height: 1.5;
        font-size: 16px;
      }
  
      .recommendation {
        background-color: #f7f7f7;
        border-left: 4px solid #800000;
        padding: 12px;
        margin-top: 16px;
      }
  
      .watermark-grid {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        z-index: 0;
        pointer-events: none;
        user-select: none;
        background-image: repeating-linear-gradient(
          45deg,
          rgba(128, 0, 0, 0.03) 0,
          rgba(128, 0, 0, 0.03) 1em,
          transparent 1em,
          transparent 3em
        ),
        repeating-linear-gradient(
          -45deg,
          rgba(128, 0, 0, 0.03) 0,
          rgba(128, 0, 0, 0.03) 1em,
          transparent 1em,
          transparent 3em
        );
        content: "";
      }
  
      .watermark-texts {
        position: fixed;
        top: 0;
        left: 0;
        z-index: 0;
        width: 100%;
        height: 100%;
        pointer-events: none;
        user-select: none;
      }
  
      .watermark-text {
        position: absolute;
        color: rgba(128, 0, 0, 0.05);
        font-size: 16px;
        transform: rotate(-30deg);
      }
  
      .content {
        position: relative;
        z-index: 1;
      }
    </style>
  </head>
  <body>
    <div class="watermark-grid"></div>
    <div class="watermark-texts">
      ${List.generate(100, (i) {
          final top = (i ~/ 10) * 80;
          final left = (i % 10) * 80;
          return '<div class="watermark-text" style="top: ${top}px; left: ${left}px;">LegalScanAI</div>';
        }).join()}
    </div>
  
    <div class="content">
      <h2>📝 Оригинальный текст:</h2>
      <div class="original">$originalText</div>
  
      <h2>💬 Рекомендация от LegalScanAI:</h2>
      <div class="recommendation">$recommendation</div>
    </div>
  </body>
  </html>
  ''';



      await file.writeAsString(htmlContent, encoding: utf8);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Результат анализа документа (HTML)',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при отправке: $e'), backgroundColor: Colors.red),
      );
    }
  }



  void _handleAdvancedAnalysis() async {
    if (!isSaved) {
      await _saveResult();
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SubscriptionPage()),
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
    final prefs = await SharedPreferences.getInstance();
    final recent = prefs.getStringList('recentChecks') ?? [];

    final docMatch = RegExp(r'📝 Тип документа: (.+?) \(уверенность').firstMatch(widget.analyzedText);
    final docType = docMatch?.group(1)?.trim() ?? 'Документ';
    final formattedDate = DateFormat('dd MMMM yyyy, HH:mm:ss', 'ru_RU').format(DateTime.now());

    if (!isSaved) {
      final checkData = {
        'type': docType,
        'date': formattedDate,
        'hasRisk': widget.hasRisk ?? false,
      };

      // Удаляем ТОЛЬКО если совпадает type и точная дата
      final filtered = recent.where((entry) {
        final decoded = jsonDecode(entry);
        return !(decoded['type'] == docType &&
            !decoded.containsKey('filePath') &&
            decoded['date'] == formattedDate);
      }).toList();

      filtered.insert(0, jsonEncode(checkData));
      await prefs.setStringList('recentChecks', filtered.take(10).toList());
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

      final formattedDate = DateFormat('dd MMMM yyyy, HH:mm:ss', 'ru_RU').format(DateTime.now());

      final filePath = '${(await getTemporaryDirectory()).path}/saved_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File(filePath);
      await file.writeAsString('📝 Оригинальный текст:\n$originalText\n\n💬 Рекомендация:\n$recommendation');

      // Удаляем ТОЛЬКО ту, что совпадает по типу и дате
      recent.removeWhere((entry) {
        final decoded = jsonDecode(entry);
        return decoded['type'] == docType &&
            !decoded.containsKey('filePath') &&
            decoded['date'] == formattedDate;
      });

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
