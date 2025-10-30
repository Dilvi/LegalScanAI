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
  bool isLoading = true;
  bool hasError = false;
  bool showFavorites = false;
  String? userEmail;

  final String baseUrl = 'http://192.168.1.82:8082';

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadCachedData();
    _fetchCategories();
    _fetchNews(updateCache: true);
  }

  // ================================
  // 📦 КЭШ
  // ================================

  Future<File> _getCacheFile(String name) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$name.json');
  }

  Future<void> _saveCache(String name, dynamic data) async {
    final file = await _getCacheFile(name);
    await file.writeAsString(jsonEncode(data), flush: true);
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

  Future<void> _loadCachedData() async {
    final cachedNews = await _loadCache('news');
    final cachedCats = await _loadCache('categories');
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favoriteNews') ?? [];

    if (cachedCats != null) categories = cachedCats;
    if (cachedNews != null) {
      newsList = cachedNews;
      favoriteNews =
          cachedNews.where((n) => favs.contains("${n['id']}")).toList();
      for (final f in favoriteNews) {
        f['isFavorite'] = true;
      }
      // удаляем избранные из основной ленты
      newsList.removeWhere((n) => favs.contains("${n['id']}"));
    }

    setState(() => isLoading = false);
  }

  // ================================
  // 👤 ПОЛЬЗОВАТЕЛЬ
  // ================================

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('email');
  }

  // ================================
  // 📂 КАТЕГОРИИ
  // ================================

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

  // ================================
  // 📰 НОВОСТИ
  // ================================

  Future<void> _fetchNews({int? categoryId, bool updateCache = false}) async {
    if (newsList.isEmpty) setState(() => isLoading = true);
    try {
      final url =
      categoryId == null ? '$baseUrl/news' : '$baseUrl/news?category=$categoryId';
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        setState(() {
          newsList = data;
          _restoreFavorites();
        });
        if (updateCache) _saveCache('news', data);
      }
    } catch (_) {
      hasError = true;
    }
    setState(() => isLoading = false);
  }

  void _restoreFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favoriteNews') ?? [];
    for (var n in newsList) {
      n['isFavorite'] = favs.contains("${n['id']}");
    }
    favoriteNews = newsList.where((n) => n['isFavorite'] == true).toList();
    newsList.removeWhere((n) => favs.contains("${n['id']}"));
  }

  // ================================
  // ❤️ ЛАЙК
  // ================================

  Future<void> _toggleLike(Map<String, dynamic> news) async {
    if (userEmail == null) return _showLoginRequired();
    final liked = (news['likedBy'] ?? []).contains(userEmail);
    setState(() {
      if (liked) {
        news['likedBy'].remove(userEmail);
        news['likes']--;
      } else {
        news['likedBy'].add(userEmail);
        news['likes']++;
      }
    });
    try {
      await http.post(Uri.parse('$baseUrl/like/${news['id']}/$userEmail'));
    } catch (_) {}
    _saveCache('news', newsList);
  }

  // ================================
  // ⭐ ИЗБРАННОЕ
  // ================================

  Future<void> _toggleFavorite(Map<String, dynamic> news) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favs = prefs.getStringList('favoriteNews') ?? [];
      final id = "${news['id']}";
      final bool currentlyFavorite = (news['isFavorite'] ?? false) == true;

      setState(() {
        news['isFavorite'] = !currentlyFavorite;

        if (!currentlyFavorite) {
          if (!favs.contains(id)) favs.add(id);
        } else {
          favs.remove(id);
        }

        // Убираем из списка
        if (!showFavorites && news['isFavorite'] == true) {
          newsList.removeWhere((n) => n['id'] == news['id']);
        } else if (showFavorites && news['isFavorite'] == false) {
          favoriteNews.removeWhere((n) => n['id'] == news['id']);
        }

        favoriteNews =
        [...favoriteNews, ...newsList.where((n) => n['isFavorite'] == true)];
      });

      await prefs.setStringList('favoriteNews', favs);
      await _saveCache('news', newsList);
    } catch (e) {
      print('❌ Ошибка избранного: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ошибка при добавлении в избранное"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ================================
  // ⚠️ ПРЕДУПРЕЖДЕНИЕ
  // ================================

  void _showLoginRequired() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
        Text("Войдите в аккаунт, чтобы ставить лайки и комментировать"),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ================================
  // 🧱 UI
  // ================================

  @override
  Widget build(BuildContext context) {
    final currentNews = showFavorites ? favoriteNews : newsList;

    return RefreshIndicator(
      onRefresh: () => _fetchNews(updateCache: true),
      color: const Color(0xFF800000),
      child: Column(
        children: [
          if (!showFavorites) ...[
            _buildCategoryBar(),
            _buildFavoritesToggleButton(),
          ] else
            _buildFavoritesToggleButton(),
          Expanded(
            child: isLoading
                ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF800000)))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              itemCount: currentNews.length,
              itemBuilder: (context, index) {
                final item = currentNews[index];
                return _buildNewsCard(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================================
  // 📌 КАТЕГОРИИ
  // ================================

  Widget _buildCategoryBar() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final bool isSelected = selectedCategory == cat['id'];
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = isSelected ? null : cat['id'];
              });
              _fetchNews(categoryId: isSelected ? null : cat['id'], updateCache: true);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              constraints: const BoxConstraints(minWidth: 90, maxWidth: 150),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF800000)
                    : const Color(0xFFF4E5E5),
                borderRadius: BorderRadius.circular(22),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  cat['title'],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ================================
  // 🔘 КНОПКА СОХРАНЁННЫЕ
  // ================================

  Widget _buildFavoritesToggleButton() {
    final hasFavorites = favoriteNews.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        width: double.infinity,
        decoration: BoxDecoration(
          color: showFavorites
              ? const Color(0xFF800000)
              : (hasFavorites ? const Color(0xFFF4E5E5) : Colors.grey[300]),
          borderRadius: BorderRadius.circular(14),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: hasFavorites
              ? () => setState(() => showFavorites = !showFavorites)
              : null,
          child: Center(
            child: Text(
              hasFavorites
                  ? (showFavorites
                  ? "Показать все новости"
                  : "Сохранённые новости")
                  : "Нет сохранённых новостей",
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

  // ================================
  // 📰 КАРТОЧКА НОВОСТИ
  // ================================

  Widget _buildNewsCard(Map<String, dynamic> item) {
    final liked = (item['likedBy'] ?? []).contains(userEmail);
    final isFavorite = (item['isFavorite'] ?? false) == true;
    final likes = item['likes'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['imageUrl'] != null && item['imageUrl'].isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item['imageUrl'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: const Color(0xFFE0E0E0),
                    child: const Icon(Icons.image_not_supported_outlined),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _toggleLike(item),
                      icon: Icon(
                        liked ? Icons.favorite : Icons.favorite_border,
                        color: liked ? Colors.red : Colors.grey.shade600,
                      ),
                    ),
                    Text('$likes'),
                  ],
                ),
                Row(
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
                    IconButton(
                      icon: const Icon(Icons.comment_outlined,
                          color: Colors.grey),
                      onPressed: () => _showCommentsModal(item),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================================
  // 💬 КОММЕНТАРИИ
  // ================================

  void _showCommentsModal(Map<String, dynamic> news) {
    final controller = TextEditingController();
    final comments = (news['comments'] as List?) ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 8,
              top: 12,
              left: 20,
              right: 20,
            ),
            child: StatefulBuilder(
              builder: (context, setModalState) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 4,
                    width: 40,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    "Комментарии",
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (comments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text("Комментариев пока нет",
                          style: TextStyle(color: Colors.grey)),
                    )
                  else
                    SizedBox(
                      height: 260,
                      child: ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (_, i) {
                          final c = comments[i];
                          final bool isMyComment = c['user'] == userEmail;
                          return ListTile(
                            dense: true,
                            title: Text(
                              c['user'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(c['text'] ?? ''),
                            trailing: isMyComment
                                ? IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red, size: 20),
                              onPressed: () {
                                setModalState(() {
                                  comments.removeAt(i);
                                });
                                http.post(
                                  Uri.parse(
                                      '$baseUrl/comment/delete/${news['id']}'),
                                  body: {
                                    'user': userEmail!,
                                    'index': '$i'
                                  },
                                );
                              },
                            )
                                : null,
                          );
                        },
                      ),
                    ),
                  const Divider(),
                  if (userEmail != null)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              hintText: "Добавить комментарий...",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send,
                              color: Color(0xFF800000)),
                          onPressed: () async {
                            final text = controller.text.trim();
                            if (text.isEmpty) return;
                            await http.post(
                              Uri.parse('$baseUrl/comment/${news['id']}'),
                              body: {'user': userEmail!, 'text': text},
                            );
                            Navigator.pop(context);
                            _fetchNews(updateCache: true);
                          },
                        ),
                      ],
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(
                        "Авторизуйтесь, чтобы комментировать",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
