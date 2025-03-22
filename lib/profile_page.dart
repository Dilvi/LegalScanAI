import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Верхняя панель с кнопкой назад и заголовком
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Кнопка назад
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: SvgPicture.asset(
                      "assets/back_button.svg",
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const Text(
                    "Настройки профиля",
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 48), // для симметрии с кнопкой назад
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Аватарка-кнопка
            GestureDetector(
              onTap: () {
                // TODO: добавить выбор URL-аватарки
              },
              child: const CircleAvatar(
                radius: 40, // 80px диаметр
                backgroundColor: Color(0xFF800000),
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
