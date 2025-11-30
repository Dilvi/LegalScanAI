import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  File? _avatarImage;
  int _avatarVersion = 0; // ✅ для форс-перерисовки аватарки

  bool _isLoggedIn = false;
  String _email = '';

  bool _hasActiveSubscription = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadAvatarImage();
  }

  // ================================
  // 🔐 Проверка авторизации + подписки
  // ================================

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final email = prefs.getString('email');

    final loggedIn = token != null && token.isNotEmpty;

    setState(() {
      _isLoggedIn = loggedIn;
      _email = email ?? '';
    });

    if (loggedIn) {
      await _loadSubscriptionStatus();
    }
  }

  Future<void> _loadSubscriptionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");
    if (token == null) return;

    try {
      final res = await http.get(
        Uri.parse("http://95.165.74.131:8080/profile/get"),
        headers: {"Authorization": token},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        setState(() {
          _hasActiveSubscription = data["subscription"] != null;
        });
      }
    } catch (_) {
      // сеть упала — просто не трогаем _hasActiveSubscription
    }
  }

  // ================================
  // 📸 Аватар — работа с файлом и кешем
  // ================================

  Future<File> _getAvatarFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/avatar.png');
  }

  Future<void> _evictAvatarFromCache(File file) async {
    // Точечно выкидываем этот FileImage из кеша
    try {
      final provider = FileImage(file);
      await provider.evict();
    } catch (_) {}

    // На всякий случай — чистим глобальный кеш изображений
    try {
      imageCache.clear();
      imageCache.clearLiveImages();
    } catch (_) {}
  }

  Future<void> _loadAvatarImage() async {
    final file = await _getAvatarFile();
    if (await file.exists()) {
      setState(() {
        _avatarImage = file;
        _avatarVersion++; // на случай, если вернулись на страницу и хотим перерисовать
      });
    } else {
      setState(() {
        _avatarImage = null;
      });
    }
  }

  Future<void> _pickAvatarImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final avatarFile = await _getAvatarFile();

    // Если был старый файл — удаляем и выкидываем из кеша
    if (await avatarFile.exists()) {
      await _evictAvatarFromCache(avatarFile);
      try {
        await avatarFile.delete();
      } catch (_) {}
    }

    // Копируем новый файл в avatar.png
    final newFile = await File(picked.path).copy(avatarFile.path);

    // Выкидываем новый из кеша (чтобы точно взять свежие байты)
    await _evictAvatarFromCache(newFile);

    if (!mounted) return;
    setState(() {
      _avatarImage = newFile;
      _avatarVersion++;
    });
  }

  Future<void> _deleteAvatarImage() async {
    final avatarFile = await _getAvatarFile();

    if (await avatarFile.exists()) {
      // сначала выкидываем из кеша
      await _evictAvatarFromCache(avatarFile);
      try {
        await avatarFile.delete();
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      _avatarImage = null;
      _avatarVersion++;
    });
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
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

  // ================================
  // 🚪 Выход
  // ================================

  Future<void> _signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('email');

    // Аватарка декоративная — можем оставить файл или удалить.
    // Я сброшу только состояние, чтобы новый пользователь не увидел старую.
    setState(() {
      _isLoggedIn = false;
      _email = '';
      _hasActiveSubscription = false;
      _avatarImage = null;
      _avatarVersion++;
    });

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
    );
  }

  // ================================
  // 📄 UI
  // ================================

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 360;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 🔝 Заголовок
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20 * scale,
                vertical: 12 * scale,
              ),
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

            // 👤 Аватар
            GestureDetector(
              onTap: _isLoggedIn ? _showAvatarOptions : null,
              child: Hero(
                tag: 'profileAvatar',
                child: CircleAvatar(
                  key: ValueKey(_avatarVersion), // ✅ форс-перерисовка
                  radius: 40 * scale,
                  backgroundColor: const Color(0xFF800000),
                  backgroundImage:
                  _avatarImage != null ? FileImage(_avatarImage!) : null,
                  child: _avatarImage == null
                      ? Icon(
                    Icons.person,
                    size: 40 * scale,
                    color: Colors.white,
                  )
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

            // 📋 Разделы
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildProfileButton(
                      "Личные данные",
                      const PersonalDataPage(),
                      scale,
                    ),
                    const SizedBox(height: 12),
                    _buildProfileButton(
                      "Безопасность и вход",
                      const SecurityPage(),
                      scale,
                    ),
                    const SizedBox(height: 12),
                    _buildProfileButton(
                      "Уведомления",
                      const NotificationsPage(),
                      scale,
                    ),
                    const SizedBox(height: 12),
                    _buildProfileButton(
                      _hasActiveSubscription
                          ? "Моя подписка"
                          : "Подключить PRO версию",
                      const SubscriptionPage(),
                      scale,
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 🔻 Низ — вход / выход
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
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
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

  // ================================
  // 🔘 Кнопка раздела
  // ================================

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
              ? () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          }
              : null,
          borderRadius: BorderRadius.circular(10 * scale),
          splashColor: const Color(0x22800000),
          highlightColor: Colors.transparent,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10 * scale),
              border: Border.all(
                color: const Color(0xFF800000),
                width: 1,
              ),
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
