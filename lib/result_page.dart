import 'package:flutter/material.dart';

class ResultPage extends StatefulWidget {
  final String analyzedText;

  const ResultPage({super.key, required this.analyzedText});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.analyzedText);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }

  TextSpan _formatAnalyzedText(String text) {
    List<TextSpan> spans = [];
    bool isRecommendationBlock = false;

    for (String line in text.split('\n')) {
      if (line.startsWith('💬 Рекомендация от GPT-4o-mini:')) {
        // Начало блока рекомендаций
        spans.add(
          const TextSpan(
            text: '\n💬 Рекомендация от GPT-4o-mini:\n',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
          ),
        );
        isRecommendationBlock = true;
        continue;
      }

      if (isRecommendationBlock) {
        // Форматируем текст рекомендаций
        if (line.startsWith('<h2>') && line.endsWith('</h2>')) {
          // Заголовок
          spans.add(
            TextSpan(
              text: '\n${line.replaceAll('<h2>', '').replaceAll('</h2>', '')}\n',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
            ),
          );
        } else if (line.startsWith('• ')) {
          // Маркированный список
          spans.add(
            TextSpan(
              text: '${line}\n',
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          );
        } else if (line.contains('<b>') && line.contains('</b>')) {
          // Жирный текст
          spans.add(
            TextSpan(
              text: '${line.replaceAll('<b>', '').replaceAll('</b>', '')}\n',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
            ),
          );
        } else if (line.startsWith('<h2>')) {
          // Обычный текст внутри рекомендаций
          spans.add(
            TextSpan(
              text: '${line.replaceAll('<h2>', '').replaceAll('</h2>', '')}\n',
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          );
        } else {
          // Обычный текст
          spans.add(
            TextSpan(
              text: '$line\n',
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          );
        }
      } else {
        // Обычный текст вне рекомендаций
        spans.add(
          TextSpan(
            text: '$line\n',
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        );
      }
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 21),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSquare(
                  "Расширенный\nанализ",
                  "assets/advanced_analysis_icon.png",
                      () {
                    // Действие для расширенного анализа
                  },
                ),
                _buildSquare(
                  "Сохранить",
                  "assets/save_icon.png",
                      () {
                    // Действие для сохранения результата
                  },
                ),
                _buildSquare(
                  "Поделиться",
                  "assets/share_icon.png",
                      () {
                    // Действие для отправки результата
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSquare(String label, String iconPath, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Image.asset(iconPath, width: 24, height: 24),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
