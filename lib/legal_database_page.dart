import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LegalDatabasePage extends StatefulWidget {
  const LegalDatabasePage({super.key});

  @override
  State<LegalDatabasePage> createState() => _LegalDatabasePageState();
}

class _LegalDatabasePageState extends State<LegalDatabasePage> {
  final String baseUrl = "http://95.165.74.131:8081";

  List<dynamic> sections = [];
  bool isLoading = true;
  bool isRefreshing = false;
  bool? hasAccess;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  // ======================================================
  // CHECK SUBSCRIPTION ACCESS
  // ======================================================

  Future<void> _checkAccess() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      setState(() => hasAccess = false);
      return;
    }

    try {
      final res = await http.get(
        Uri.parse("http://95.165.74.131:8080/profile/get"),
        headers: {"Authorization": "Bearer $token"},  // ✔ fixed
      );

      if (res.statusCode != 200) {
        setState(() => hasAccess = false);
        return;
      }

      final data = jsonDecode(res.body);
      final subscription = data["subscription"];

      if (subscription == null) {
        setState(() => hasAccess = false);
        return;
      }

      // ✔ Correct field name
      final bool access = subscription["hasLegalBaseAccess"] == true;

      setState(() => hasAccess = access);

      if (access) {
        _loadCachedData();
        _fetchUpdates();
      }
    } catch (e) {
      setState(() => hasAccess = false);
    }
  }

  // ======================================================
  // CACHE
  // ======================================================

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

        final file = await _getCacheFile();
        await file.writeAsString(jsonEncode(data), flush: true);

        setState(() {
          sections = data;
          isLoading = false;
        });

        await _cacheHtmlFiles(data);

        if (showSnackbar && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Правовая база обновлена"),
              backgroundColor: Color(0xFF800000),
            ),
          );
        }
      }
    } catch (_) {}
  }

  // ======================================================
  // DOWNLOAD HTML + CSS
  // ======================================================

  Future<void> _cacheHtmlFiles(List<dynamic> nodes) async {
    final dir = await getApplicationDocumentsDirectory();

    try {
      final cssRes = await http.get(Uri.parse("$baseUrl/html/style.css"));
      if (cssRes.statusCode == 200) {
        final cssFile = File("${dir.path}/style.css");
        await cssFile.writeAsBytes(cssRes.bodyBytes, flush: true);
      }
    } catch (_) {}

    Future<void> downloadNode(dynamic node) async {
      if (node is! Map<String, dynamic>) return;

      if (node["html"] != null) {
        final remotePath = node["html"];
        final localRelative = remotePath.replaceFirst("/html/", "");

        final file = File("${dir.path}/$localRelative");

        try {
          await file.parent.create(recursive: true);
          final res = await http.get(Uri.parse("$baseUrl$remotePath"));
          if (res.statusCode == 200) {
            await file.writeAsBytes(res.bodyBytes, flush: true);
          }
        } catch (_) {}
      }

      if (node["children"] != null) {
        for (var c in node["children"]) {
          await downloadNode(c);
        }
      }
    }

    for (final n in nodes) {
      await downloadNode(n);
    }
  }

  // ======================================================
  // UI
  // ======================================================

  @override
  Widget build(BuildContext context) {
    // 🔥 1 — Проверяем доступ
    if (hasAccess == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF800000)),
      );
    }

    // 🔥 2 — Нет доступа
    if (hasAccess == false) {
      return _buildNoAccessPage();
    }

    // 🔥 3 — Загрузка базы
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
                    final node = sections[index];
                    final color = Color(
                      int.parse('0xFF${(node['color'] as String).substring(1)}'),
                    );
                    return _buildSectionCard(node, color);
                  },
                  childCount: sections.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================================================
  // NO ACCESS PAGE
  // ======================================================

  Widget _buildNoAccessPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.lock_outline, color: Color(0xFF800000), size: 80),
            SizedBox(height: 20),
            Text(
              "Нет доступа к правовой базе",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12),
            Text(
              "Оформите подписку для получения полного доступа.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 15,
                color: Color(0xFF737C97),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================================================
  // CARDS
  // ======================================================

  Widget _buildSectionCard(Map<String, dynamic> node, Color color) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LegalNodePage(node: node),
            ),
          );
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              node["title"],
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

// ======================================================
// UNIVERSAL NODE PAGE
// ======================================================

class LegalNodePage extends StatefulWidget {
  final Map<String, dynamic> node;

  const LegalNodePage({super.key, required this.node});

  @override
  State<LegalNodePage> createState() => _LegalNodePageState();
}

class _LegalNodePageState extends State<LegalNodePage> {
  String? selectedCity;

  @override
  void initState() {
    super.initState();

    if (widget.node["cities"] != null) {
      selectedCity = widget.node["cities"][0];
    }
  }

  @override
  Widget build(BuildContext context) {
    final node = widget.node;

    if (node["html"] != null) {
      return LegalHtmlPage(
        title: node["title"],
        htmlPath: node["html"],
      );
    }

    final children = node["children"] ?? [];
    final hasCities = node["cities"] != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(node["title"]),
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (hasCities)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: DropdownButton<String>(
                value: selectedCity,
                underline: const SizedBox(),
                items: (node["cities"] as List<dynamic>)
                    .map<DropdownMenuItem<String>>(
                      (c) => DropdownMenuItem<String>(
                    value: c,
                    child: Text(c),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedCity = value);
                },
              ),
            ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: children.length,
        itemBuilder: (context, index) {
          final child = children[index];

          if (child["city"] != null &&
              selectedCity != null &&
              child["city"] != selectedCity) {
            return const SizedBox.shrink();
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LegalNodePage(node: child),
                  ),
                );
              },
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Text(
                  child["title"] ?? "",
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ======================================================
// HTML PAGE
// ======================================================

class LegalHtmlPage extends StatelessWidget {
  final String title;
  final String htmlPath;

  const LegalHtmlPage({
    super.key,
    required this.title,
    required this.htmlPath,
  });

  Future<String> _loadHtml() async {
    final dir = await getApplicationDocumentsDirectory();

    final relative = htmlPath.replaceFirst("/html/", "");
    final fullPath = "${dir.path}/$relative";

    String html = await File(fullPath).readAsString();

    final cssPath = "${dir.path}/style.css";
    if (await File(cssPath).exists()) {
      String css = await File(cssPath).readAsString();
      html = html.replaceFirst("<head>", "<head><style>$css</style>");
    }

    return html;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _loadHtml(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF800000)),
            ),
          );
        }

        final controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadHtmlString(snapshot.data!);

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: WebViewWidget(controller: controller),
        );
      },
    );
  }
}
