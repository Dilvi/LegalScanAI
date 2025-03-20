import 'package:flutter/material.dart';
import 'check_text_page.dart'; // Импортируем страницу проверки текста

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Фон экрана - белый
      body: Stack(
        children: [
          // Верхняя часть экрана с приветствием и текстом
          const Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 40), // Отступы сверху (40px) и по бокам (20px)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 54),
                Text(
                  "Добро пожаловать",
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  "Последние проверки/результат анализа",
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    color: Color(0xFF737C97),
                  ),
                ),
              ],
            ),
          ),

          // Стрелка по центру экрана над блоком с кнопками
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(
                  bottom: 140 + 16), // Отступ над кнопками
              child: Image.asset(
                'assets/arrow.png',
                width: 96,
                height: 96,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Нижняя панель с кнопками
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomPanel(context), // Передаем context в метод
          ),
        ],
      ),
    );
  }

  // Метод для создания нижней панели
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
                _buildSquare("Проверить\nтекст", () {
                  // Открываем страницу проверки текста при нажатии
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CheckTextPage()),
                  );
                }),
                _buildSquare("Сканировать\nдокумент", () {}),
                _buildSquare("Загрузить\nфайл", () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Метод для создания квадратных кнопок
  Widget _buildSquare(String label, VoidCallback onTap) {
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
