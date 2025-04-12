import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  int currentIndex = 0;
  final PageController _pageController = PageController();

  void _onTabTap(int index) {
    setState(() => currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 360;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: SvgPicture.asset('assets/back_button.svg', width: 24, height: 24),
        ),
        centerTitle: true,
        title: const Text(
          'Подключить PRO',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildHeaderInfo(),
          const SizedBox(height: 10),
          _buildFeatureCard(),
          const SizedBox(height: 16),
          _buildTabSwitcher(),
          const SizedBox(height: 8),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => currentIndex = index),
              children: [
                _buildSubscriptionOptions(),
                _buildTokensOptions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: const [
          Text(
            "Окупаемость за 1 документ",
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              color: Color(0xFF800000),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF3F3),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.workspace_premium_rounded, color: Color(0xFF800000)),
                SizedBox(width: 8),
                Text(
                  "Что входит в PRO",
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF800000),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _proFeature("⚖️ Расширенный анализ документов"),
            _proFeature("📘 Пояснения на основе законов"),
            _proFeature("🚀 Приоритетная обработка без ожидания"),
            _proFeature("🧾 Шаблоны юридических документов"),
            _proFeature("🔕 Без рекламы и отвлечений"),
            _proFeature("♾️ Безлимит запросов (в годовой подписке)"),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            _buildTab("Подписка", 0),
            _buildTab("Запросы", 1),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isActive = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF800000) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isActive ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionOptions() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 8),
        _buildOptionTile("Месячная подписка", "199 ₽ / месяц (30 запросов)", () {}),
        const SizedBox(height: 10),
        _buildOptionTile("Годовая подписка", "1490 ₽ / год (безлимит)", () {}),
        const SizedBox(height: 20),
        _buildSubscribeButton(),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {},
          child: const Text(
            "🧾 Уже есть подписка? Восстановить",
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              color: Color(0xFF800000),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTokensOptions() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 8),
        _buildOptionTile("10 запросов к LegalMind", "99 ₽", () {}),
        const SizedBox(height: 10),
        _buildOptionTile("30 запросов", "199 ₽", () {}),
        const SizedBox(height: 10),
        _buildOptionTile("50 запросов", "279 ₽", () {}),
        const SizedBox(height: 10),
        _buildOptionTile("100 запросов", "449 ₽", () {}),
        const SizedBox(height: 20),
        _buildSubscribeButton(text: "Купить запросы"),
      ],
    );
  }

  Widget _buildOptionTile(String title, String subtitle, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF800000), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF800000)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscribeButton({String text = "Оформить подписку"}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          // TODO: подключить покупку
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF800000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  static Widget _proFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }
}
