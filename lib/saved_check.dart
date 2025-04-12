import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class SavedCheckPage extends StatelessWidget {
  final File savedFile;

  const SavedCheckPage({super.key, required this.savedFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
      backgroundColor: Colors.white,
      body: FutureBuilder<String>(
        future: savedFile.readAsString(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF800000)),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Ошибка: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Html(
                  data: snapshot.data ?? 'Файл пуст',
                  style: {
                    "body": Style(
                      fontSize: FontSize(16),
                      color: Colors.black,
                      fontFamily: 'DM Sans',
                      lineHeight: LineHeight.number(1.4),
                      whiteSpace: WhiteSpace.normal,
                    ),
                    "b": Style(fontWeight: FontWeight.bold),
                    "i": Style(fontStyle: FontStyle.italic),
                    "code": Style(
                      backgroundColor: Colors.grey.shade200,
                      padding: HtmlPaddings.symmetric(horizontal: 6, vertical: 2),
                      fontFamily: 'Courier',
                    ),
                    "h2": Style(
                      fontSize: FontSize(18),
                      fontWeight: FontWeight.bold,
                      margin: Margins.only(bottom: 8),
                    ),
                    "h3": Style(
                      fontSize: FontSize(16),
                      fontWeight: FontWeight.w600,
                      margin: Margins.only(bottom: 6),
                    ),
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
