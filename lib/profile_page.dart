import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';  // 🔥 Добавлен импорт FirebaseAuth
import 'login_page.dart';  // Импорт страницы входа
import 'security_page.dart';
import 'personal_data_page.dart';
import 'notifications_page.dart';
import 'save_route_page.dart';
import 'subscription_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _avatarImage;

  Future<void> _pickAvatarImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _avatarImage = File(picked.path);
      });
    }
  }

  // 🔥 Метод выхода из аккаунта
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ошибка выхода: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / 360;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Верхняя панель
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 12 * scale),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: SvgPicture.asset(
                      "assets/back_button.svg",
                      width: 24 * scale,
                      height: 24 * scale,
                    ),
                  ),
                  Text(
                    "Настройки профиля",
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 48 * scale), // для выравнивания
                ],
              ),
            ),

            SizedBox(height: 32 * scale),

            // Аватарка
            GestureDetector(
              onTap: _pickAvatarImage,
              child: CircleAvatar(
                radius: 40 * scale,
                backgroundColor: const Color(0xFF800000),
                backgroundImage: _avatarImage != null ? FileImage(_avatarImage!) : null,
                child: _avatarImage == null
                    ? Icon(Icons.person, size: 40 * scale, color: Colors.white)
                    : null,
              ),
            ),

            SizedBox(height: 32 * scale),

            // Кнопки профиля
            _buildProfileButton(
              "Личные данные",
              SvgPicture.asset('assets/arrow-right.svg', width: 20 * scale, height: 20 * scale),
              scale,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PersonalDataPage()),
                );
              },
            ),
            SizedBox(height: 12 * scale),

            _buildProfileButton(
              "Безопасность и вход",
              SvgPicture.asset('assets/arrow-right.svg', width: 20 * scale, height: 20 * scale),
              scale,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SecurityPage()),
                );
              },
            ),
            SizedBox(height: 12 * scale),

            _buildProfileButton(
              "Уведомления",
              SvgPicture.asset('assets/arrow-right.svg', width: 20 * scale, height: 20 * scale),
              scale,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsPage()),
                );
              },
            ),
            SizedBox(height: 12 * scale),

            _buildProfileButton(
              "Путь сохранения",
              SvgPicture.asset('assets/arrow-right.svg', width: 20 * scale, height: 20 * scale),
              scale,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SaveRoutePage()),
                );
              },
            ),
            SizedBox(height: 12 * scale),

            _buildProfileButton(
              "Подключить PRO версию",
              SvgPicture.asset('assets/arrow-right.svg', width: 20 * scale, height: 20 * scale),
              scale,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SubscriptionPage()),
                );
              },
            ),
          ],
        ),
      ),

      // Нижний бар
      bottomNavigationBar: Container(
        width: double.infinity,
        height: 134,
        decoration: const BoxDecoration(
          color: Color(0xFF800000),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Center(
          child: SizedBox(
            width: 327,
            height: 52,
            child: ElevatedButton(
              onPressed: _signOut,  // 🔥 Выход из аккаунта
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF800000),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Выйти из аккаунта",
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Метод создания кнопок профиля
  Widget _buildProfileButton(String label, Widget icon, double scale, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10 * scale),
      child: InkWell(
        onTap: onTap ?? () => debugPrint('$label tapped'),
        borderRadius: BorderRadius.circular(10 * scale),
        splashColor: const Color(0x22800000),
        highlightColor: Colors.transparent,
        child: Container(
          width: 318 * scale,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10 * scale),
            border: Border.all(color: const Color(0xFF800000), width: 1),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16 * scale),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14 * scale,
                  color: Colors.black,
                ),
              ),
              icon,
            ],
          ),
        ),
      ),
    );
  }
}
