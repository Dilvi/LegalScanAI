import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LegalNewsPage extends StatefulWidget {
  const LegalNewsPage({super.key});

  @override
  State<LegalNewsPage> createState() => _LegalNewsPageState();
}

class _LegalNewsPageState extends State<LegalNewsPage> {
  List<dynamic> categories = [];
  List<dynamic> newsList = [];
  List<dynamic> favoriteNews = [];

  int? selectedCategory;
  int? selectedFavCategory;

  bool isLoading = true;
  bool showFavorites = false;

  final String baseUrl = 'http://95.165.74.131:8082';
  late Directory imagesDir;

  @override
  void initState() {
    super.initState();
    _prepareFolders();
    _loadCachedData();
    _fetchCategories();
    _fetchNews(updateCache: true);
  }

  // ============================================================
  // 📁 Папка для изображений
  // ============================================================

  Future<void> _prepareFolders() async {
    final dir = await getApplicationDocumentsDirectory();
    imagesDir = Directory('${dir.path}/news_images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
  }

  Future<String?> downloadAndCacheImage(String url, int id) async {
    try {
      final file = File('${imagesDir.path}/$id.jpg');

      if (await file.exists()) return file.path;

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      }
    } catch (_) {}
    return null;
  }

  // ============================================================
  // 📦 Кэш
  // ============================================================

  Future<File> _getCacheFile(String name) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$name.json');
  }

  Future<void> _saveCache(String name, dynamic data) async {
    final file = await _getCacheFile(name);
    await file.writeAsString(jsonEncode(data));
  }

  Future<dynamic> _loadCache(String name) async {
    try {
      final file = await _getCacheFile(name);
      if (await file.exists()) {
        return jsonDecode(await file.readAsString());
      }
    } catch (_) {}
    return null;
  }

  bool toBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v == 1;
    if (v is String) return v.toLowerCase() == "true";
    return false;
  }

  Future<void> _loadCachedData() async {
    final cachedNews = await _loadCache('news');
    final cachedCats = await _loadCache('categories');
    final prefs = await SharedPreferences.getInstance();

    final favs = prefs.getStringList('favoriteNews') ?? [];

    if (cachedCats != null) categories = cachedCats;

    if (cachedNews != null) {
      for (var n in cachedNews) {
        n['isFavorite'] = toBool(n['isFavorite']);
      }

      favoriteNews =
          cachedNews.where((n) => n['isFavorite'] == true).toList();
      newsList =
          cachedNews.where((n) => n['isFavorite'] != true).toList();
    }

    setState(() => isLoading = false);
  }

  // ============================================================
  // Категории
  // ============================================================

  Future<void> _fetchCategories() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/categories'));
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        setState(() => categories = data);
        _saveCache('categories', data);
      }
    } catch (_) {}
  }

  // ============================================================
  // Новости
  // ============================================================

  Future<void> _fetchNews({int? categoryId, bool updateCache = false}) async {
    if (newsList.isEmpty) setState(() => isLoading = true);

    try {
      final url = categoryId == null
          ? '$baseUrl/news'
          : '$baseUrl/news?category=$categoryId';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) throw Exception();

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final prefs = await SharedPreferences.getInstance();
      final favs = prefs.getStringList('favoriteNews') ?? [];

      for (var n in data) {
        n['isFavorite'] = favs.contains("${n['id']}");

        if (n['imageUrl'] != null && n['imageUrl'] != "") {
          final path = await downloadAndCacheImage(n['imageUrl'], n['id']);
          n['cachedImagePath'] = path;
        }
      }

      setState(() {
        newsList = data.where((n) => !n['isFavorite']).toList();
        favoriteNews = data.where((n) => n['isFavorite']).toList();
      });

      if (updateCache) _saveCache('news', data);
    } catch (_) {
      // Но НЕ закрываем ленту — показываем SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Ошибка соединения"),
          backgroundColor: Colors.red,
        ));
      }
    }

    if (mounted) setState(() => isLoading = false);
  }

  // ============================================================
  // ⭐ Избранное
  // ============================================================

  Future<void> _toggleFavorite(Map<String, dynamic> news) async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favoriteNews') ?? [];

    final id = "${news['id']}";

    if (news['isFavorite']) {
      favs.remove(id);
    } else {
      favs.add(id);
    }

    await prefs.setStringList('favoriteNews', favs);

    news['isFavorite'] = !news['isFavorite'];

    _rebuildLists();
  }

  void _rebuildLists() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favoriteNews') ?? [];

    final all = [...newsList, ...favoriteNews];
    final unique = <Map<String, dynamic>>[];

    final seen = <String>{};
    for (var n in all) {
      final id = "${n['id']}";
      if (!seen.contains(id)) {
        seen.add(id);
        unique.add(n);
      }
    }

    for (var n in unique) {
      n['isFavorite'] = favs.contains("${n['id']}");
    }

    setState(() {
      newsList = unique.where((n) => !n['isFavorite']).toList();
      favoriteNews = unique.where((n) => n['isFavorite']).toList();
    });
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    List<dynamic> currentNews = showFavorites
        ? (selectedFavCategory == null
        ? favoriteNews
        : favoriteNews
        .where((n) => n['category_id'] == selectedFavCategory)
        .toList())
        : (selectedCategory == null
        ? newsList
        : newsList
        .where((n) => n['category_id'] == selectedCategory)
        .toList());

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await Future.any([
            _fetchNews(updateCache: true),
            Future.delayed(const Duration(seconds: 5)),
          ]);
        },
        color: const Color(0xFF800000),
        child: Column(
          children: [
            if (!showFavorites) _buildCategoryBar(),
            if (showFavorites) _buildFavoriteCategoryBar(),
            _buildFavoritesToggleButton(),
            Expanded(
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF800000),
                ),
              )
                  : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  14,
                  8,
                  14,
                  bottomInset + 16,
                ),
                itemCount: currentNews.length,
                itemBuilder: (context, index) {
                  return _buildNewsCard(currentNews[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Категории
  // ============================================================

  Widget _buildCategoryBar() {
    return SizedBox(
      height: 62,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selectedCategory == cat['id'];

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = isSelected ? null : cat['id'];
              });
            },
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF800000)
                    : const Color(0xFFF4E5E5),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: Text(
                  cat['title'],
                  style: TextStyle(
                    height: 1.05,
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'DM Sans',
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoriteCategoryBar() {
    return SizedBox(
      height: 62,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selectedFavCategory == cat['id'];

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedFavCategory =
                isSelected ? null : cat['id'];
              });
            },
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF800000)
                    : const Color(0xFFF4E5E5),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: Text(
                  cat['title'],
                  style: TextStyle(
                    height: 1.05,
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'DM Sans',
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // Кнопка "Сохранённые"
  // ============================================================

  Widget _buildFavoritesToggleButton() {
    final hasFavorites = favoriteNews.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 46,
        width: double.infinity,
        decoration: BoxDecoration(
          color: showFavorites
              ? const Color(0xFF800000)
              : (hasFavorites ? const Color(0xFFF4E5E5) : Colors.grey[300]),
          borderRadius: BorderRadius.circular(14),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            if (!hasFavorites) {
              setState(() {
                showFavorites = false;
                selectedFavCategory = null;
              });
              return;
            }

            setState(() {
              showFavorites = !showFavorites;
              selectedFavCategory = null;
            });
          },
          child: Center(
            child: Text(
              !hasFavorites
                  ? "Вернуться к новостям"
                  : (showFavorites
                  ? "Показать все новости"
                  : "Сохранённые новости"),
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: showFavorites
                    ? Colors.white
                    : (hasFavorites ? Colors.black : Colors.black45),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Новости
  // ============================================================

  Widget _buildNewsCard(Map<String, dynamic> item) {
    final cachedImage = item['cachedImagePath'];
    final isFavorite = item['isFavorite'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: cachedImage != null
                  ? Image.file(
                File(cachedImage),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              )
                  : Container(
                height: 180,
                width: double.infinity,
                color: const Color(0xFFE0E0E0),
                child: const Icon(
                  Icons.image_not_supported,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item['title'] ?? '',
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item['description'] ?? '',
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 15,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => _toggleFavorite(item),
                  icon: Icon(
                    isFavorite ? Icons.bookmark : Icons.bookmark_outline,
                    color: isFavorite
                        ? const Color(0xFF800000)
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
