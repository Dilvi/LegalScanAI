import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

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
          icon: SvgPicture.asset('assets/back_button.svg', width: 24 * scale, height: 24 * scale),
        ),
        centerTitle: true,
        title: Text(
          'Подключить PRO',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 16 * scale,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 10 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Блок: Что входит в PRO
            Text(
              "✅ Что входит в PRO:",
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 15 * scale,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12 * scale),
            _buildBullet("Расширенный юридический анализ", scale),
            _buildBullet("Детализированные пояснения на основе законов", scale),
            _buildBullet("Приоритетная обработка документов", scale),
            _buildBullet("Юридические шаблоны и советы", scale),
            SizedBox(height: 30 * scale),

            // Блок: Подписка
            Text(
              "💳 Подписка:",
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 15 * scale,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12 * scale),
            _buildPriceOption("Месяц", "199 ₽", scale),
            SizedBox(height: 10 * scale),
            _buildPriceOption("Год", "1490 ₽", scale),
            SizedBox(height: 30 * scale),

            // Кнопка оформить подписку
            SizedBox(
              width: double.infinity,
              height: 52 * scale,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: оформить подписку
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF800000),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Оформить подписку',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20 * scale),

            // Восстановить покупку
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: восстановить покупку
                },
                child: Text(
                  "🧾 Уже есть подписка? Восстановить покупку",
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14 * scale,
                    color: const Color(0xFF800000),
                    decoration: TextDecoration.underline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBullet(String text, double scale) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "• ",
            style: TextStyle(
              fontSize: 18 * scale,
              height: 1.4,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14 * scale,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceOption(String period, String price, double scale) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          period,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14 * scale,
            fontWeight: FontWeight.normal,
          ),
        ),
        Text(
          price,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14 * scale,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
