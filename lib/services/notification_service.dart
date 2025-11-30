import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // ================================
  // 🔧 ИНИЦИАЛИЗАЦИЯ
  // ================================
  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@drawable/ic_stat_notification');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);

    // Создаём каналы сразу
    await _createChannels();
  }

  // Создание всех каналов уведомлений
  static Future<void> _createChannels() async {
    const AndroidNotificationChannel newsChannel = AndroidNotificationChannel(
      'news_channel', // id
      'Новости', // name
      description: 'Уведомления о новых юридических новостях',
      importance: Importance.high,
    );

    const AndroidNotificationChannel tipsChannel = AndroidNotificationChannel(
      'tips_channel',
      'Советы и лайфхаки',
      description: 'Юридические советы и полезные напоминания',
      importance: Importance.high,
    );

    const AndroidNotificationChannel updatesChannel = AndroidNotificationChannel(
      'updates_channel',
      'Обновления приложения',
      description: 'Оповещения о нововведениях и улучшениях',
      importance: Importance.high,
    );

    final android = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      await android.createNotificationChannel(newsChannel);
      await android.createNotificationChannel(tipsChannel);
      await android.createNotificationChannel(updatesChannel);
    }
  }

  // ================================
  // 📰 НОВОСТИ
  // ================================
  static Future<void> showNewsNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'news_channel',
      'Новости',
      channelDescription: 'Уведомления новых юридических новостей',
      icon: '@drawable/ic_stat_notification',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFF800000),
      colorized: true,
    );

    await _notificationsPlugin.show(
      1,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }

  // ================================
  // 💡 СОВЕТЫ
  // ================================
  static Future<void> showTipsNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'tips_channel',
      'Советы и лайфхаки',
      channelDescription: 'Полезные юридические рекомендации',
      icon: '@drawable/ic_stat_notification',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFF800000),
      colorized: true,
    );

    await _notificationsPlugin.show(
      2,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }

  // ================================
  // 🔧 ОБНОВЛЕНИЯ ПРИЛОЖЕНИЯ
  // ================================
  static Future<void> showAppUpdateNotification(
      String title, String body) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'updates_channel',
      'Обновления приложения',
      channelDescription: 'Оповещения о новых функциях и изменениях',
      icon: '@drawable/ic_stat_notification',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFF800000),
      colorized: true,
    );

    await _notificationsPlugin.show(
      3,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }

  // ================================
  // 📌 ЗАПРОС СИСТЕМНОГО РАЗРЕШЕНИЯ
  // ================================
  static Future<void> requestSystemPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }
}
