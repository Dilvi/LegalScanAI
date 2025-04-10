import 'dart:io';
import 'package:flutter/material.dart';

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
                child: SelectableText(
                  snapshot.data ?? 'Файл пуст',
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'DM Sans',
                    color: Colors.black,
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
