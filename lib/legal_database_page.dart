import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LegalDatabasePage extends StatefulWidget {
  const LegalDatabasePage({super.key});

  @override
  State<LegalDatabasePage> createState() => _LegalDatabasePageState();
}

class _LegalDatabasePageState extends State<LegalDatabasePage> {
  List<Map<String, dynamic>> sections = [];
  bool isLoading = true;
  bool hasError = false;
  File? _avatarImage;

  @override
  void initState() {
    super.initState();
    _fetchSections();
    _loadAvatarImage();
  }

  Future<void> _loadAvatarImage() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/avatar.png';
    final avatarFile = File(path);
    if (await avatarFile.exists()) {
      setState(() {
        _avatarImage = avatarFile;
      });
    }
  }

  Future<void> _fetchSections() async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.1.82:8081/legal-sections"), // ✅ локальный IP
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
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
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      // 👉 Можно добавить переход в профиль (если нужно)
                    },
                    child: CircleAvatar(
                      radius: 22.5,
                      backgroundColor: const Color(0xFF800000),
                      backgroundImage:
                      _avatarImage != null ? FileImage(_avatarImage!) : null,
                      child: _avatarImage == null
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Правовая база",
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "Ответы на популярные юридические вопросы",
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 15,
                      color: Color(0xFF737C97),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final section = sections[index];
                  return _buildTile(section);
                },
                childCount: sections.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(Map<String, dynamic> section) {
    return Material(
      color: const Color(0xFFF4E5E5),
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
