import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';


class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@drawable/ic_stat_notification'); // ← твоя иконка

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'default_channel',
      'General Notifications',
      icon: '@drawable/ic_stat_notification', // твоё белое лого
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFF800000), // ← бордовый
      colorized: true, // обязательно!
    );


    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }
}
