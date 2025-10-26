import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchNews();
  }

  Future<void> _fetchCategories() async {
    try {
      final res = await http.get(Uri.parse('http://95.165.74.131:8082/categories'));
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
          ? 'http://95.165.74.131:8082/news'
          : 'http://95.165.74.131:8082/news?category=$categoryId';

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
        onRefresh: _fetchNews,
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

    return Column(
      children: [
        // 🧭 Полоска категорий
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
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

        const SizedBox(height: 10),

        // 📰 Лента новостей
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _fetchNews(categoryId: selectedCategory),
            color: const Color(0xFF800000),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                final item = newsList[index];
                return _buildNewsCard(item, index);
              },
            ),
          ),
        ),
      ],
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
