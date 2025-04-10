import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'result_page.dart';
import '../services/api_service.dart';
import 'load.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CheckTextPage extends StatefulWidget {
  const CheckTextPage({super.key});

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
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset("assets/back_button.png", width: 24, height: 24),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Проверить текст",
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Image.asset("assets/paste_button.png", width: 24, height: 24),
            onPressed: () async {
              ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
              if (data != null) {
                setState(() {
                  textController.text = data.text!;
                });
              }
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: textController,
                maxLines: 20,
                decoration: InputDecoration(
                  hintText: "Введите текст для анализа",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomPanel(context),
    );
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
      child: Center(
        child: GestureDetector(
          onTap: () async {
            String inputText = textController.text.trim();
            if (inputText.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Пожалуйста, введите текст для анализа"),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoadPage()),
            );

            try {
              final response = await ApiService.analyzeText(inputText);
              final analyzedResult = response['result'];
              final hasRisk = response['hasRisk'] ?? false;

              await _saveToRecentChecks(analyzedResult, hasRisk);


              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultPage(
                    analyzedText: analyzedResult,
                    originalText: inputText, // 👈 передаём оригинальный текст
                  ),
                ),
              );

            } catch (e) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Ошибка анализа: $e"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Image.asset(
            "assets/analyze_button.png",
            width: 158,
            height: 158,
          ),
        ),
      ),
    );
  }
}
