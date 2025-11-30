import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import 'subscription_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool newsNotifications = true;       // Новости
  bool tipsNotifications = false;      // Лайфхаки — только с подпиской
  bool appUpdatesNotifications = true; // Обновления приложения

  @override
  void initState() {
    super.initState();
    NotificationService.init();
    _loadPreferences();
    _checkAndRequestPermission();
  }

  // ================================
  // 🔐 Проверка системного разрешения
  // ================================
  Future<void> _checkAndRequestPermission() async {
    final prefs = await SharedPreferences.getInstance();
    final requested = prefs.getBool('notification_permission_requested') ?? false;

    if (!requested) {
      await NotificationService.requestSystemPermission();
      await prefs.setBool('notification_permission_requested', true);
    }
  }

  // ================================
  // 🔄 Загрузка сохранённых настроек
  // ================================
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      newsNotifications = prefs.getBool('newsNotifications') ?? true;
      tipsNotifications = prefs.getBool('tipsNotifications') ?? false;
      appUpdatesNotifications = prefs.getBool('appUpdatesNotifications') ?? true;
    });
  }

  Future<void> _savePref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // ================================
  // 🔍 Проверка активной подписки
  // ================================
  Future<bool> _hasSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) return false;

    final res = await http.get(
      Uri.parse("http://95.165.74.131:8080/profile/get"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode != 200) return false;

    final data = jsonDecode(utf8.decode(res.bodyBytes));
    return data["subscription"] != null;
  }

  // ================================
  // 🔧 Обработка переключателя
  // ================================
  Future<void> _onToggle(String key, bool value) async {

    // особая логика — советы и лайфхаки (только подписка)
    if (key == 'tipsNotifications' && value == true) {
      bool hasSub = await _hasSubscription();
      if (!hasSub) {
        // возвращаем переключатель обратно
        setState(() => tipsNotifications = false);

        // открываем страницу подписки
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubscriptionPage()),
          );
        }

        return;
      }
    }

    setState(() {
      switch (key) {
        case 'newsNotifications':
          newsNotifications = value;
          break;
        case 'tipsNotifications':
          tipsNotifications = value;
          break;
        case 'appUpdatesNotifications':
          appUpdatesNotifications = value;
          break;
      }
    });

    _savePref(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 360;

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
          'Уведомления',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 16 * scale,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 12 * scale),
        child: Column(
          children: [
            // ===============================
            // 📰 Новости
            // ===============================
            _buildTile(
              emoji: "📰",
              title: "Новости",
              subtitle: "При добавлении новой новости в приложении",
              value: newsNotifications,
              keyPref: "newsNotifications",
              scale: scale,
            ),

            const SizedBox(height: 12),

            // ===============================
            // 💡 Лайфхаки (подписка)
            // ===============================
            _buildTile(
              emoji: "💡",
              title: "Советы и лайфхаки",
              subtitle: "Подборки полезных юридических советов из правовой базы",
              value: tipsNotifications,
              keyPref: "tipsNotifications",
              scale: scale,
            ),

            const SizedBox(height: 12),

            // ===============================
            // 🔧 Обновления приложения
            // ===============================
            _buildTile(
              emoji: "🔔",
              title: "Обновления приложения",
              subtitle: "Новые функции, улучшения и важные изменения",
              value: appUpdatesNotifications,
              keyPref: "appUpdatesNotifications",
              scale: scale,
            ),
          ],
        ),
      ),
    );
  }

  // ================================
  // 🔲 UI компоненты
  // ================================
  Widget _buildTile({
    required String emoji,
    required String title,
    required String subtitle,
    required bool value,
    required String keyPref,
    required double scale,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF800000), width: 1),
        borderRadius: BorderRadius.circular(10 * scale),
        color: Colors.white,
      ),
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 24 * scale)),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12 * scale,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: value,
            onChanged: (v) => _onToggle(keyPref, v),
            activeColor: const Color(0xFF800000),
          ),
        ],
      ),
    );
  }
}
