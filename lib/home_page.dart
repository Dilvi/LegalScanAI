import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'check_text_page.dart';
import 'profile_page.dart'; // Страница профиля
import 'chat_page.dart';
import 'scan_document_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Верхняя часть с аватаркой и текстом
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Аватарка в левом верхнем углу
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfilePage(),
                      ),
                    );
                  },
                  child: const CircleAvatar(
                    radius: 22.5,
                    backgroundColor: Color(0xFF800000),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Добро пожаловать",
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Последние проверки/результат анализа",
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    color: Color(0xFF737C97),
                  ),
                ),
              ],
            ),
          ),

          // Нижняя панель с кнопками
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomPanel(context),
          ),
        ],
      ),
    );
  }

  // Нижняя панель
  Widget _buildBottomPanel(BuildContext context) {
    return Material(
      color: const Color(0xFF800000),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(25),
        topRight: Radius.circular(25),
      ),
      child: Container(
        width: double.infinity,
        height: 219,
        padding: const EdgeInsets.symmetric(horizontal: 21),
        child: Column(
          children: [
            const SizedBox(height: 26),
            // Кнопка LegalMind
            SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (context) => const ChatPage(),
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
                child: const Text(
                  "LegalMind – AI помощник по праву",
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 26),
            // Нижние кнопки
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIconButton(
                  label: "Проверить\nтекст",
                  iconPath: "assets/check_text_icon.svg",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CheckTextPage(),
                      ),
                    );
                  },
                ),
                _buildIconButton(
                  label: "Сканировать\nдокумент",
                  iconPath: "assets/scan_doc_icon.svg",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ScanDocumentPage(),
                      ),
                    );
                  },
                ),
                _buildIconButton(
                  label: "Загрузить\nфайл",
                  iconPath: "assets/upload_file_icon.svg",
                  onTap: () {
                    // TODO
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Кнопка с иконкой и подписью
  Widget _buildIconButton({
    required String label,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          elevation: 1,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            splashColor: Colors.grey.withOpacity(0.3),
            child: SizedBox(
              width: 52,
              height: 52,
              child: Center(
                child: SvgPicture.asset(
                  iconPath,
                  width: 24,
                  height: 24,
                  color: const Color(0xFF800000),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
