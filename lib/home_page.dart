import 'package:flutter/material.dart';

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
                // Заголовок "Добро пожаловать"
                SizedBox(height: 54),
                Text(
                  "Добро пожаловать",
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 34, // Размер шрифта 34px
                    fontWeight: FontWeight.bold, // Жирный текст
                    color: Colors.black, // Цвет черный
                  ),
                ),
                SizedBox(height: 14), // Отступ 14px
                // Подзаголовок "Последние проверки/результат анализа"
                Text(
                  "Последние проверки/результат анализа",
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 15, // Размер шрифта 15px
                    fontWeight: FontWeight.normal, // Обычный текст
                    color: Color(0xFF737C97), // Серый цвет #737C97
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
                'assets/arrow.png', // Путь к изображению
                width: 96, // Ширина стрелки (можно изменить)
                height: 96, // Высота стрелки
                fit: BoxFit.contain, // Подгонка размера
              ),
            ),
          ),

          // Нижняя панель с кнопками
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomPanel(),
          ),
        ],
      ),
    );
  }

  // Метод для создания нижней панели
  Widget _buildBottomPanel() {
    return Container(
      width: double.infinity, // На всю ширину экрана
      height: 140, // Высота 140px для размещения кнопок
      decoration: const BoxDecoration(
        color: Color(0xFF800000), // Темно-красный цвет #800000
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25), // Закругление верхнего левого угла 25px
          topRight:
              Radius.circular(25), // Закругление верхнего правого угла 25px
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 21), // Отступы по бокам 21px
        child: Column(
          children: [
            const SizedBox(height: 16), // Отступ сверху перед кнопками
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Равномерное распределение по горизонтали
              children: [
                _buildSquare("Проверить\nтекст"), // Левая кнопка
                _buildSquare("Сканировать\nдокумент"), // Центральная кнопка
                _buildSquare("Загрузить\nфайл"), // Правая кнопка
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Метод для создания квадратных кнопок
  Widget _buildSquare(String label) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            // Действие при нажатии
          },
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
