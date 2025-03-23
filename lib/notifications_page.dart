import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
              title: 'Уведомления о новых результатах анализа',
              value: resultNotifications,
              onChanged: (val) => setState(() => resultNotifications = val),
              scale: scale,
            ),
            const SizedBox(height: 12),
            _buildNotificationTile(
              emoji: '🤖',
              title: 'Советы от LegalMind',
              value: legalMindTips,
              onChanged: (val) => setState(() => legalMindTips = val),
              scale: scale,
            ),
            const SizedBox(height: 12),
            _buildNotificationTile(
              emoji: '📰',
              title: 'Новости и обновления приложения',
              value: appNews,
              onChanged: (val) => setState(() => appNews = val),
              scale: scale,
            ),
            const SizedBox(height: 12),
            _buildNotificationTile(
              emoji: '📩',
              title: 'Email-рассылка',
              value: emailUpdates,
              onChanged: (val) => setState(() => emailUpdates = val),
              scale: scale,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile({
    required String emoji,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required double scale,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF800000), width: 1),
        borderRadius: BorderRadius.circular(10 * scale),
        color: Colors.white,
      ),
      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  emoji,
                  style: TextStyle(fontSize: 20 * scale),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14 * scale,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF800000),
          ),
        ],
      ),
    );
  }
}
