import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SaveRoutePage extends StatefulWidget {
  const SaveRoutePage({super.key});

  @override
  State<SaveRoutePage> createState() => _SaveRoutePageState();
}

class _SaveRoutePageState extends State<SaveRoutePage> {
  bool _useCloud = false;
  String _localPath = "/storage/emulated/0/LegalScanAI";

  void _changePath() {
    // TODO: Реализовать выбор директории через файловый менеджер
    setState(() {
      _localPath = "/новый/путь/к/папке";
    });
  }

  void _toggleCloud(bool value) {
    setState(() {
      _useCloud = value;
    });

    if (_useCloud) {
      // TODO: Авторизация и выбор облачной папки
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / 360;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: SvgPicture.asset(
            'assets/back_button.svg',
            width: 24 * scale,
            height: 24 * scale,
          ),
        ),
        centerTitle: true,
        title: Text(
          "Путь сохранения",
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 16 * scale,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 10 * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📂 Локальное хранилище
              Text(
                "📂 Локальное хранилище устройства",
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 14 * scale),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10 * scale),
                  border: Border.all(color: const Color(0xFF800000), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _localPath,
                        style: TextStyle(
                          fontSize: 13 * scale,
                          fontFamily: 'DM Sans',
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: _changePath,
                      child: Text(
                        "Изменить",
                        style: TextStyle(
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF800000),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ☁️ Облако
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "☁️ Использовать облако (Google Drive / Яндекс.Диск)",
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14 * scale,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Switch(
                    value: _useCloud,
                    activeColor: const Color(0xFF800000),
                    onChanged: _toggleCloud,
                  ),
                ],
              ),
              if (_useCloud)
                Padding(
                  padding: EdgeInsets.only(top: 8 * scale),
                  child: Text(
                    "Выберите облачную папку после авторизации",
                    style: TextStyle(
                      fontSize: 13 * scale,
                      color: const Color(0xFF737C97),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
