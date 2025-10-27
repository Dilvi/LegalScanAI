import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LegalNewsPage extends StatefulWidget {
  const LegalNewsPage({super.key});

  @override
  State<LegalNewsPage> createState() => _LegalNewsPageState();
}

class _LegalNewsPageState extends State<LegalNewsPage> {
  List<dynamic> categories = [];
  List<dynamic> newsList = [];
  int? selectedCategory;
  bool isLoading = true;
  bool hasError = false;
  File? _avatarImage;

  @override
  void initState() {
    super.initState();
    _loadAvatarImage();
    _fetchCategories();
    _fetchNews();
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

  Future<void> _fetchCategories() async {
    try {
      final res = await http.get(Uri.parse('http://192.168.1.82:8082/categories'));
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        setState(() {
          categories = data;
        });
      }
    } catch (e) {
      print('❌ Ошибка категорий: $e');
    }
  }

  Future<void> _fetchNews({int? categoryId}) async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final url = categoryId == null
          ? 'http://192.168.1.82:8082/news'
          : 'http://192.168.1.82:8082/news?category=$categoryId';

      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        setState(() {
          newsList = data;
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
      print('❌ Ошибка новостей: $e');
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  void _toggleFavorite(int index) {
    setState(() {
      newsList[index]['isFavorite'] = !(newsList[index]['isFavorite'] ?? false);
    });
  }

  void _toggleLike(int index) {
    setState(() {
      final liked = newsList[index]['liked'] ?? false;
      newsList[index]['liked'] = !liked;
      newsList[index]['likes'] = (newsList[index]['likes'] ?? 0) + (liked ? -1 : 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF800000)));
    }

    if (hasError) {
      return RefreshIndicator(
        onRefresh: () => _fetchNews(categoryId: selectedCategory),
        color: const Color(0xFF800000),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 200),
            Center(child: Text("Не удалось загрузить новости.\nПотяните вниз, чтобы обновить")),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchNews(categoryId: selectedCategory),
      color: const Color(0xFF800000),
      child: CustomScrollView(
        slivers: [
          // 🧭 Шапка
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      // 👉 Переход в профиль (при необходимости)
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
                    "ЮрНовости",
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "Свежие юридические события и прецеденты",
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

          // 📌 Категории
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final bool isSelected = selectedCategory == cat['id'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = isSelected ? null : cat['id'];
                      });
                      _fetchNews(categoryId: isSelected ? null : cat['id']);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF800000) : const Color(0xFFF4E5E5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cat['title'],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // 📰 Новости
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final item = newsList[index];
                  return _buildNewsCard(item, index);
                },
                childCount: newsList.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> item, int index) {
    final isFavorite = item['isFavorite'] ?? false;
    final likes = item['likes'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🖼 Изображение
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Image.network(
              item['imageUrl'] ?? '',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                color: const Color(0xFFE0E0E0),
                child: const Center(child: Icon(Icons.image_not_supported)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _toggleLike(index),
                          icon: Icon(
                            (item['liked'] ?? false)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: (item['liked'] ?? false)
                                ? Colors.red
                                : Colors.grey,
                          ),
                        ),
                        Text('$likes'),
                        IconButton(
                          onPressed: () => _toggleFavorite(index),
                          icon: Icon(
                            isFavorite ? Icons.star : Icons.star_border,
                            color: isFavorite ? Colors.amber : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        // ✍️ комментарий или переход на страницу новости
                      },
                      icon: const Icon(Icons.mode_comment_outlined),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
