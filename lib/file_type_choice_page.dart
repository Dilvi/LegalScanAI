import 'package:flutter/material.dart';

class DocumentType {
  final String title;
  final String slug;
  DocumentType(this.title, this.slug);
}

class FileTypeChoicePage extends StatefulWidget {
  const FileTypeChoicePage({super.key});

  @override
  State<FileTypeChoicePage> createState() => _FileTypeChoicePageState();
}

class _FileTypeChoicePageState extends State<FileTypeChoicePage> {
  final TextEditingController _searchController = TextEditingController();

  final List<DocumentType> _allTypes = [
    DocumentType("Договор купли-продажи автомобиля", "car_sale"),
    DocumentType("Договор купли-продажи квартиры", "apartment_sale"),
  ];

  late List<DocumentType> _filteredTypes;

  @override
  void initState() {
    super.initState();
    _filteredTypes = _allTypes;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTypes = _allTypes
          .where((type) => type.title.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Выберите тип документа",
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Поиск...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _filteredTypes.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final type = _filteredTypes[index];
                return ListTile(
                  title: Text(
                    type.title,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    // Возвращаем slug (например "car_sale")
                    Navigator.pop(context, type.slug);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
