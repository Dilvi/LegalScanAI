import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool resultNotifications = true;
  bool legalMindTips = false;
  bool appNews = true;
  bool emailUpdates = false;

  @override
  void initState() {
    super.initState();
    NotificationService.init();
    _loadPreferences();
    _checkAndRequestPermission(); // 👈 системный запрос
  }

  Future<void> _checkAndRequestPermission() async {
    final prefs = await SharedPreferences.getInstance();
    final requested = prefs.getBool('notification_permission_requested') ?? false;

    if (!requested) {
      await NotificationService.requestSystemPermission();
      await prefs.setBool('notification_permission_requested', true);
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      resultNotifications = prefs.getBool('resultNotifications') ?? true;
      legalMindTips = prefs.getBool('legalMindTips') ?? false;
      appNews = prefs.getBool('appNews') ?? true;
      emailUpdates = prefs.getBool('emailUpdates') ?? false;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _onNotificationChange(String key, bool value) {
    setState(() {
      switch (key) {
        case 'resultNotifications':
          resultNotifications = value;
          break;
        case 'legalMindTips':
          legalMindTips = value;
          break;
        case 'appNews':
          appNews = value;
          break;
        case 'emailUpdates':
          emailUpdates = value;
          break;
      }
      _savePreference(key, value);
      if (value) {
        NotificationService.showNotification(
          'Уведомления включены',
          'Теперь вы будете получать уведомления: $key',
        );
      }
    });
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
            _buildNotificationTile(
              emoji: '📝',
              title: 'Новые результаты анализа',
              subtitle: 'Оповещение, когда готов результат анализа документа',
              value: resultNotifications,
              keyPref: 'resultNotifications',
              scale: scale,
            ),
            const SizedBox(height: 12),
            _buildNotificationTile(
              emoji: '🤖',
              title: 'Советы от LegalMind',
              subtitle: 'Юридические подсказки и разборы интересных случаев',
              value: legalMindTips,
              keyPref: 'legalMindTips',
              scale: scale,
            ),
            const SizedBox(height: 12),
            _buildNotificationTile(
              emoji: '📰',
              title: 'Новости и обновления',
              subtitle: 'Выход новых функций и улучшений в приложении',
              value: appNews,
              keyPref: 'appNews',
              scale: scale,
            ),
            const SizedBox(height: 12),
            _buildNotificationTile(
              emoji: '📩',
              title: 'Email-рассылка',
              subtitle: 'Получать полезные письма с юридическими лайфхаками',
              value: emailUpdates,
              keyPref: 'emailUpdates',
              scale: scale,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => NotificationService.showNotification(
                'Тестовое уведомление',
                'Это пример работы уведомлений',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF800000),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.notifications, color: Colors.white),
              label: const Text(
                "Показать тестовое уведомление",
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile({
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
          Text(
            emoji,
            style: TextStyle(fontSize: 24 * scale),
          ),
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
            onChanged: (val) => _onNotificationChange(keyPref, val),
            activeColor: const Color(0xFF800000),
          ),
        ],
      ),
    );
  }
}
