import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';

import 'subscription_page.dart';
import 'home_page.dart';

class ResultPage extends StatefulWidget {
  final String analyzedText;
  final String? originalText;
  final bool? hasRisk;
  final String docType;

  const ResultPage({
    super.key,
    required this.analyzedText,
    this.originalText,
    this.hasRisk,
    required this.docType,
  });

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage>
    with SingleTickerProviderStateMixin {
  bool isSaved = false;
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ru_RU', null);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasRisk = widget.hasRisk ?? false;

    return WillPopScope(
      onWillPop: () async {
        await _handleBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: SvgPicture.asset(
              "assets/back_button.svg",
              width: 24,
              height: 24,
            ),
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
        body: SafeArea(
          bottom: false,
          child: FadeTransition(
            opacity: _fadeIn,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRiskBanner(hasRisk),
                    const SizedBox(height: 20),
                    // ✨ Добавляем надпись бренда
                    const Text(
                      "✨ Результат анализа от LegalScanAI",
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF800000),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Html(
                      data: widget.analyzedText,
                      style: {
                        "body": Style(
                          fontFamily: 'DM Sans',
                          fontSize: FontSize(16),
                          lineHeight: LineHeight.number(1.6),
                          color: Colors.black87,
                        ),
                        "h2": Style(
                          fontSize: FontSize(20),
                          fontWeight: FontWeight.bold,
                          margin: Margins.only(top: 16, bottom: 8),
                        ),
                        "h3": Style(
                          fontSize: FontSize(18),
                          fontWeight: FontWeight.w600,
                          margin: Margins.only(top: 14, bottom: 6),
                        ),
                        "b": Style(fontWeight: FontWeight.bold),
                        "i": Style(fontStyle: FontStyle.italic),
                        "hr": Style(
                          margin: Margins.symmetric(vertical: 12),
                          border: Border(
                            top: BorderSide(color: Colors.grey.shade300, width: 1),
                          ),
                        ),
                        "code": Style(
                          backgroundColor: Colors.grey.shade200,
                          padding: HtmlPaddings.all(4),
                          fontFamily: 'monospace',
                        ),
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomPanel(context),
      ),
    );
  }

  Widget _buildRiskBanner(bool hasRisk) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasRisk ? const Color(0xFFFFE5E5) : const Color(0xFFE5FFE7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            hasRisk ? Icons.warning_amber_rounded : Icons.check_circle_outline,
            color: hasRisk ? Colors.red[800] : Colors.green[700],
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hasRisk
                  ? "В документе обнаружены потенциальные риски"
                  : "Критических рисков не обнаружено",
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: hasRisk ? Colors.red[800] : Colors.green[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📌 Нижняя панель — старая версия с бордовым фоном
  Widget _buildBottomPanel(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF800000),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, -2),
          )
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(top: 12, bottom: 12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSquare("Расширенный\nанализ", "assets/advanced_analysis_icon.svg", _handleAdvancedAnalysis),
              _buildSquare("Сохранить", "assets/save_icon.svg", isSaved ? null : _saveResult),
              _buildSquare("Поделиться", "assets/share_icon.svg", _shareResult),
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
            splashColor: onTap != null
                ? const Color(0xFF800000).withOpacity(0.15)
                : Colors.transparent,
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
    final formattedDate =
    DateFormat('dd MMMM yyyy, HH:mm:ss', 'ru_RU').format(DateTime.now());

    if (!isSaved) {
      final checkData = {
        'type': widget.docType,
        'date': formattedDate,
        'hasRisk': widget.hasRisk ?? false,
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
      final formattedDate =
      DateFormat('dd MMMM yyyy, HH:mm:ss', 'ru_RU').format(DateTime.now());

      final filePath =
          '${(await getTemporaryDirectory()).path}/saved_${DateTime.now().millisecondsSinceEpoch}.html';
      final file = File(filePath);
      await file.writeAsString(widget.analyzedText);

      final newCheck = {
        'type': widget.docType,
        'date': formattedDate,
        'hasRisk': widget.hasRisk ?? true,
        'filePath': filePath,
      };

      recent.insert(0, jsonEncode(newCheck));
      await prefs.setStringList('recentChecks', recent.take(10).toList());

      if (!mounted) return;
      setState(() => isSaved = true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Результат сохранён'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _shareResult() async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/shared_result_${DateTime.now().millisecondsSinceEpoch}.html';
      final file = File(filePath);
      await file.writeAsString(widget.analyzedText);
      await Share.shareXFiles([XFile(file.path)], text: 'Результат анализа');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при отправке: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _handleAdvancedAnalysis() async {
    if (!isSaved) await _saveResult();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SubscriptionPage()),
    );
  }
}
