import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:another_flushbar/flushbar.dart';

import 'profile_page.dart';
import 'chat_page.dart';
import 'check_text_page.dart';
import 'scan_document_page.dart';
import 'upload_file_page.dart';
import 'saved_check.dart';
import 'file_type_choice_page.dart';

// 👇 Новые импорты для слайдов
import 'legal_news_page.dart';
import 'legal_database_page.dart';

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

  final PageController _pageController = PageController(initialPage: 1);
  int _currentPage = 1;

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
      recentChecks = list.map((jsonStr) {
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        return decoded;
      }).toList();
    });
  }

  Future<void> _saveRecentChecks() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = recentChecks.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('recentChecks', encoded);
  }

  Future<void> _refresh() async {
    await _loadRecentChecks();
  }

  Future<void> _navigateWithDocType(Widget Function(String) pageBuilder) async {
    final selectedType = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FileTypeChoicePage()),
    );
    if (selectedType != null && selectedType is String) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => pageBuilder(selectedType)),
      );
    }
  }

  void _showCustomNotification(String message, {Color background = const Color(0xFF800000)}) {
    Flushbar(
      messageText: Text(
        message,
        style: const TextStyle(
          fontFamily: 'DM Sans',
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      margin: const EdgeInsets.only(left: 12, right: 12, bottom: 235),
      borderRadius: BorderRadius.circular(14),
      backgroundColor: background,
      duration: const Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.BOTTOM,
    ).show(context);
  }

  void _deleteSelected() {
    setState(() {
      final indexes = selectedIndexes.toList()..sort((a, b) => b.compareTo(a));
      for (final index in indexes) {
        recentChecks.removeAt(index);
      }
      selectedIndexes.clear();
      isSelectionMode = false;
    });
    _saveRecentChecks();
    _showCustomNotification("Выбранные проверки удалены");
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
          onPressed: () => setState(() {
            isSelectionMode = false;
            selectedIndexes.clear();
          }),
        ),
        title: Text(
          'Выбрано: ${selectedIndexes.length}',
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black),
            onPressed: selectedIndexes.isEmpty ? null : _deleteSelected,
          )
        ],
      )
          : null,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  const LegalNewsPage(),
                  _buildRecentChecksPage(),
                  const LegalDatabasePage(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: _buildBottomPanel(context),
      ),
    );
  }

  Widget _buildHeader() {
    String title;
    String subtitle;
    if (_currentPage == 0) {
      title = "ЮрНовости";
      subtitle = "Свежие юридические события и прецеденты";
    } else if (_currentPage == 2) {
      title = "Правовая база";
      subtitle = "Ответы на популярные юридические вопросы";
    } else {
      title = "Добро пожаловать";
      subtitle = "Последние проверки/результат анализа";
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
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
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 15,
              color: Color(0xFF737C97),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRecentChecksPage() {
    return RefreshIndicator(
      onRefresh: _refresh,
      color: const Color(0xFF800000),
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 230, left: 20, right: 20),
        itemCount: recentChecks.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE0E0E0)),
        itemBuilder: (context, index) {
          final item = recentChecks[index];
          final riskValue = item['hasRisk'];
          String riskIcon;

          if (riskValue == true) {
            riskIcon = 'assets/Unsuccessfully.svg';
          } else if (riskValue == false) {
            riskIcon = 'assets/Successfully.svg';
          } else {
            riskIcon = 'assets/Unknown.svg';
          }

          final isSelected = selectedIndexes.contains(index);

          return GestureDetector(
            onLongPress: () {
              setState(() {
                isSelectionMode = true;
                selectedIndexes.add(index);
              });
            },
            onTap: () {
              if (isSelectionMode) {
                setState(() {
                  if (isSelected) {
                    selectedIndexes.remove(index);
                    if (selectedIndexes.isEmpty) isSelectionMode = false;
                  } else {
                    selectedIndexes.add(index);
                  }
                });
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFE4E4) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: SvgPicture.asset('assets/doc.svg', width: 45, height: 45),
                title: Text(item['type'] ?? 'Неизвестно'),
                subtitle: Text(item['date'] ?? ''),
                trailing: SvgPicture.asset(riskIcon, width: 24, height: 24),
              ),
            ),
          );
        },
      ),
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
                  onTap: () => _navigateWithDocType(
                        (docType) => CheckTextPage(docType: docType),
                  ),
                ),
                _buildIconButton(
                  label: "Сканировать\nдокумент",
                  iconPath: "assets/scan_doc_icon.svg",
                  onTap: () => _navigateWithDocType(
                        (docType) => ScanDocumentPage(docType: docType),
                  ),
                ),
                _buildIconButton(
                  label: "Загрузить\nфайл",
                  iconPath: "assets/upload_file_icon.svg",
                  onTap: () => _navigateWithDocType(
                        (docType) => UploadFilePage(docType: docType),
                  ),
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
