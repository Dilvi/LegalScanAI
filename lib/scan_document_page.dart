import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ScanDocumentPage extends StatelessWidget {
  const ScanDocumentPage({super.key});

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
          "Сканирование документа",
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
            icon: SvgPicture.asset("assets/flash_button.svg", width: 30, height: 30),
            onPressed: () {
              // Логика включения/выключения вспышки
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Камера (пока просто контейнер с надписью)
          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: const Center(
                child: Text(
                  "Камера",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ),

          // Рамка сканирования (поднята выше и по центру)
          Align(
            alignment: const Alignment(0, -0.3), // Поднята чуть выше центра
            child: SvgPicture.asset(
              "assets/photo_frame.svg",
              width: 450,
              height: 450,
            ),
          ),

          // Нижняя панель
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 140,
              decoration: const BoxDecoration(
                color: Color(0xFF800000),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Центровка с равным расстоянием
                  crossAxisAlignment: CrossAxisAlignment.center, // Выравнивание по центру по вертикали
                  children: [
                    // Пустой контейнер для балансировки
                    const SizedBox(width: 60),

                    // Кнопка фотографирования (по центру, немного выше)
                    GestureDetector(
                      onTap: () {
                        // Логика для фотографирования
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 25), // Поднять кнопку выше
                        child: SvgPicture.asset(
                          "assets/photo_button.svg",
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ),

                    // Кнопка галереи (правее от центра)
                    GestureDetector(
                      onTap: () {
                        // Логика загрузки из галереи
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20), // Поднять кнопку выше
                        child: Image.asset(
                          "assets/gallery_button.png",
                          width: 70,
                          height: 70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
