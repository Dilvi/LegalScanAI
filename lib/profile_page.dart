import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';

import 'login_page.dart';
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
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadAvatarImage();
  }

  Future<void> _checkLoginStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _isLoggedIn = user != null;
    });
  }

  Future<void> _loadAvatarImage() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/avatar.png';
    final file = File(path);
    if (await file.exists()) {
      setState(() {
        _avatarImage = file;
      });
    }
  }

  Future<void> _pickAvatarImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/avatar.png';
      final imageFile = File(picked.path);

      // Сохраняем и перезаписываем аватарку
      await imageFile.copy(path);

      setState(() {
        _avatarImage = File(path);
      });
    }
  }

  Future<void> _deleteAvatarImage() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/avatar.png';
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
      setState(() {
        _avatarImage = null;
      });
    }
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Загрузить новый аватар"),
              onTap: () {
                Navigator.pop(context);
                _pickAvatarImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Удалить текущий аватар"),
              onTap: () {
                Navigator.pop(context);
                _deleteAvatarImage();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      setState(() {
        _isLoggedIn = false;
      });
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
                  SizedBox(width: 48 * scale),
                ],
              ),
            ),

            SizedBox(height: 32 * scale),

            // Аватарка с действиями
            GestureDetector(
              onTap: _isLoggedIn ? _showAvatarOptions : null,
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
            _buildProfileButton("Личные данные", const PersonalDataPage(), scale),
            SizedBox(height: 12 * scale),
            _buildProfileButton("Безопасность и вход", const SecurityPage(), scale),
            SizedBox(height: 12 * scale),
            _buildProfileButton("Уведомления", const NotificationsPage(), scale),
            SizedBox(height: 12 * scale),
            _buildProfileButton("Путь сохранения", const SaveRoutePage(), scale),
            SizedBox(height: 12 * scale),
            _buildProfileButton("Подключить PRO версию", const SubscriptionPage(), scale),
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
              onPressed: _isLoggedIn
                  ? _signOut
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF800000),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _isLoggedIn ? "Выйти из аккаунта" : "Войти в аккаунт",
                style: const TextStyle(
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

  Widget _buildProfileButton(String label, Widget page, double scale) {
    return Material(
      color: _isLoggedIn ? Colors.white : Colors.grey[300],
      borderRadius: BorderRadius.circular(10 * scale),
      child: InkWell(
        onTap: _isLoggedIn
            ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => page))
            : null,
        borderRadius: BorderRadius.circular(10 * scale),
        splashColor: const Color(0x22800000),
        highlightColor: Colors.transparent,
        child: Container(
          width: 318 * scale,
          height: 52,
          decoration: BoxDecoration(
            color: _isLoggedIn ? Colors.white : Colors.grey[300],
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
                  color: _isLoggedIn ? Colors.black : Colors.grey,
                ),
              ),
              SvgPicture.asset(
                'assets/arrow-right.svg',
                width: 20 * scale,
                height: 20 * scale,
                color: _isLoggedIn ? Colors.black : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
