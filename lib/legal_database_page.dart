import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class LegalDatabasePage extends StatefulWidget {
  const LegalDatabasePage({super.key});

  @override
  State<LegalDatabasePage> createState() => _LegalDatabasePageState();
}

class _LegalDatabasePageState extends State<LegalDatabasePage> {
  final String baseUrl = "http://95.165.74.131:8081"; // твой статический IP
  List<dynamic> sections = [];
  bool isLoading = true;
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _fetchUpdates(); // проверка обновлений при открытии
  }

  Future<File> _getCacheFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/legal_base.json');
  }

  Future<void> _loadCachedData() async {
    try {
      final file = await _getCacheFile();
      if (await file.exists()) {
        final cached = jsonDecode(await file.readAsString());
        setState(() {
          sections = cached;
          isLoading = false;
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchUpdates({bool showSnackbar = false}) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/legal-base'));
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        setState(() {
          sections = data;
          isLoading = false;
        });
        final file = await _getCacheFile();
        await file.writeAsString(jsonEncode(data), flush: true);
        await _cacheImages(data);

        if (showSnackbar && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ База обновлена"),
              backgroundColor: Color(0xFF800000),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (_) {
      if (showSnackbar && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠️ Не удалось обновить базу"),
            backgroundColor: Colors.grey,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _cacheImages(List<dynamic> data) async {
    final dir = await getApplicationDocumentsDirectory();
    for (final section in data) {
      for (final sub in section['subsections']) {
        final url = '$baseUrl${sub['image']}';
        final fileName = sub['image'].split('/').last;
        final file = File('${dir.path}/$fileName');

        // если файла нет — скачиваем
        if (!await file.exists()) {
          try {
            final response = await http.get(Uri.parse(url));
            if (response.statusCode == 200) {
              await file.writeAsBytes(response.bodyBytes);
            }
          } catch (_) {}
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF800000)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        color: const Color(0xFF800000),
        onRefresh: () async {
          setState(() => isRefreshing = true);
          await _fetchUpdates(showSnackbar: true);
          setState(() => isRefreshing = false);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final section = sections[index];
                    final color = Color(int.parse(
                        '0xFF${(section['color'] as String).substring(1)}'));
                    return _buildSectionCard(context, section, color);
                  },
                  childCount: sections.length,
                ),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1,
                ),
              ),
            ),
            if (isRefreshing)
              const SliverToBoxAdapter(
                child: SizedBox(height: 60),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
      BuildContext context, Map<String, dynamic> section, Color color) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        splashColor: const Color(0xFF800000).withOpacity(0.1),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LegalSubsectionsPage(
                title: section["title"],
                subsections: section["subsections"],
              ),
            ),
          );
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              section["title"],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LegalSubsectionsPage extends StatelessWidget {
  final String title;
  final List<dynamic> subsections;

  const LegalSubsectionsPage({
    super.key,
    required this.title,
    required this.subsections,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        itemCount: subsections.length,
        itemBuilder: (context, index) {
          final item = subsections[index];
          return _buildSubCard(context, item);
        },
      ),
    );
  }

  Widget _buildSubCard(BuildContext context, Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LegalImagePage(
                title: item["title"],
                imageName: item["image"].split('/').last,
              ),
            ),
          );
        },
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Text(
            item["title"],
            style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 15,
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

class LegalImagePage extends StatelessWidget {
  final String title;
  final String imageName;

  const LegalImagePage({
    super.key,
    required this.title,
    required this.imageName,
  });

  Future<File?> _getImageFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$imageName');
    if (await file.exists()) return file;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<File?>(
        future: _getImageFile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child:
              CircularProgressIndicator(color: Color(0xFF800000)),
            );
          }
          final file = snapshot.data;
          if (file == null) {
            return const Center(child: Text("Изображение не найдено"));
          }
          return InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: SingleChildScrollView(
              child: Image.file(file, fit: BoxFit.contain),
            ),
          );
        },
      ),
    );
  }
}
