import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'login_page.dart';
import 'security_page.dart';
import 'personal_data_page.dart';
import 'notifications_page.dart';
import 'subscription_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  File? _avatarImage;
  bool _isLoggedIn = false;
  String _email = '';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadAvatarImage();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final email = prefs.getString('email');
    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
      _email = email ?? '';
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
      isScrollControlled: true, // ✅ чтобы учитывать всю высоту экрана
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea( // ✅ оборачиваем в SafeArea
        child: Padding(
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
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('email');

    setState(() {
      _isLoggedIn = false;
      _email = '';
    });

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 360;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false, // чтобы нижняя панель не сжималась
        child: Column(
          children: [
            // 📍 Верхняя панель
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
                  const SizedBox(width: 48),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 📸 Аватар
            GestureDetector(
              onTap: _isLoggedIn ? _showAvatarOptions : null,
              child: Hero(
                tag: 'profileAvatar',
                child: CircleAvatar(
                  radius: 40 * scale,
                  backgroundColor: const Color(0xFF800000),
                  backgroundImage: _avatarImage != null ? FileImage(_avatarImage!) : null,
                  child: _avatarImage == null
                      ? Icon(Icons.person, size: 40 * scale, color: Colors.white)
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 12),

            if (_isLoggedIn)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _email,
                  key: ValueKey(_email),
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // 📜 Список кнопок
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildProfileButton("Личные данные", const PersonalDataPage(), scale),
                    const SizedBox(height: 12),
                    _buildProfileButton("Безопасность и вход", const SecurityPage(), scale),
                    const SizedBox(height: 12),
                    _buildProfileButton("Уведомления", const NotificationsPage(), scale),
                    const SizedBox(height: 12),
                    _buildProfileButton("Подключить PRO версию", const SubscriptionPage(), scale),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 🧭 Нижняя панель
      bottomNavigationBar: SafeArea(
        top: false,
        child: Material(
          color: const Color(0xFF800000),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: Container(
            width: double.infinity,
            height: 134,
            padding: const EdgeInsets.all(20),
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
        ),
      ),
    );
  }

  Widget _buildProfileButton(String label, Widget page, double scale) {
    final enabled = _isLoggedIn;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1.0 : 0.6,
      child: Material(
        color: enabled ? Colors.white : Colors.grey[300],
        borderRadius: BorderRadius.circular(10 * scale),
        child: InkWell(
          onTap: enabled
              ? () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          )
              : null,
          borderRadius: BorderRadius.circular(10 * scale),
          splashColor: const Color(0x22800000),
          highlightColor: Colors.transparent,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
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
                    color: enabled ? Colors.black : Colors.grey,
                  ),
                ),
                SvgPicture.asset(
                  'assets/arrow-right.svg',
                  width: 20 * scale,
                  height: 20 * scale,
                  color: enabled ? Colors.black : Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
