import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LegalDatabasePage extends StatefulWidget {
  const LegalDatabasePage({super.key});

  @override
  State<LegalDatabasePage> createState() => _LegalDatabasePageState();
}

class _LegalDatabasePageState extends State<LegalDatabasePage> {
  List<Map<String, dynamic>> sections = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchSections();
  }

  Future<void> _fetchSections() async {
    try {
      final response = await http.get(
        Uri.parse("http://95.165.74.131:8081/legal-sections"),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes)); // ✅ UTF-8 fix
        setState(() {
          sections = data.cast<Map<String, dynamic>>();
          isLoading = false;
          hasError = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      print("❌ Ошибка при загрузке разделов: $e");
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF800000)),
      );
    }

    if (hasError) {
      // ❗ Ошибка — теперь свайп вниз для обновления вместо кнопки
      return RefreshIndicator(
        color: const Color(0xFF800000),
        onRefresh: _fetchSections,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 200),
            Center(
              child: Text(
                "Не удалось загрузить разделы.\nПотяните вниз, чтобы обновить",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF800000),
      onRefresh: _fetchSections,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: GridView.builder(
          itemCount: sections.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 📌 2 плитки в ширину
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final section = sections[index];
            return _buildTile(section);
          },
        ),
      ),
    );
  }

  Widget _buildTile(Map<String, dynamic> section) {
    return Material(
      color: const Color(0xFFF4E5E5), // 🌸 Светлый бордовый фон
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: const Color(0xFF800000).withOpacity(0.1),
        highlightColor: const Color(0xFF800000).withOpacity(0.05),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LegalSectionDetailPage(
                title: section['title'] ?? 'Раздел',
                id: section['id'],
              ),
            ),
          );
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              section['title'] ?? 'Без названия',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LegalSectionDetailPage extends StatelessWidget {
  final String title;
  final dynamic id;

  const LegalSectionDetailPage({super.key, required this.title, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          "📜 Контент раздела ID: $id\n(сюда подгружается с бэкенда)",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
