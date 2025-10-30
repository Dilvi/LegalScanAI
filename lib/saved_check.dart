import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class SavedCheckPage extends StatefulWidget {
  final String filePath;

  const SavedCheckPage({super.key, required this.filePath});

  @override
  State<SavedCheckPage> createState() => _SavedCheckPageState();
}

class _SavedCheckPageState extends State<SavedCheckPage>
    with SingleTickerProviderStateMixin {
  late File savedFile;
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    savedFile = File(widget.filePath);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String> _loadFile() async {
    if (await savedFile.exists()) {
      return await savedFile.readAsString();
    } else {
      throw Exception("Файл не найден или был удалён");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Сохранённая проверка",
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
        child: FutureBuilder<String>(
          future: _loadFile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF800000)),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    '⚠️ Ошибка: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                ),
              );
            } else {
              final htmlContent = snapshot.data ?? 'Файл пуст';
              return FadeTransition(
                opacity: _fade,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Верхняя плашка
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4E5E5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.history_edu, color: Color(0xFF800000)),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Просмотр сохранённой проверки",
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF800000),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Основной текст
                      Html(
                        data: htmlContent,
                        style: {
                          "body": Style(
                            fontFamily: 'DM Sans',
                            fontSize: FontSize(16),
                            color: Colors.black87,
                            lineHeight: LineHeight.number(1.6),
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
                              top: BorderSide(
                                  color: Colors.grey.shade300, width: 1),
                            ),
                          ),
                          "code": Style(
                            backgroundColor: Colors.grey.shade200,
                            padding: HtmlPaddings.all(4),
                            fontFamily: 'monospace',
                          ),
                        },
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
