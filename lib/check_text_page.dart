import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CheckTextPage extends StatelessWidget {
  const CheckTextPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController textController = TextEditingController();

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
              ClipboardData? data =
                  await Clipboard.getData(Clipboard.kTextPlain);
              if (data != null) {
                textController.text = data.text!;
              }
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
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
      bottomNavigationBar: _buildBottomPanel(),
    );
  }

  Widget _buildBottomPanel() {
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
          onTap: () {
            // Действие при нажатии
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
