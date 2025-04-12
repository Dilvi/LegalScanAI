import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart'; // ← обязательно в pubspec.yaml

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@drawable/ic_stat_notification');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  /// Показывает обычное уведомление
  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'default_channel', // ID канала
      'General Notifications', // Название канала
      channelDescription: 'Уведомления приложения LegalScanAI',
      icon: '@drawable/ic_stat_notification',
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFF800000),
      colorized: true,
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0, // ID уведомления
      title,
      body,
      notificationDetails,
    );
  }

  /// Запрашивает системное разрешение на уведомления (Android 13+)
  static Future<void> requestSystemPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }
}
