import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'result_page.dart';
import '../services/api_service.dart';
import 'load.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CheckTextPage extends StatefulWidget {
  final String docType;

  const CheckTextPage({super.key, required this.docType});

  @override
  _CheckTextPageState createState() => _CheckTextPageState();
}

class _CheckTextPageState extends State<CheckTextPage> {
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: error ? Colors.red : const Color(0xFF800000),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Проверить текст",
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Image.asset("assets/back_button.png", width: 24, height: 24),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Image.asset("assets/paste_button.png", width: 24, height: 24),
            onPressed: () async {
              ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
              if (data != null && data.text != null && data.text!.trim().isNotEmpty) {
                setState(() {
                  textController.text = data.text!;
                });
                _showSnack("Текст вставлен из буфера");
              } else {
                _showSnack("Буфер обмена пуст", error: true);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Введите текст для анализа",
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: textController,
                  maxLines: 18,
                  minLines: 8,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 15,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: "Например: Договор аренды квартиры...",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: _buildBottomPanel(context),
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context) {
    return Material(
      color: const Color(0xFF800000),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(25),
        topRight: Radius.circular(25),
      ),
      child: Container(
        width: double.infinity,
        height: 140,
        padding: const EdgeInsets.only(bottom: 10),
        child: Center(
          child: GestureDetector(
            onTap: () async {
              final inputText = textController.text.trim();
              if (inputText.isEmpty) {
                _showSnack("Введите текст для анализа", error: true);
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoadPage()),
              );

              try {
                final response = await ApiService.analyzeText(
                  inputText,
                  docType: widget.docType,
                );

                final analyzedResult = response['result'];
                final hasRisk = response['hasRisk'] ?? false;

                if (!mounted) return;
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultPage(
                      analyzedText: analyzedResult,
                      originalText: inputText,
                      hasRisk: hasRisk,
                      docType: widget.docType,
                    ),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context);
                _showSnack("Ошибка анализа: $e", error: true);
              }
            },
            child: Image.asset(
              "assets/analyze_button.png",
              width: 158,
              height: 158,
            ),
          ),
        ),
      ),
    );
  }
}
