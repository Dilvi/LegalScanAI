import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'check_text_page.dart';
import 'profile_page.dart';
import 'chat_page.dart';
import 'scan_document_page.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> recentChecks = [];
  Set<int> selectedIndexes = {};
  bool isSelectionMode = false;
  File? _avatarImage;


  @override
  void initState() {
    super.initState();
    _loadRecentChecks();
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

  Future<void> _loadRecentChecks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('recentChecks') ?? [];

    setState(() {
      recentChecks = list
          .map((jsonStr) => jsonDecode(jsonStr) as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> _refresh() async {
    await _loadRecentChecks();
  }

  Future<void> _deleteSelected() async {
    final prefs = await SharedPreferences.getInstance();
    final newList = List<Map<String, dynamic>>.from(recentChecks);

    selectedIndexes.toList()
      ..sort((a, b) => b.compareTo(a))
      ..forEach((index) {
        newList.removeAt(index);
      });

    final updatedStringList =
    newList.map((e) => jsonEncode(e)).toList();

    await prefs.setStringList('recentChecks', updatedStringList);

    setState(() {
      recentChecks = newList;
      selectedIndexes.clear();
      isSelectionMode = false;
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      if (selectedIndexes.contains(index)) {
        selectedIndexes.remove(index);
        if (selectedIndexes.isEmpty) isSelectionMode = false;
      } else {
        selectedIndexes.add(index);
        isSelectionMode = true;
      }
    });
  }

  void _selectAll() {
    setState(() {
      selectedIndexes =
          Set.from(List.generate(recentChecks.length, (index) => index));
    });
  }

  void _exitSelectionMode() {
    setState(() {
      isSelectionMode = false;
      selectedIndexes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isSelectionMode
          ? AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: _exitSelectionMode,
        ),
        title: Text(
          'Выбрано: ${selectedIndexes.length}',
          style: const TextStyle(
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.bold,
              color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.select_all, color: Colors.black),
            onPressed: _selectAll,
            tooltip: 'Выбрать всё',
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Удалить',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Удалить выбранные элементы?"),
                  content: const Text("Это действие нельзя отменить."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text("Отмена"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text("Удалить", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                _deleteSelected();
              }
            },
          ),
        ],
      )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      ),
                      child: CircleAvatar(
                        radius: 22.5,
                        backgroundColor: const Color(0xFF800000),
                        backgroundImage: _avatarImage != null ? FileImage(_avatarImage!) : null,
                        child: _avatarImage == null
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
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
                      color: Color(0xFF737C97),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                color: const Color(0xFF800000),
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 230, left: 20, right: 20),
                  itemCount: recentChecks.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE0E0E0)),
                  itemBuilder: (context, index) {
                    final item = recentChecks[index];
                    final isSelected = selectedIndexes.contains(index);
                    return GestureDetector(
                      onLongPress: () => _toggleSelection(index),
                      onTap: () {
                        if (isSelectionMode) {
                          _toggleSelection(index);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Результат не был сохранён"),
                            ),
                          );
                        }
                      },
                      child: Container(
                        color: isSelected ? const Color(0x11707070) : null,
                        child: ListTile(
                          leading: SvgPicture.asset(
                            'assets/doc.svg',
                            width: 45,
                            height: 45,
                          ),
                          title: Text(
                            item['type'] ?? 'Неизвестно',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                          subtitle: Text(
                            item['date'] ?? '',
                            style: const TextStyle(fontFamily: 'DM Sans'),
                          ),
                          trailing: SvgPicture.asset(
                            item['hasRisk'] == true
                                ? 'assets/Unsuccessfully.svg'
                                : 'assets/Successfully.svg',
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomPanel(context),
    );
  }

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
            SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatPage()),
                ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIconButton(
                  label: "Проверить\nтекст",
                  iconPath: "assets/check_text_icon.svg",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CheckTextPage()),
                  ),
                ),
                _buildIconButton(
                  label: "Сканировать\nдокумент",
                  iconPath: "assets/scan_doc_icon.svg",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScanDocumentPage()),
                  ),
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
